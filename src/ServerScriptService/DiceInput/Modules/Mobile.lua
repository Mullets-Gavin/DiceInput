--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: 
--]]

--// logic
local Mobile = {}
Mobile.TouchTap = {}
Mobile.TouchStarted = {}
Mobile.TouchEnded = {}
Mobile.TouchSwipe = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function Mobile.Enabled()
	if Services['UserInputService'].TouchEnabled and not Services['UserInputService'].KeyboardEnabled then
		return true
	end
	return false
end

function Mobile:InputTouchTap(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Mobile.TouchTap,code)
		if findFunc then
			table.remove(Mobile.TouchTap,findFunc)
		end
	end
	table.insert(Mobile.TouchTap,code)
	return connection
end

function Mobile:InputTouchStarted(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Mobile.TouchStarted,code)
		if findFunc then
			table.remove(Mobile.TouchStarted,findFunc)
		end
	end
	table.insert(Mobile.TouchStarted,code)
	return connection
end

function Mobile:InputTouchEnded(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Mobile.TouchEnded,code)
		if findFunc then
			table.remove(Mobile.TouchEnded,findFunc)
		end
	end
	table.insert(Mobile.TouchEnded,code)
	return connection
end

function Mobile:InputTouchSwipe(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Mobile.TouchSwipe,code)
		if findFunc then
			table.remove(Mobile.TouchSwipe,findFunc)
		end
	end
	table.insert(Mobile.TouchSwipe,code)
	return connection
end



return Mobile