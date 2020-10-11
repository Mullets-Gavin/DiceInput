--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: an input wrapper to streamline inputs on all platforms
--]]

--[[
[DOCUMENTATION]:
	.IsComputer()
	.IsMobile()
	.IsConsole()
	
	.IsKeyboard()
	.IsMouse()
	.IsTouch()
	.Gamepad()
	.IsVR()
	
	.create(name)
	
	local Action = Input.create('Action')
	Action:Keybinds()
	Action:Hook(function)
	Action:Unbind()
	
	Input:Disconnect(name)
	Input:Update(name,{keybinds}
	Input:Began(name,{keybinds},function)
	Input:Ended(name,{keybinds},function)
	Input:Tapped(name,function)
	
[NOTES]:
	inputObject.KeyCode
	inputObject.Delta
	inputObject.Position
	inputObject.UserInputState
	inputObject.UserInputType
	
[WHAT I WANT]:
	- if using CAS option & mobile is enabled, set button to visible.
	- if CAS option & mobile is not enabled (by default, it is not), set button to invisible
--]]

--// logic
local Input = {}
Input.Cache = {}
Input.Touch = {}
Input.Events = {}
Input.Debug = false

local Element = {}
Element.Cache = {}
Element.Events = {}
Element.Positions = {}

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// variables
local Positioning = require(script:WaitForChild('Positioning'))
local Manager = require(script:WaitForChild('Manager'))
local Player = Services['Players'].LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')
local Container = PlayerGui:FindFirstChild('DiceMobile') do
	if not Container then
		Container = Instance.new('ScreenGui')
		Container.Name = 'DiceMobile'
		Container.Enabled = false
		Container.ResetOnSpawn = false
		Container.Parent = PlayerGui
	end
end

--// functions
function Element:GetButton(name)
	return Element.Cache[name]
end

function Element:CreateButton(name)
	if Element:GetButton(name) then
		return Element:GetButton(name)
	end
	local button = Instance.new('ImageButton')
	button.Name = name
	button.BackgroundTransparency = 1
	button.Image = 'rbxassetid://3376854277'
	button.ImageColor3 = Color3.fromRGB(0,0,0)
	button.ImageTransparency = 0.5
	button.Visible = false
	local icon = Instance.new('ImageLabel')
	icon.Name = 'Icon'
	icon.BackgroundTransparency = 1
	icon.Image = ''
	icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
	icon.ImageTransparency = 0.5
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	icon.Size = UDim2.new(0.8, 0, 0.8, 0)
	icon.ZIndex = 10
	icon.Parent = button
	Element.Cache[name] = button
	button.Parent = Container
	return button
end

function Element:EnableButton(name,state)
	assert(typeof(name) == 'string')
	assert(typeof(state) == 'boolean')
	
	local button = Element:GetButton(name)
	local data = Input.Cache[name]
	if not button or not data then return end
	if state then
		button.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		button.Icon.ImageTransparency = 0
	else
		button.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
		button.Icon.ImageTransparency = 0.5
	end
end

function Element.Effects(name)
	local button = Element:GetButton(name)
	if button then
		Manager:ConnectKey(name,button.MouseButton1Down:Connect(function()
			button.ImageColor3 = Color3.fromRGB(255, 255, 255)
			button.ImageTransparency = 0.75
		end))
		Manager:ConnectKey(name,button.MouseButton1Up:Connect(function()
			button.ImageColor3 = Color3.fromRGB(0, 0, 0)
			button.ImageTransparency = 0.5
		end))
		Manager:ConnectKey(name,button.MouseLeave:Connect(function()
			button.ImageColor3 = Color3.fromRGB(0, 0, 0)
			button.ImageTransparency = 0.5
		end))
		Manager:ConnectKey(name,button.InputBegan:Connect(function(obj)
			if not Input.Cache[name] then return end
			if not Input.Cache[name]['Enabled'] then return end
			if not Input.Cache[name]['Function'] then return end
			if not Input.Cache[name]['Verify'] then return end
			Input.Cache[name]['Function'](obj)
		end))
	end
end

function Input.IsComputer()
	local check = Input.IsKeyboard() and Input.IsMouse() and true or false
	return check
end

function Input.IsMobile()
	local check = Input.IsTouch() and not Input.IsKeyboard() and true or false
	return check
end

function Input.IsConsole()
	return Services['GuiService']:IsTenFootInterface()
end

function Input.IsKeyboard()
	return Services['UserInputService'].KeyboardEnabled
end

function Input.IsMouse()
	return Services['UserInputService'].MouseEnabled
end

function Input.IsTouch()
	return Services['UserInputService'].TouchEnabled
end

function Input.IsGamepad()
	return Services['UserInputService'].GamepadEnabled
end

function Input.IsVR()
	return Services['UserInputService'].VREnabled
end

function Input:Disconnect(name)
	assert(typeof(name) == 'string')
	
	if Input.Events[name] then
		Input.Events[name] = nil
	end
end

function Input:Update(name,keys)
	assert(typeof(name) == 'string')
	assert(typeof(keys) == 'table')
	for index,key in pairs(keys) do
		assert(typeof(key) == 'EnumItem')
	end
	
	if Input.Events[name] then
		Input.Events[name]['Keys'] = keys
		return true
	end
	return false
end

function Input:Began(name,keys,code)
	assert(typeof(name) == 'string')
	assert(typeof(keys) == 'table')
	assert(typeof(code) == 'function')
	for index,key in pairs(keys) do
		assert(typeof(key) == 'EnumItem')
	end
	
	if Input.Events[name] then
		Input.Events[name] = nil
		if Input.Debug then
			warn("[DICE INPUT]: '"..name.."' is already connected, disconnecting.")
		end
	end
	Input:Disconnect(name)
	Input.Events[name] = {
		['Keys'] = keys;
		['Code'] = code;
		['Type'] = 'Began';
	}
end

function Input:Ended(name,keys,code)
	assert(typeof(name) == 'string')
	assert(typeof(keys) == 'table')
	assert(typeof(code) == 'function')
	for index,key in pairs(keys) do
		assert(typeof(key) == 'EnumItem')
	end
	
	if Input.Debug and Input.Events[name] then
		warn("[DICE INPUT]: '"..name.."' is already connected, disconnecting.")
	end
	Input:Disconnect(name)
	Input.Events[name] = {
		['Keys'] = keys;
		['Code'] = code;
		['Type'] = 'Ended';
	}
end

function Input:Tapped(name,code)
	assert(typeof(name) == 'string')
	assert(typeof(code) == 'function')
	
	if Input.Debug and Input.Touch[name] then
		warn("[DICE INPUT]: '"..name.."' is already connected, disconnecting.")
	end
	Input.Touch[name] = {
		['Code'] = code;
		['Type'] = 'Ended';
	}
end

function Input.destroy(name)
	if Input.Cache[name] then
		for index in pairs(Input.Cache[name]) do
			Input.Cache[name][index] = nil
		end
	end
end

function Input.create(name)
	assert(typeof(name) == 'string')
	
	Element:CreateButton(name)
	if not Input.Cache[name] then
		Input.Cache[name] = {}
	end
	
	local control = {}
	
	--[[
	Functions:
	.Verify()
	:Enabled(bool)
	:Keybinds(...)
	:Mobile(bool,image)
	:Hook(function)
	--]]
	
	function control.Verify()
		assert(Input.Cache[name] ~= nil)
		
		if Input.Cache[name]['Keys'] and Input.Cache[name]['Function'] then
			Input.Cache[name]['Verify'] = true
		else
			Input.Cache[name]['Verify'] = false
		end
	end
	
	function control:Enabled(state)
		assert(typeof(state) == 'boolean')
		
		Input.Cache[name]['Enabled'] = state
		Element:EnableButton(name,state)
		control.Verify()
	end
	
	function control:Keybinds(...)
		local capture = {}
		for index,key in pairs({...}) do
			assert(typeof(key) == 'EnumItem')
			table.insert(capture,key)
		end
		
		Input.Cache[name]['Keys'] = capture
		control.Verify()
	end
	
	function control:Mobile(state,image)
		assert(typeof(state) == 'boolean')
		
		Input.Cache[name]['Mobile'] = state
		local button = Element:GetButton(name)
		if button then
			button.Visible = state
			if image then
				assert(typeof(image) == 'string')
				
				button.Icon.Image = image
			end
		end
		control.Verify()
	end
	
	function control:Hook(code)
		assert(typeof(code) == 'function')
		
		if Input.Cache[name]['Function'] then
			Input.Cache[name]['Function'] = nil
		end
		Input.Cache[name]['Function'] = code
		control.Verify()
	end
	
	function control:Destroy()
		local button = Element:GetButton(name)
		if button then
			Manager:DisconnectKey(name)
			button:Destroy()
		end
		for index in pairs(control) do
			control[index] = nil
		end
		setmetatable(control, {
			__index = function()
				error('[DICE MANAGER]: Attempt to use destroyed task scheduler')
			end;
			__newindex = function()
				error('[DICE MANAGER]: Attempt to use destroyed task scheduler')
			end;
		})
	end
	
	return control
end

Services['UserInputService'].InputBegan:Connect(function(obj,processed)
	if processed then return end
	for name,data in pairs(Input.Cache) do
		if data['Verify'] and data['Enabled'] and data['Function'] and data['Keys'] then
			if table.find(data['Keys'],obj.KeyCode) or table.find(data['Keys'],obj.UserInputType) then
				Manager.wrap(function()
					data['Function'](obj)
				end)
			end
		end
	end
	
	for index,data in pairs(Input.Events) do
		if data['Type'] == 'Began' then
			if table.find(data['Keys'],obj.KeyCode) or table.find(data['Keys'],obj.UserInputType) then
				Manager.wrap(function()
					data['Code'](obj)
				end)
			end
		end
	end
end)

Services['UserInputService'].InputEnded:Connect(function(obj,processed)
	if processed then return end
	for index,data in pairs(Input.Events) do
		if data['Type'] == 'Ended' then
			if table.find(data['Keys'],obj.KeyCode) or table.find(data['Keys'],obj.UserInputType) then
				Manager.wrap(function()
					data['Code'](obj)
				end)
			end
		end
	end
end)

Services['UserInputService'].TouchTap:Connect(function(obj,processed)
	if processed then return end
	for index,data in pairs(Input.Touch) do
		Manager.wrap(function()
			data['Code'](obj)
		end)
	end
end)

Manager.wrap(function()
	if Input.IsMobile() then
		Container.Enabled = true
		
		local Size,Jump; do
			local TouchGui = PlayerGui:WaitForChild('TouchGui',math.huge)
			local TouchFrame = TouchGui:WaitForChild('TouchControlFrame',math.huge)
			Jump = TouchFrame:WaitForChild('JumpButton',math.huge)
			while not Player.Character do Manager.wait() end
			Size = UDim2.new(0,Jump.Size.X.Offset/1.25,0,Jump.Size.Y.Offset/1.25)
		end
		
		local log = {}
		local config = {
			CENTER_BUTTON_POSITION = Jump.AbsolutePosition,
			CENTER_BUTTON_SIZE = Jump.AbsoluteSize,
			N_BUTTONS = 4,
			MIN_RADIUS_PADDING = 10,
			BUTTON_PADDING = 5,
			BUTTON_SIZE = UDim2.new(0, Jump.Size.X.Offset/1.25, 0, Jump.Size.Y.Offset/1.25),
			RESOLUTION = Container.AbsoluteSize,
		}
		
		local function Organize()
			local generate = Positioning.make_table_on_the_fly_but_bigger_every_time(#log)
			config.MIN_RADIUS = 0
			local positions = Positioning.get_positions_with_rows(generate,config)
			for index,button in ipairs(log) do
				if not button then continue end
				button.Position = positions[index]
			end
		end
		
		for index,button in ipairs(Container:GetChildren()) do
			if table.find(log,button) then continue end
			table.insert(log,button)
			button.Size = Size
			Element.Effects(button.Name)
			Organize()
		end
		Container.ChildAdded:Connect(function(button)
			if table.find(log,button) then return end
			table.insert(log,button)
			button.Size = Size
			Element.Effects(button.Name)
			Organize()
		end)
	end
end)

return Input