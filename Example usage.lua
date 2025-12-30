local Toba = loadstring(game:HttpGet("https://example.com/toba_library.lua"))()

local Window = Toba:CreateWindow("Toba Hub", {
    Logo = "rbxassetid://1234567890",
    Accent = Color3.fromRGB(105, 125, 255),
    ToggleKey = Enum.KeyCode.RightShift
})

local PlayerTab = Window:AddTab("Player")

PlayerTab:AddButton("Click Me", function()
    print("Clicked!")
end)

PlayerTab:AddToggle("Infinite Stamina", function(state)
    print("Infinite Stamina:", state)
end, false)

PlayerTab:AddSlider("WalkSpeed", 16, 200, 16, function(val)
    print("WalkSpeed:", val)
end)

PlayerTab:AddTextbox("Name", "Player1", function(text)
    print("Textbox:", text)
end)

PlayerTab:AddParagraph("Info", [[
This is a paragraph.
You can write multiple lines of info here.
]])

Window:Show()
