--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: 
--]]

--// logic
local Mouse = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function Mouse.Enabled()
	return Services['UserInputService'].MouseEnabled
end

return Mouse