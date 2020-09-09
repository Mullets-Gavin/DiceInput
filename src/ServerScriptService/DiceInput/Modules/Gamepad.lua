--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: 
--]]

--// logic
local Gamepad = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function Gamepad.Enabled()
	return Services['UserInputService'].GamepadEnabled
end



return Gamepad