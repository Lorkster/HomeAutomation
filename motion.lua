--[[ 
%% autostart 
%% properties 
27 value 
%% globals 
Time_of_Day 
AnnaHome
MagnusHome
--]] 
-- 10, 12	
if fibaro:countScenes()>1 then --this is always good to add to avoid the scene spawning multiple times. 
  fibaro:abort() 
end 

LTable = {10,12}

local function turnOn(device)
  local isOn = fibaro:getValue(device, "on")
  fibaro:debug("Light was " ..isOn)
  if (isOn == '0') then
    fibaro:call(device,"turnOn")
  end
end

local function turnOffFibaro(device)
  fibaro:call(device,"setColor", "0", "0", "0", "0")
end

local function updateDevice(successCallback, errorCallback, device, parameter, value)
  
  local http = net.HTTPClient()
  
  http:request('http://127.0.0.1:11111/api/plugins/callUIEvent?deviceID='..device ..'&elementName='..parameter ..'&eventType=onChanged&value=' ..value ..'',
	  {
      options = {
        method = 'GET'
      },
      success = successCallback,
      error = errorCallback
  })
end

local function setHueBrightness(device, brightness)
 	updateDevice(function(resp)
    fibaro:debug("Status: " .. resp.status)
    end,
    function(err)
    fibaro:debug('error' .. err)
    end,
    device,
    'brightness',
    brightness)
end

local function setHueColor(device, color)
 	updateDevice(function(resp)
    fibaro:debug("Status: " .. resp.status)
    end,
    function(err)
    fibaro:debug('error' .. err)
    end,
    device,
    'hue',
    color)
end

local function setHueSaturation(device, saturation)
 	updateDevice(function(resp)
    fibaro:debug("Status: " .. resp.status)
    end,
    function(err)
    fibaro:debug('error' .. err)
    end,
    device,
    'saturation',
    saturation)
end

local function setDayMode(device)
  	turnOn(device)
    turnOnTable()
 	setHueColor(device, 12750)
  	setHueSaturation(device, 80)
  	setHueBrightness(device, 254)
end

local function setFlowerMode(device)
  	turnOn(device)
    turnOnTable()
 	setHueColor(device, 53330)
  	setHueSaturation(device, 100)
  	setHueBrightness(device, 254)
end

local function setEveningMode(device)
  	turnOn(device)
    turnOnTable()
 	setHueColor(device, 9000)
  	setHueSaturation(device, 130)
  	setHueBrightness(device, 150)
end

local function setNightMode(device)
  	turnOn(device)
    turnOnTable()
 	setHueColor(device, 6000)
  	setHueSaturation(device, 254)
  	setHueBrightness(device, 50)
end

local function turnOnTable()
	for i, device in ipairs(LTable) do  
    	turnOn(device)
    	fibaro:sleep(500)
    end
end

local function turnOffTable()
	for i, device in ipairs(LTable) do  
    	turnOn(device)
    	fibaro:sleep(500)
    end
end

local function setTableHomeDayMode()
  	for i, device in ipairs(LTable) do  
    	setDayMode(device)
    	fibaro:sleep(500)
  	end
end  

local function setTableAwayMode()
  	for i, device in ipairs(LTable) do  
    	setFlowerMode(device)
    	fibaro:sleep(500)
  	end  
end

local function setTableEveningMode()
  	for i, device in ipairs(LTable) do  
    	setDayMode(device)
    	fibaro:sleep(500)
  	end
end  

local function setTableNightMode()
  	for i, device in ipairs(LTable) do  
    	setFlowerMode(device)
    	fibaro:sleep(500)
  	end  
end

local function setNightModeFibaro(device)
  	fibaro:call(device, "setColor", "255", "5", "0", "0")
end

local function setDayModeFibaro(device)
  	fibaro:call(device, "setColor", "255", "255", "255", "0")
end

------------------------------------------ Kjokken on 
local startSource = fibaro:getSourceTrigger(); 

fibaro:debug("Script started because of: " .. startSource["type"]) 

Time_of_Day = fibaro:getGlobalValue("Time_of_Day") 
LAnnaHome = tonumber(fibaro:getGlobalValue("AnnaHome"))
LMagnusHome = tonumber(fibaro:getGlobalValue("MagnusHome"))

fibaro:debug("Time_of_Day: " .. Time_of_Day) 
fibaro:debug("Motion value: " ..(fibaro:getValue(27, "value")))

local tempDeviceState0, deviceLastModification0 = fibaro:get(27, "value");
fibaro:debug("Time since activity: " ..(os.time() - deviceLastModification0))
  
if (tonumber(fibaro:getValue(27, "value")) > 0 and LMagnusHome > 0) then 
  if Time_of_Day == "Morning" or Time_of_Day == "Afternoon" then 
    fibaro:debug("Setting scenario number 1") 
     setDayMode(17) 
     setDayModeFibaro(32)
	 setTableHomeDayMode()
  elseif  Time_of_Day == "Evening"  then 
    fibaro:debug("Setting scenario number 3") 
      setEveningMode(17)
      setDayModeFibaro(32)
  	  setTableHomeDayMode()
  elseif Time_of_Day == "Night" or Time_of_Day == "Sleeping" then 
    fibaro:debug("Setting scenario number 4") 
    setNightMode(17)
    setNightModeFibaro(32)
    --setTableNightMode()
    setTableHomeDayMode()
  end 
elseif (LMagnusHome == 0) then
    setTableAwayMode()
end    

--------------------------------- Turning off

fibaro:sleep(5000); -- Time delay before turn off 
local delayedCheck0 = false; 
local tempDeviceState0, deviceLastModification0 = fibaro:get(27, "value"); 

if (( tonumber(fibaro:getValue(27, "value")) == 0 ) and (os.time() - deviceLastModification0) >= 600) then 
  	fibaro:debug("tonumber: " .. tonumber(fibaro:getValue(27, "value")))
	fibaro:debug("timecheck: " .. (os.time() - deviceLastModification0))  
  	delayedCheck0 = true; 
end 
if (LMagnusHome == 0) then
 	fibaro:call(17, "turnOff")
  	turnOffFibaro(32)
  	fibaro:debug("Turning off due to empty home")
elseif delayedCheck0 == true then 
  if Time_of_Day == "Morning" then 
    fibaro:debug("Setting scenario number 1") 
    fibaro:call(17, "turnOff")
    turnOffFibaro(32)
    --fibaro:call(24, "setValue", "50"); --  

  elseif (Time_of_Day == "Afternoon" or Time_of_Day == "Evening" or Time_of_Day == "Night" ) then 
    fibaro:debug("Setting scenario number 2") 
    fibaro:call(17, "turnOff")
    turnOffFibaro(32)
    --fibaro:call(24, "setValue", "3"); --   
  end 
end 
