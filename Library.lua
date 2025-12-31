if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local TobaHub = {
    Version = "1.0.0",
    Settings = {
        ReduceAnimations = false
    }
}

local Theme = {
    Main = Color3.fromRGB(20,20,25),
    Dark = Color3.fromRGB(30,30,35),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(235,235,235),
    Muted = Color3.fromRGB(160,160,160)
}

local Registry = {}
local Flags = {}
local Folder = "TobaHubConfigs"

local function Create(c,p)
    local i = Instance.new(c)
    for k,v in pairs(p) do i[k]=v end
    return i
end

local function Tween(o,t,p)
    if TobaHub.Settings.ReduceAnimations then
        for k,v in pairs(p) do o[k]=v end
    else
        TweenService:Create(o,TweenInfo.new(unpack(t)),p):Play()
    end
end

function TobaHub:Notify(text,time)
    time = time or 2
    local g = Player.PlayerGui:FindFirstChild("TobaHub")
    if not g then return end
    local n = Create("TextLabel",{
        Parent=g,
        Size=UDim2.fromOffset(300,40),
        Position=UDim2.fromScale(.5,.9),
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=Theme.Accent,
        Text=text,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=14,
        BackgroundTransparency=1
    })
    Create("UICorner",{Parent=n,CornerRadius=UDim.new(0,10)})
    Tween(n,{.25,Enum.EasingStyle.Quad},{BackgroundTransparency=0})
    task.delay(time,function()
        Tween(n,{.25,Enum.EasingStyle.Quad},{TextTransparency=1,BackgroundTransparency=1})
        task.wait(.3)
        n:Destroy()
    end)
end

function TobaHub:SaveConfig(name)
    if not isfolder(Folder) then makefolder(Folder) end
    local d = {}
    for f,v in pairs(Flags) do d[f]=v.Get() end
    writefile(Folder.."/"..name..".json",HttpService:JSONEncode(d))
end

function TobaHub:LoadConfig(name)
    local p = Folder.."/"..name..".json"
    if not isfile(p) then return end
    local d = HttpService:JSONDecode(readfile(p))
    for f,v in pairs(d) do
        if Flags[f] then Flags[f].Set(v) end
    end
end

function TobaHub:EnableProfiler()
    local g = Player.PlayerGui:FindFirstChild("TobaHub")
    if not g then return end
    local f = Create("Frame",{
        Parent=g,
        Size=UDim2.fromOffset(180,90),
        Position=UDim2.fromScale(.01,.95),
        AnchorPoint=Vector2.new(0,1),
        BackgroundColor3=Theme.Dark
    })
    Create("UICorner",{Parent=f})
    local l = Create("TextLabel",{
        Parent=f,
        Size=UDim2.new(1,-10,1,-10),
        Position=UDim2.new(0,5,0,5),
        BackgroundTransparency=1,
        TextXAlignment=Left,
        TextYAlignment=Top,
        Font=Enum.Font.Code,
        TextSize=13,
        TextColor3=Theme.Text
    })
    local frames,last=0,tick()
    RunService.RenderStepped:Connect(function()
        frames+=1
        if tick()-last>=1 then
            l.Text="FPS: "..frames..
            "\nMemory: "..math.floor(Stats:GetTotalMemoryUsageMb()).." MB"..
            "\nElements: "..#Registry
            frames=0
            last=tick()
        end
    end)
end

function TobaHub:CreateWindow(title)
    local gui = Create("ScreenGui",{Name="TobaHub",Parent=Player.PlayerGui,ResetOnSpawn=false})

    local main = Create("Frame",{
        Parent=gui,
        Size=UDim2.fromOffset(540,380),
        Position=UDim2.fromScale(.5,.5),
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=Theme.Main
    })
    Create("UICorner",{Parent=main,CornerRadius=UDim.new(0,14)})

    local drag,ds,sp
    main.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true ds=i.Position sp=main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            main.Position=sp+UDim2.fromOffset(d.X,d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)

    Create("TextLabel",{
        Parent=main,
        Size=UDim2.new(1,0,0,45),
        Text="  "..title,
        BackgroundTransparency=1,
        TextColor3=Theme.Text,
        Font=Enum.Font.GothamBold,
        TextSize=18,
        TextXAlignment=Left
    })

    local tabs = Create("Frame",{Parent=main,Size=UDim2.new(0,130,1,-45),Position=UDim2.new(0,0,0,45),BackgroundColor3=Theme.Dark})
    Create("UIListLayout",{Parent=tabs,Padding=UDim.new(0,6)})

    local content = Create("Frame",{Parent=main,Size=UDim2.new(1,-140,1,-55),Position=UDim2.new(0,140,0,55),BackgroundTransparency=1})

    local float = Create("TextButton",{
        Parent=gui,
        Size=UDim2.fromOffset(48,48),
        Position=UDim2.fromScale(.05,.5),
        Text="⚡",
        BackgroundColor3=Theme.Accent,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=22
    })
    Create("UICorner",{Parent=float,CornerRadius=UDim.new(1,0)})
    float.MouseButton1Click:Connect(function() main.Visible=not main.Visible end)

    local Window = {}

    function Window:CreateTab(name)
        local b = Create("TextButton",{Parent=tabs,Size=UDim2.new(1,-10,0,38),Text=name,BackgroundColor3=Theme.Main,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
        Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,8)})

        local p = Create("ScrollingFrame",{Parent=content,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),ScrollBarImageTransparency=.6,BackgroundTransparency=1,Visible=false})
        local l = Create("UIListLayout",{Parent=p,Padding=UDim.new(0,8)})
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            p.CanvasSize=UDim2.fromOffset(0,l.AbsoluteContentSize.Y+20)
        end)

        b.MouseButton1Click:Connect(function()
            for _,v in ipairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible=false end
            end
            p.Visible=true
        end)
        if #content:GetChildren()==1 then p.Visible=true end

        local Tab = {}

        function Tab:AddButton(text,cb)
            local bt = Create("TextButton",{Parent=p,Size=UDim2.new(1,-10,0,42),Text=text,BackgroundColor3=Theme.Dark,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
            Create("UICorner",{Parent=bt})
            table.insert(Registry,bt)
            bt.MouseButton1Click:Connect(cb)
        end

        function Tab:AddToggle(text,flag,def,cb)
            local s=def
            local t=Create("TextButton",{Parent=p,Size=UDim2.new(1,-10,0,42),Text=text..": "..(s and "ON" or "OFF"),BackgroundColor3=s and Theme.Accent or Theme.Dark,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
            Create("UICorner",{Parent=t})
            Flags[flag]={Get=function()return s end,Set=function(v)s=v t.Text=text..": "..(s and "ON" or "OFF") cb(s) end}
            table.insert(Registry,t)
            t.MouseButton1Click:Connect(function()
                s=not s
                t.Text=text..": "..(s and "ON" or "OFF")
                Tween(t,{.2,Enum.EasingStyle.Quad},{BackgroundColor3=s and Theme.Accent or Theme.Dark})
                cb(s)
            end)
        end

        return Tab
    end

    return Window
end

return TobaHub
