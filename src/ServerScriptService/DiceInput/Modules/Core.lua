--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: roblox input
--]]

--// logic
local Core = {}
Core.Focus = {}
Core.Release = {}
Core.Opened = {}
Core.Closed = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
function Core.Enabled()
	return false
end

function Core:MenuOpened(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Core.Opened,code)
		if findFunc then
			table.remove(Core.Opened,findFunc)
		end
	end
	table.insert(Core.Opened,code)
	return connection
end

function Core:MenuClosed(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Core.Closed,code)
		if findFunc then
			table.remove(Core.Closed,findFunc)
		end
	end
	table.insert(Core.Closed,code)
	return connection
end

function Core:WindowFocused(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Core.Focus,code)
		if findFunc then
			table.remove(Core.Focus,findFunc)
		end
	end
	table.insert(Core.Focus,code)
	return connection
end

function Core:WindowReleased(code)
	assert(typeof(code) == 'function',"[DICE INPUT]: Supplied connection must be a function, got '".. typeof(code) .."'")
	local connection = {}
	function connection:Disconnect()
		local findFunc = table.find(Core.Release,code)
		if findFunc then
			table.remove(Core.Release,findFunc)
		end
	end
	table.insert(Core.Release,code)
	return connection
end

Services['GuiService'].MenuOpened:Connect(function()
	for index,code in pairs(Core.Opened) do
		code()
	end
end)

Services['GuiService'].MenuClosed:Connect(function()
	for index,code in pairs(Core.Closed) do
		code()
	end
end)

Services['UserInputService'].WindowFocused:Connect(function()
	for index,code in pairs(Core.Focus) do
		code()
	end
end)

Services['UserInputService'].WindowFocusReleased:Connect(function()
	for index,code in pairs(Core.Release) do
		code()
	end
end)

return Core