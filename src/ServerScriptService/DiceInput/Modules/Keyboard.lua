--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: keyboard input
--]]

--// logic
local Keyboard = {}
Keyboard.Began = {}
Keyboard.Ended = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function Keyboard.Enabled()
	if not Services['UserInputService'].TouchEnabled and Services['UserInputService'].KeyboardEnabled then
		return true
	end
	return false
end

function Keyboard:IsValidKey(enum)
	if typeof(enum) == 'EnumItem' then
		return enum
	elseif typeof(enum) == 'string' then
		if Enum.KeyCode[enum] then
			return Enum.KeyCode[enum]
		end
	end
	return false
end

function Keyboard:IsKey(input,enum)
	if not Keyboard:IsValidKey(enum) then return false end
	if typeof(enum) == 'EnumItem' and typeof(input) == 'Instance' then
		if input.KeyCode == enum then
			return true,input.KeyCode
		end
	elseif typeof(enum) == 'string' and typeof(input) == 'Instance' then
		if input.KeyCode == Enum.KeyCode[enum] then
			return true,input.KeyCode
		end
	end
	return false
end

function Keyboard:KeyDown(enum)
	local validKey = Keyboard:IsValidKey(enum)
	if validKey then
		if Services['UserInputService']:IsKeyDown(validKey) then
			return true
		end
		return false
	end
	warn('[DICE INPUT]: Enum provided does not exist & is not valid')
	return false
end

function Keyboard:KeyUp(enum)
	local validKey = Keyboard:IsValidKey(enum)
	if validKey then
		if not Services['UserInputService']:IsKeyDown(validKey) then
			return true
		end
		return false
	end
	warn('[DICE INPUT]: Enum provided does not exist & is not valid')
	return false
end

function Keyboard:InputBegan(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Keyboard.Began,code)
		if findFunc then
			table.remove(Keyboard.Began,findFunc)
		end
	end
	table.insert(Keyboard.Began,code)
	return connection
end

function Keyboard:InputEnded(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Keyboard.Ended,code)
		if findFunc then
			table.remove(Keyboard.Ended,findFunc)
		end
	end
	table.insert(Keyboard.Ended,code)
	return connection
end

Services['UserInputService'].InputBegan:Connect(function(input,processed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		for index,code in pairs(Keyboard.Began) do
			code(input,processed)
		end
	end
end)

Services['UserInputService'].InputEnded:Connect(function(input,processed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		for index,code in pairs(Keyboard.Ended) do
			code(input,processed)
		end
	end
end)

return Keyboard