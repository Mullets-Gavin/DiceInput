--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: a wrapper for handling inputs
--]]

--// logic
local DiceInput = {}
DiceInput.Initialized = false
DiceInput.Cache = {
	['Keyboard'] = require(script:WaitForChild('Modules'):WaitForChild('Keyboard'));
	['Mouse'] = require(script:WaitForChild('Modules'):WaitForChild('Mouse'));
	['Gamepad'] = require(script:WaitForChild('Modules'):WaitForChild('Gamepad'));
	['Mobile'] = require(script:WaitForChild('Modules'):WaitForChild('Mobile'));
	['Core'] = require(script:WaitForChild('Modules'):WaitForChild('Core'));
}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function DiceInput:GetInputsEnabled()
	local contents = {}
	for index,code in pairs(DiceInput.Cache) do
		contents[index] = code.Enabled()
	end
	return contents
end

function DiceInput:Keyboard()
	return DiceInput.Cache['Keyboard']
end

function DiceInput:Mouse()
	return DiceInput.Cache['Mouse']
end

function DiceInput:Gamepad()
	return DiceInput.Cache['Gamepad']
end

function DiceInput:Mobile()
	return DiceInput.Cache['Mobile']
end

function DiceInput:Core()
	return DiceInput.Cache['Core']
end

return DiceInput