if not game:IsLoaded() then game.Loaded:Wait() end

local Players, UIS, TweenService, RunService, Stats, HttpService =
    game:GetService("Players"),
    game:GetService("UserInputService"),
    game:GetService("TweenService"),
    game:GetService("RunService"),
    game:GetService("Stats"),
    game:GetService("HttpService")

local Player = Players.LocalPlayer
local TobaHub = {Version="1.3.0", Settings={ReduceAnimations=false}}

local Theme = {
    Main=Color3.fromRGB(20,20,25),
    Dark=Color3.fromRGB(30,30,35),
    Accent=Color3.fromRGB(0,170,255),
    Text=Color3.fromRGB(235,235,235),
    Muted=Color3.fromRGB(160,160,160)
}

local Registry, Flags, Folder = {}, {}, "TobaHubConfigs"

local function Create(c,p)local i=Instance.new(c) for k,v in pairs(p) do i[k]=v end return i end
local function Tween(o,t,p)if TobaHub.Settings.ReduceAnimations then for k,v in pairs(p) do o[k]=v end else TweenService:Create(o,TweenInfo.new(unpack(t)),p):Play() end end

-- Animations helper
local function AnimateWindow(window,open)
    if open then
        window.Visible=true
        window.Position=UDim2.new(0.5,0,0.5,0)+UDim2.fromOffset(0,-50)
        window.Size=UDim2.fromOffset(540,380)
        Tween(window,{0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out},{Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(540,380),BackgroundTransparency=0})
    else
        Tween(window,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In},{BackgroundTransparency=1,Size=UDim2.fromOffset(540,380),Position=UDim2.new(0.5,0,0.5,0)+UDim2.fromOffset(0,-50)})
        task.delay(0.25,function() window.Visible=false end)
    end
end

function TobaHub:Notify(text,time,type)
    time=time or 2
    local g=Player.PlayerGui:FindFirstChild("TobaHub")
    if not g then return end
    local n=Create("TextLabel",{
        Parent=g, Size=UDim2.fromOffset(300,40), Position=UDim2.fromScale(.5,.9),
        AnchorPoint=Vector2.new(.5,.5), BackgroundColor3=(type=="success" and Color3.fromRGB(0,220,100) or type=="warning" and Color3.fromRGB(255,160,0) or Theme.Accent),
        Text=text, TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=14, BackgroundTransparency=1
    })
    Create("UICorner",{Parent=n,CornerRadius=UDim.new(0,10)})
    Tween(n,{0.25,Enum.EasingStyle.Quad},{BackgroundTransparency=0})
    task.delay(time,function() Tween(n,{0.25,Enum.EasingStyle.Quad},{TextTransparency=1,BackgroundTransparency=1}) task.wait(.3) n:Destroy() end)
end

function TobaHub:SaveConfig(name)
    if not isfolder(Folder) then makefolder(Folder) end
    local d={} for f,v in pairs(Flags) do d[f]=v.Get() end
    writefile(Folder.."/"..name..".json",HttpService:JSONEncode(d))
end

function TobaHub:LoadConfig(name)
    local p=Folder.."/"..name..".json"
    if not isfile(p) then return end
    local d=HttpService:JSONDecode(readfile(p))
    for f,v in pairs(d) do if Flags[f] then Flags[f].Set(v) end end
end

function TobaHub:EnableProfiler()
    local g=Player.PlayerGui:FindFirstChild("TobaHub")
    if not g then return end
    local f=Create("Frame",{Parent=g,Size=UDim2.fromOffset(180,90),Position=UDim2.fromScale(.01,.95),AnchorPoint=Vector2.new(0,1),BackgroundColor3=Theme.Dark})
    Create("UICorner",{Parent=f})
    local l=Create("TextLabel",{Parent=f,Size=UDim2.new(1,-10,1,-10),Position=UDim2.new(0,5,0,5),BackgroundTransparency=1,TextXAlignment=Left,TextYAlignment=Top,Font=Enum.Font.Code,TextSize=13,TextColor3=Theme.Text})
    local frames,last=0,tick()
    RunService.RenderStepped:Connect(function()
        frames+=1
        if tick()-last>=1 then
            l.Text="FPS: "..frames.."\nMemory: "..math.floor(Stats:GetTotalMemoryUsageMb()).." MB\nElements: "..#Registry
            frames=0 last=tick()
        end
    end)
