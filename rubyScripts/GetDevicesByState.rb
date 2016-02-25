require 'net/https'
require 'rexml/document'

#*************** Edit Script Variables here ********************************
host = 'demo.perfectomobile.com'
user = 'brianc@perfectomobile.com'
pwd = '54Ph1R3!'

state = 'connected' # [connected, not connected, ready to connect, error, ANY]

#****************************************************************************


def parseResponse(response, state)
  puts "Parsing response...."
  doc = REXML::Document.new(response)
  device_ids = [] #Array to hold found devices
  #Check each handset node
  doc.elements.each('handsets/handset') do |handset|
      # Check status value, if 'ANY' add all devices to list and add status value
      if (state.casecmp('ANY') == 0)        
        deviceString = handset.elements['deviceId'].text + 
                        " - Status:" + 
                        handset.elements['status'].text
          # if connected is it in use?
          if (handset.elements['status'].text.casecmp('connected')==0) 
          deviceString +=  " - In Use:" + 
                            handset.elements['inUse'].text              
        end
        # add  to  list
        device_ids << deviceString
      # Check status value, only add if matching case
      elsif (handset.elements['status'].text.casecmp(state)== 0)
        deviceString = handset.elements['deviceId'].text
        # if connected is it in use?
        if (handset.elements['status'].text.casecmp('connected')==0) 
                    deviceString +=  " - In Use:" + 
                                      handset.elements['inUse'].text              
        end
        # add  to  list
        device_ids << deviceString 
      end
  end
  return device_ids
end


def findDevicesByState(host,user,pwd,state)
  # encode username and password
  _user = URI::encode(user)
  _pwd = URI::encode(pwd)
  
  uri = URI.parse("https://" + 
                   host + 
                   "/services/handsets?operation=list&user=" + 
                   _user + 
                   "&password=" + 
                   _pwd)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  req = Net::HTTP::Get.new(uri.request_uri)
  puts "Sending request..."
  res = http.request(req)
  
 if(!res.code == 200) #Check response
   err_msg = "Failed to get Device List. " + res.body
   raise err_msg
 end  
  if(!res.nil?) #Check for content
    devices = parseResponse(res.body, state)
    if(devices.empty?) 
      puts "\nNo devices found in '" + state + "' state"
    else
      puts "\n"+ devices.count.to_s + 
        " Devices found in the " + host + 
        " cloud that are currently in '" + state + "' state:"
      devices.each{|d| puts "     " + d}
    end
  end    
end


findDevicesByState(host,user,pwd, state)
