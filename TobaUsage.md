# Loadstring
```
local TobaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourName/TobaHub/main/src/TobaHub.lua"
))()
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
    TobaHub:Notify("Hello from Toba Hub")
end)
```
# Toggle
```
Main:AddToggle("God Mode","GodMode",false,function(v)
    print("God Mode:",v)
end)
```
# Save Config
```
Main:AddButton("Save Config",function()
    TobaHub:SaveConfig("Default")
    TobaHub:Notify("Config Saved")
end)
```
# Load Config
```
Main:AddButton("Load Config",function()
    TobaHub:LoadConfig("Default")
    TobaHub:Notify("Config Loaded")
end)
```
