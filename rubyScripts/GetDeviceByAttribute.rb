require 'net/https'
require 'rexml/document'

#*************** Edit Script Variables here ********************************
host = 'YourCloud.perfectomobile.com'
user = 'YourUser@perfectomobile.com'
pwd = 'YourPerfectoPassword'

# Enter any desired attributes value into the Hash at the appropriate key
#       Leave as empty ("") string if not using
attributes = Hash["deviceId" => "",
                  "manufacturer" => "",
                  "model" => "",
                  "os" => "",
                  "osVersion" => "",
                  "description" => "brian",
                  "phoneNumber" => "",
                  "location" => ""] 

#****************************************************************************


def filterByAttributes(response, atts)
  puts "Parsing response...."
  doc = REXML::Document.new(response)
  puts "There are " + doc.elements['handsets'].size.to_s + " total devices in the cloud"
  #resize hash
  atts.delete_if{|k,v| v == "" }
  puts "Looking for devices with "+ atts.length.to_s + " attributes: " + atts.to_s
 
  
  device_ids = [] #Array to hold found devices
  #Check each handset node
  
  doc.elements.each('handsets/handset') do |handset|
      # Check status value, if device is available 
      if (handset.elements['available'].text.casecmp('true')==0)  
        i = 0
        #Check for any matching attributes 
        atts.each{|k,v|
          #Break out if any attribute not found for current device
          break  if !(handset.elements[k].text.downcase.include?(v.downcase))
          i = i+1      
        }        
      end
      #skip this device if not matching all attributes
     next if !(i == atts.length)
      # Otherwise add  to the list
      device_ids << handset.elements['deviceId'].text                      
  end
  return device_ids
end

def requestDevicesfromCloud(host,user,pwd)
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
     err_msg = "Failed to access the cloud. " + res.body
     raise err_msg
     return nil
   end  
    if(!res.nil?) #Check for content
      return res.body
    else 
      return nil
    end  
end

def findDevicesByAttributes(host,user,pwd,atts)
  #
 response =  requestDevicesfromCloud(host,user,pwd) 
  if(!response.nil?) #Check for content
    devices = filterByAttributes(response, atts)
    if(devices.empty?) 
      puts "\nNo devices found matching all of the specified attributes"
    else
      puts "\nThere are "+ devices.count.to_s + 
        " Devices found that currently match the specified attributes:"
      devices.each{|d| puts "     " + d}
    end
  end    
end


findDevicesByAttributes(host,user,pwd, attributes)
