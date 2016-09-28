#  please install the required gems - this was written in Ruby 2.2.3
require 'selenium-webdriver'

# sets variables for perfecto driver 
@username = "youruser@perfectomobile.com"
@password = "yourpwd"
@perfecto_server = "yourcloud.perfectomobile.com/nexperience/perfectomobile"
@deviceid = "yourDeviceID"

# creates the remote webdriver driver
puts "Creating the driver..."

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 300 # seconds

  caps = Selenium::WebDriver::Remote::Capabilities.new
  caps['browserName'] = 'mobileOS'
  caps['user'] = @username
  caps['password'] = @password
  caps['deviceName'] = @deviceid
  caps['takesScreenshot'] = true

  @driver = Selenium::WebDriver.for(:remote,
                                    :url => 'http://'+ @perfecto_server + '/wd/hub',
                                    :desired_capabilities => caps,
                                    :http_client => client)

puts @driver.to_s

begin  
    clearCache()
    
    # Do other work....
    
rescue  => exception
    puts "Now that was wasn't very fun!!"
    puts exception.backtrace
    raise exception
    
ensure
    # always quit the driver...
    @driver.quit   
end


# load at start of script
BEGIN{
  def clearCache()
      params = {}
      params["property"] = "os"
      devType = @driver.execute_script("mobile:handset:info", params)
      puts "Current device type: " + devType
      case devType.downcase    
        when "android"
          @driver.execute_script("mobile:browser:open", {})
          sleep(3)
          @driver.execute_script("mobile:browser:clean", {})
          @driver.execute_script("mobile:browser:open", {}) 
          
          # Accept agreement
          params.clear()
          params["content"] = "ACCEPT & CONTINUE"
          params["timeout"] = "15"  
          @driver.execute_script("mobile:text:select", params)
          
          # Sign in to Chrome ---> NO THANKS
          params.clear()
          params["content"] = "Sign in to Chrome"
          params["timeout"] = "15" 
          if( @driver.execute_script("mobile:text:find", params))
            params.clear()
            params["content"] = "NO THANKS"
            @driver.execute_script("mobile:text:select", params)    
          end
          
        when "ios"
        # Close Safari (Or it always wants to come back to the front)
          puts "Closing 'Safari' app"
          params.clear()
          params["name"] = "Safari"
          @driver.execute_script("mobile:application:close", params)
          
          # Open/Close/Open Settings app ... sets to default state
          puts "Opening 'Settings' app"
          params.clear()
          params["name"] = "Settings"
          @driver.execute_script("mobile:application:open", params)
          puts "Closing 'Settings' app"
          params.clear()
          params["name"] = "Settings"
          @driver.execute_script("mobile:application:close", params)
          puts "Opening 'Settings' app"
          params.clear()
          params["name"] = "Settings"
          @driver.execute_script("mobile:application:open", params)
          
          
          #Give app a few seconds to open
          sleep(3)
          
          # Look for 'Safari'
          params.clear()
          params['content'] = "Safari"
          params['scrolling'] = "scroll"
          params['next'] = "SWIPE_UP"
          @driver.execute_script("mobile:text:select", params)
          
          # Look for Clear History...
          params.clear()
          params['content'] = "Clear History and Website Data"
          params['scrolling'] = "scroll"
          params['next'] = "SWIPE_UP"
          @driver.execute_script("mobile:text:select", params)
          
          #  Clear History...
          params.clear()
          params['content'] = "Clear History and Data"
          params['timeout'] = "15"
          @driver.execute_script("mobile:text:select", params)
          
          #  back to main Settings
          params.clear()
          params['content'] = "Settings"
          params['timeout'] = "15"
          @driver.execute_script("mobile:text:select", params)
          
          # Open The Browser
          @driver.execute_script("mobile:browser:open", {})
      else
        puts "Clear Cache not supported for this OS"
      end    
    
  end
}