-- Toba Hub Library
local success, Toba = pcall(function()
    local TobaHub = {}
    TobaHub.__index = TobaHub

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function UICorner(obj,radius)
        local c = Instance.new("UICorner",obj)
        c.CornerRadius = UDim.new(0,radius or 12)
    end

    local function Tween(obj,props,t)
        TweenService:Create(obj,TweenInfo.new(t or 0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play()
    end

    local WindowClass = {}
    WindowClass.__index = WindowClass

    function WindowClass:Create(title,options)
        options = options or {}
        local logoId = options.Logo or ""
        local accent = options.Accent or Color3.fromRGB(105,125,255)
        local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

        local gui = Instance.new("ScreenGui",game.CoreGui)
        gui.Name = title.."Gui"
        gui.ResetOnSpawn=false

        local panel = Instance.new("Frame",gui)
        panel.Size = UDim2.fromScale(0,0)
        panel.Position = UDim2.fromScale(0.5,0.5)
        panel.AnchorPoint = Vector2.new(0.5,0.5)
        panel.BackgroundColor3 = Color3.fromRGB(24,24,34)
        panel.BorderSizePixel=0
        UICorner(panel,25)

        local gradient = Instance.new("UIGradient",panel)
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(32,32,48)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,28))
        }

        Tween(panel,{Size=UDim2.fromScale(0.7,0.6)},0.5)

        -- Draggable
        local dragging,dragInput,mousePos,framePos=false,nil,nil,nil
        local function updateDrag(input)
            local delta=input.Position-mousePos
            panel.Position=UDim2.new(panel.Position.X.Scale,framePos.X+delta.X,panel.Position.Y.Scale,framePos.Y+delta.Y)
        end
        panel.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                mousePos=input.Position
                framePos=panel.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        panel.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then updateDrag(dragInput) end
        end)

        -- Logo pulse
        if logoId~="" then
            local logo=Instance.new("ImageLabel",panel)
            logo.Size=UDim2.fromScale(0.15,0.15)
            logo.Position=UDim2.fromScale(0.05,0.05)
            logo.BackgroundTransparency=1
            logo.Image=logoId
            UICorner(logo,10)
            task.spawn(function()
                while logo.Parent do
                    Tween(logo,{Size=UDim2.fromScale(0.17,0.17)},1)
                    task.wait(1)
                    Tween(logo,{Size=UDim2.fromScale(0.15,0.15)},1)
                    task.wait(1)
                end
            end)
        end

        -- Tab Bar
        local tabBar=Instance.new("Frame",panel)
        tabBar.Size=UDim2.new(1,0,0,50)
        tabBar.Position=UDim2.fromScale(0,0)
        tabBar.BackgroundTransparency=1

        local tabs={}
        local pages={}

        local Window={}
        function Window:AddTab(name)
            local tabButton=Instance.new("TextButton",tabBar)
            tabButton.Size=UDim2.new(0,120,1,0)
            tabButton.Position=UDim2.new(#tabs*0.17,0,0,0)
            tabButton.Text=name
            tabButton.Font=Enum.Font.GothamBold
            tabButton.TextColor3=Color3.new(1,1,1)
            tabButton.TextScaled=true
            tabButton.BackgroundColor3=Color3.fromRGB(40,40,50)
            UICorner(tabButton,12)

            local pageFrame=Instance.new("Frame",panel)
            pageFrame.Size=UDim2.new(1,0,1,-50)
            pageFrame.Position=UDim2.fromScale(0,1)
            pageFrame.BackgroundTransparency=1
            pageFrame.Visible=false
            pages[#tabs+1]=pageFrame

            tabButton.MouseEnter:Connect(function() Tween(tabButton,{BackgroundColor3=accent},0.2) end)
            tabButton.MouseLeave:Connect(function() Tween(tabButton,{BackgroundColor3=Color3.fromRGB(40,40,50)},0.2) end)
            tabButton.MouseButton1Click:Connect(function()
                for i,p in pairs(pages) do p.Visible=(p==pageFrame) end
            end)

            local TabObj={}
            function TabObj:AddButton(text,callback)
                local btn=Instance.new("TextButton",pageFrame)
                btn.Size=UDim2.new(0.8,0,0,40)
                btn.Position=UDim2.fromScale(0.1,#pageFrame:GetChildren()*0.12)
                btn.Text=text
                btn.Font=Enum.Font.GothamBold
                btn.TextColor3=Color3.new(1,1,1)
                btn.TextScaled=true
                btn.BackgroundColor3=accent
                UICorner(btn,12)
                btn.MouseButton1Click:Connect(callback)
            end

            function TabObj:AddToggle(text,callback,default)
                local toggle=Instance.new("TextButton",pageFrame)
                toggle.Size=UDim2.new(0.8,0,0,40)
                toggle.Position=UDim2.fromScale(0.1,#pageFrame:GetChildren()*0.12)
                local state=default or false
                toggle.Text=text.." : "..(state and "ON" or "OFF")
                toggle.Font=Enum.Font.GothamBold
                toggle.TextColor3=Color3.new(1,1,1)
                toggle.TextScaled=true
                toggle.BackgroundColor3=accent
                UICorner(toggle,12)
                toggle.MouseButton1Click:Connect(function()
                    state=not state
                    toggle.Text=text.." : "..(state and "ON" or "OFF")
                    callback(state)
                end)
            end

            function TabObj:AddSlider(text,min,max,default,callback)
                local sliderFrame=Instance.new("Frame",pageFrame)
                sliderFrame.Size=UDim2.new(0.8,0,0,40)
                sliderFrame.Position=UDim2.fromScale(0.1,#pageFrame:GetChildren()*0.12)
                sliderFrame.BackgroundColor3=Color3.fromRGB(60,60,70)
                UICorner(sliderFrame,12)

                local label=Instance.new("TextLabel",sliderFrame)
                label.Size=UDim2.new(1,0,1,0)
                label.BackgroundTransparency=1
                label.TextColor3=Color3.new(1,1,1)
                label.Font=Enum.Font.GothamBold
                label.TextScaled=true
                label.Text=text.." : "..tostring(default)

                local mouseDown=false
                sliderFrame.InputBegan:Connect(function(input)
                    if input.UserInputType==Enum.UserInputType.MouseButton1 then mouseDown=true end
                end)
                sliderFrame.InputEnded:Connect(function(input)
                    if input.UserInputType==Enum.UserInputType.MouseButton1 then mouseDown=false end
                end)

                RunService.RenderStepped:Connect(function()
                    if mouseDown then
                        local mouse=LocalPlayer:GetMouse()
                        local pos=math.clamp((mouse.X-sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
                        local value=min+(max-min)*pos
                        label.Text=text.." : "..string.format("%.1f",value)
                        callback(value)
                    end
                end)
            end

            function TabObj:AddTextbox(placeholder,default,callback)
                local box=Instance.new("TextBox",pageFrame)
                box.Size=UDim2.new(0.8,0,0,40)
                box.Position=UDim2.fromScale(0.1,#pageFrame:GetChildren()*0.12)
                box.PlaceholderText=placeholder
                box.Text=default or ""
                box.Font=Enum.Font.GothamBold
                box.TextColor3=Color3.new(1,1,1)
                box.TextScaled=true
                box.BackgroundColor3=accent
                UICorner(box,12)
                box.FocusLost:Connect(function()
                    callback(box.Text)
                end)
            end

            function TabObj:AddParagraph(title,text)
                local frame=Instance.new("Frame",pageFrame)
                frame.Size=UDim2.new(0.8,0,0,80)
                frame.Position=UDim2.fromScale(0.1,#pageFrame:GetChildren()*0.12)
                frame.BackgroundColor3=Color3.fromRGB(40,40,50)
                UICorner(frame,12)

                local titleLabel=Instance.new("TextLabel",frame)
                titleLabel.Size=UDim2.new(1,0,0.3,0)
                titleLabel.BackgroundTransparency=1
                titleLabel.Text=title
                titleLabel.Font=Enum.Font.GothamBold
                titleLabel.TextColor3=Color3.new(1,1,1)
                titleLabel.TextScaled=true

                local contentLabel=Instance.new("TextLabel",frame)
                contentLabel.Size=UDim2.new(1,0,0.7,0)
                contentLabel.Position=UDim2.fromScale(0,0.3)
                contentLabel.BackgroundTransparency=1
                contentLabel.Text=text
                contentLabel.Font=Enum.Font.Gotham
                contentLabel.TextColor3=Color3.new(1,1,1)
                contentLabel.TextScaled=true
            end

            tabs[#tabs+1]=tabButton
            return TabObj
        end

        function Window:Show() panel.Visible=true end
        function Window:Hide() panel.Visible=false end
        function Window:Toggle() panel.Visible=not panel.Visible end

        -- Keybind to toggle UI
        UserInputService.InputBegan:Connect(function(input,gp)
            if input.KeyCode==toggleKey and not gp then
                Window:Toggle()
            end
        end)

        return Window
    end

    setmetatable(TobaHub,{__call=function(_,...) return WindowClass:Create(...) end})
    return TobaHub
end)

if not success then
    warn("Failed to load Toba Hub")
    return
end

return Toba
