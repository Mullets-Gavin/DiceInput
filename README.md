<div align="center">
<h1>Dice Input</h1>

By [Mullet Mafia Dev](https://www.roblox.com/groups/5018486/Mullet-Mafia-Dev#!/about)
</div>

Dice Input is a wrapper for Roblox inputs to wrap API for convenience of running code.

## API

```lua
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
```