end

function TobaHub:CreateWindow(title)
    local gui=Create("ScreenGui",{Name="TobaHub",Parent=Player.PlayerGui,ResetOnSpawn=false})
    local main=Create("Frame",{Parent=gui,Size=UDim2.fromOffset(540,380),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Theme.Main})
    Create("UICorner",{Parent=main,CornerRadius=UDim.new(0,14)})
    
    local drag,ds,sp
    main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true ds=i.Position sp=main.Position end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds main.Position=sp+UDim2.fromOffset(d.X,d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)

    Create("TextLabel",{Parent=main,Size=UDim2.new(1,0,0,45),Text="  "..title,BackgroundTransparency=1,TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Left})

    -- Tabs container
    local tabs=Create("Frame",{Parent=main,Size=UDim2.new(0,130,1,-45),Position=UDim2.new(0,0,0,45),BackgroundTransparency=1})
    local tabLayout=Create("UIListLayout",{Parent=tabs,Padding=UDim.new(0,6)})

    local content=Create("Frame",{Parent=main,Size=UDim2.new(1,-140,1,-55),Position=UDim2.new(0,140,0,55),BackgroundTransparency=1})

    -- Floating toggle button
    local float=Create("TextButton",{Parent=gui,Size=UDim2.fromOffset(48,48),Position=UDim2.fromScale(.05,.5),Text="⚡",BackgroundColor3=Theme.Accent,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=22})
    Create("UICorner",{Parent=float,CornerRadius=UDim.new(1,0)})
    local dragging=false local dragInput,mousePos,startPos
    float.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true startPos=float.Position mousePos=input.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
    float.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta=dragInput.Position-mousePos float.Position=startPos+UDim2.fromOffset(delta.X,delta.Y) end end)
    float.MouseButton1Click:Connect(function() AnimateWindow(main,not main.Visible) end)

    local Window={}
    function Window:CreateTab(name)
        local b=Create("TextButton",{Parent=tabs,Size=UDim2.new(1,-10,0,38),Text=name,BackgroundColor3=Theme.Main,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
        Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,8)})
        local p=Create("ScrollingFrame",{Parent=content,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),ScrollBarImageTransparency=.6,BackgroundTransparency=1,Visible=false})
        local l=Create("UIListLayout",{Parent=p,Padding=UDim.new(0,8)})
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() p.CanvasSize=UDim2.fromOffset(0,l.AbsoluteContentSize.Y+20) end)

        b.MouseButton1Click:Connect(function()
            for _,v in ipairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then Tween(v,{0.25,Enum.EasingStyle.Quad},{BackgroundTransparency=1}) v.Visible=false end
            end
            p.Visible=true
            Tween(p,{0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out},{BackgroundTransparency=0})
        end)
        if #content:GetChildren()==1 then p.Visible=true end

        local Tab={}
        function Tab:AddButton(text,cb)
            local bt=Create("TextButton",{Parent=p,Size=UDim2.new(1,-10,0,42),Text=text,BackgroundColor3=Theme.Dark,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
            Create("UICorner",{Parent=bt})
            local outline=Create("UIStroke",{Parent=bt,Color=Theme.Muted,Thickness=1})
            table.insert(Registry,bt)
            bt.MouseEnter:Connect(function() Tween(bt,{0.15,Enum.EasingStyle.Quad},{BackgroundColor3=Theme.Accent}) end)
            bt.MouseLeave:Connect(function() Tween(bt,{0.15,Enum.EasingStyle.Quad},{BackgroundColor3=Theme.Dark}) end)
            bt.MouseButton1Click:Connect(function() Tween(bt,{0.2,Enum.EasingStyle.Elastic},{Size=UDim2.new(1,-5,0,40)}) cb() task.delay(0.1,function() Tween(bt,{0.2,Enum.EasingStyle.Elastic},{Size=UDim2.new(1,-10,0,42)}) end) end)
        end

        function Tab:AddToggle(text,flag,def,cb)
            local s=def
            local t=Create("TextButton",{Parent=p,Size=UDim2.new(1,-10,0,42),Text=text..": "..(s and "ON" or "OFF"),BackgroundColor3=s and Theme.Accent or Theme.Dark,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
            Create("UICorner",{Parent=t})
            Create("UIStroke",{Parent=t,Color=Theme.Muted,Thickness=1})
            Flags[flag]={Get=function()return s end,Set=function(v)s=v t.Text=text..": "..(s and "ON" or "OFF") cb(s) end}
            table.insert(Registry,t)
            t.MouseButton1Click:Connect(function()
                s=not s
                t.Text=text..": "..(s and "ON" or "OFF")
                Tween(t,{.2,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out},{BackgroundColor3=s and Theme.Accent or Theme.Dark})
                cb(s)
            end)
        end

        function Tab:AddSlider(text,min,max,def,cb)
            local frame=Create("Frame",{Parent=p,Size=UDim2.new(1,-10,0,42),BackgroundColor3=Theme.Dark})
            Create("UICorner",{Parent=frame})
            Create("UIStroke",{Parent=frame,Color=Theme.Muted,Thickness=1})
            local label=Create("TextLabel",{Parent=frame,Size=UDim2.new(1,0,0,20),Text=text.." : "..def,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14,BackgroundTransparency=1,TextXAlignment=Left})
            local bar=Create("Frame",{Parent=frame,Size=UDim2.new(1,-10,0,8),Position=UDim2.new(0,5,0,25),BackgroundColor3=Theme.Muted})
            Create("UICorner",{Parent=bar})
            local thumb=Create("Frame",{Parent=bar,Size=UDim2.new((def-min)/(max-min),1,1,0),BackgroundColor3=Theme.Accent})
            Create("UICorner",{Parent=thumb})
            local dragging=false
            thumb.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                    dragging=true
                    input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    thumb.Size=UDim2.new(pos,0,1,0)
                    local value = math.floor(pos*(max-min)+min)
                    label.Text=text.." : "..value
                    cb(value)
                end
            end)
        end

        function Tab:AddDropdown(text,options,cb)
            local frame=Create("Frame",{Parent=p,Size=UDim2.new(1,-10,0,42),BackgroundColor3=Theme.Dark})
            Create("UICorner",{Parent=frame})
            Create("UIStroke",{Parent=frame,Color=Theme.Muted,Thickness=1})
            local btn=Create("TextButton",{Parent=frame,Size=UDim2.new(1,0,1,0),Text=text.." ▼",BackgroundTransparency=1,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
            local dropdown=Create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,#options*30),Position=UDim2.new(0,0,1,0),BackgroundColor3=Theme.Dark,Visible=false})
            Create("UICorner",{Parent=dropdown})
            local layout=Create("UIListLayout",{Parent=dropdown})
            for _,v in ipairs(options) do
                local opt=Create("TextButton",{Parent=dropdown,Size=UDim2.new(1,0,0,30),Text=v,BackgroundTransparency=1,TextColor3=Theme.Text,Font=Enum.Font.Gotham,TextSize=14})
                opt.MouseButton1Click:Connect(function() btn.Text=text.." : "..v dropdown.Visible=false cb(v) end)
            end
            btn.MouseButton1Click:Connect(function() dropdown.Visible=not dropdown.Visible end)
        end

        return Tab
    end

    return Window
end

return TobaHub
