# Loadstring
```
local TobaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Legitxwx/TobaUI/refs/heads/main/Library.lua"))()
```
# Window
```
local Window = TobaHub:CreateWindow("Toba Hub")
```
# Profiler
```
TobaHub:EnableProfiler()
```
# Tab
```
local Main = Window:CreateTab("Main")
```
# Button
```
Main:AddButton("Notify", function()
    TobaHub:Notify("Hello from Toba Hub","info")
end)
```
# Toggle
```
Main:AddToggle("God Mode","GodMode",false,function(v)
    print("God Mode:",v)
end)
```
# Slider
```
Main:AddSlider("Walk Speed",16,500,16,function(value)   game.Players.LocalPlayer.Character.Humanoid.WalkSpeed=value
end)
```
# Dropdown
```
Main:AddDropdown("Select Color",{"Red","Blue","Green","Yellow"},function(val)
    print("Selected:",val)
end)
```
# Save Config
```
Main:AddButton("Save Config",function()
    TobaHub:SaveConfig("Default")
    TobaHub:Notify("Config Saved","success")
end)
```
# Load Config
```
Main:AddButton("Load Config",function()
    TobaHub:LoadConfig("Default")
    TobaHub:Notify("Config Loaded","success")
end)
```
