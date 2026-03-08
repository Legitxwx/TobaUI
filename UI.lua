local cloneref = (cloneref or clonereference or function(x) return x end)
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local function safeGet(url)
    if not url then return nil end
    if writefile and game.HttpGet then
        local ok,res = pcall(function() return game:HttpGet(url) end)
        if ok then return res end
    end
    local ok2,res2 = pcall(function() return HttpService:GetAsync(url) end)
    if ok2 then return res2 end
    return nil
end

local IconModule = rawget(_G, "IconModule") or rawget(game, "IconModule") or IconModule
if not IconModule then
    IconModule = {
        IconsType = "lucide",
        Image = function() return { IconFrame = Instance.new("ImageLabel") } end,
        Icon = function() return nil end,
        Icon2 = function() return nil end,
        Init = function() return IconModule end,
        SetIconsType = function() end
    }
end

local Toba = {}
Toba.__index = Toba

Toba.Config = {
    Name = "TobaUI",
    SaveFolder = "TobaConfigs",
    DefaultTheme = "dark",
    Font = Enum.Font.GothamSemibold,
    Accent = Color3.fromRGB(255,85,95),
    AutoSave = true,
    AutoSaveInterval = 30,
}

local Themes = {
    dark = {
        Background = Color3.fromRGB(18,18,20),
        Panel = Color3.fromRGB(28,28,34),
        Accent = Toba.Config.Accent,
        Text = Color3.fromRGB(235,235,240),
        SubText = Color3.fromRGB(160,160,170),
        Muted = Color3.fromRGB(70,70,80),
    },
    light = {
        Background = Color3.fromRGB(250,250,252),
        Panel = Color3.fromRGB(255,255,255),
        Accent = Color3.fromRGB(0,120,255),
        Text = Color3.fromRGB(20,20,20),
        SubText = Color3.fromRGB(100,100,110),
        Muted = Color3.fromRGB(220,220,225),
    }
}

local function detectExecutor()
    local name = "Unknown"
    if syn then name = "Synapse X" end
    if KRNL_LOADED then name = "KRNL" end
    if is_sirhurt_closure then name = "SirHurt" end
    if identifyexecutor then
        local ok, res = pcall(function() return identifyexecutor() end)
        if ok and res then name = res end
    end
    return {
        Name = name,
        Flags = {
            syn = syn and true or nil,
            krnl = KRNL_LOADED and true or nil,
            sirhurt = is_sirhurt_closure and true or nil
        }
    }
end

Toba.Executor = detectExecutor()

local function tween(obj, props, t, style, dir)
    t = tonumber(t) or 0.18
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    pcall(function()
        local ti = TweenInfo.new(t, style, dir)
        local tw = TweenService:Create(obj, ti, props)
        tw:Play()
    end)
end

local function clamp(n, a, b) return math.max(a, math.min(b, n)) end

local function applyUICorner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 10)
    c.Parent = inst
    return c
end

local function createLabel(parent, text, size, color, align)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.Font = Toba.Config.Font
    l.TextSize = 14
    l.Text = text or ""
    l.TextColor3 = color or Themes.dark.Text
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function parseIcon(name)
    if not name then return nil end
    if type(name) == "string" then
        local iconName = name
        return IconModule.Image({Icon = iconName, Type = IconModule.IconsType, Size = UDim2.new(0,20,0,20)})
    end
    return nil
end

local function removeExisting(name)
    local existing = CoreGui:FindFirstChild(name)
    if existing then pcall(function() existing:Destroy() end) end
end

local function safeWrite(path, data)
    if writefile then
        local full = (Toba.Config.SaveFolder .. "/" .. path .. ".json")
        pcall(function() writefile(full, data) end)
        return true
    end
    return false
end
local function safeRead(path)
    if readfile then
        local full = (Toba.Config.SaveFolder .. "/" .. path .. ".json")
        local ok, res = pcall(function() return readfile(full) end)
        if ok then return res end
    end
    return nil
end

local function absoluteCanvasUpdate(list, scroll)
    local ok = pcall(function()
        scroll.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y + 12)
    end)
    return ok
end

local function makeScreen(name)
    local sg = Instance.new("ScreenGui")
    sg.Name = name
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui
    return sg
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1,40,1,40)
    shadow.Position = UDim2.new(0,-20,0,-20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://284186778" -- subtle shadow asset fallback
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.9
    shadow.ZIndex = 0
    shadow.Parent = parent
    return shadow
end

-- Window factory
function Toba.CreateWindow(opts)
    opts = opts or {}
    removeExisting(Toba.Config.Name)
    local themeName = opts.Theme or Toba.Config.DefaultTheme
    local theme = Themes[themeName] or Themes.dark
    local sg = makeScreen(Toba.Config.Name)
    local main = Instance.new("Frame")
    main.Name = "Toba_Main"
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.Size = opts.Size or UDim2.new(0,920,0,680)
    main.Position = UDim2.new(0.5,0.5,0.5,0)
    main.BackgroundColor3 = theme.Panel
    main.BorderSizePixel = 0
    main.Parent = sg
    applyUICorner(main, UDim.new(0,18))
    createShadow(main)

    -- header
    local header = Instance.new("Frame"); header.Size = UDim2.new(1,0,0,64); header.Position = UDim2.new(0,0,0,0); header.BackgroundTransparency = 1; header.Parent = main
    local iconCont = Instance.new("Frame"); iconCont.Size = UDim2.new(0,56,0,56); iconCont.Position = UDim2.new(0,12,0,4); iconCont.BackgroundTransparency = 1; iconCont.Parent = header
    local title = createLabel(header, opts.Title or "Toba", UDim2.new(0.6,0,0,28), theme.Text, Enum.TextXAlignment.Left); title.Position = UDim2.new(0,80,0,6)
    title.TextSize = 20
    local subtitle = createLabel(header, opts.Subtitle or "", UDim2.new(0.6,0,0,18), theme.SubText, Enum.TextXAlignment.Left); subtitle.Position = UDim2.new(0,80,0,32)
    local controls = Instance.new("Frame"); controls.Size = UDim2.new(0,148,0,64); controls.Position = UDim2.new(1,-156,0,0); controls.BackgroundTransparency = 1; controls.Parent = header

    local btnMin = Instance.new("TextButton"); btnMin.Size = UDim2.new(0,40,0,40); btnMin.Position = UDim2.new(0,8,0,12); btnMin.Text="—"; btnMin.Font=Toba.Config.Font; btnMin.TextSize=18; btnMin.BackgroundColor3=theme.Panel; btnMin.TextColor3=theme.Text; btnMin.Parent=controls; applyUICorner(btnMin, UDim.new(0,10))
    local btnLock = Instance.new("TextButton"); btnLock.Size=UDim2.new(0,40,0,40); btnLock.Position=UDim2.new(0,56,0,12); btnLock.Text="🔒"; btnLock.Font=Toba.Config.Font; btnLock.TextSize=18; btnLock.BackgroundColor3=theme.Panel; btnLock.TextColor3=theme.Text; btnLock.Parent=controls; applyUICorner(btnLock, UDim.new(0,10))
    local btnClose = Instance.new("TextButton"); btnClose.Size=UDim2.new(0,40,0,40); btnClose.Position=UDim2.new(0,104,0,12); btnClose.Text="✕"; btnClose.Font=Toba.Config.Font; btnClose.TextSize=18; btnClose.BackgroundColor3=theme.Panel; btnClose.TextColor3=theme.Text; btnClose.Parent=controls; applyUICorner(btnClose, UDim.new(0,10))

    -- left tabs list
    local left = Instance.new("Frame"); left.Size = UDim2.new(0,220,1,-104); left.Position = UDim2.new(0,12,0,88); left.BackgroundColor3 = theme.Panel; left.Parent = main; applyUICorner(left, UDim.new(0,12))
    local leftList = Instance.new("UIListLayout"); leftList.Padding = UDim.new(0,8); leftList.HorizontalAlignment = Enum.HorizontalAlignment.Left; leftList.Parent = left

    local tabIndicator = Instance.new("Frame"); tabIndicator.Size = UDim2.new(1,0,0,4); tabIndicator.Position = UDim2.new(0,0,0,0); tabIndicator.BackgroundColor3 = theme.Accent; tabIndicator.ZIndex = 2; tabIndicator.Parent = left

    -- content
    local content = Instance.new("Frame"); content.Size = UDim2.new(1,-260,1,-104); content.Position = UDim2.new(0,244,0,88); content.BackgroundTransparency = 1; content.Parent = main
    local scroll = Instance.new("ScrollingFrame"); scroll.Name="TobaScroll"; scroll.Size = UDim2.new(1,0,1,0); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ScrollBarThickness=8; scroll.Parent = content
    local contentList = Instance.new("UIListLayout"); contentList.Padding = UDim.new(0,12); contentList.Parent = scroll

    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() absoluteCanvasUpdate(contentList, scroll) end)

    -- footer
    local footer = Instance.new("Frame"); footer.BackgroundTransparency = 1; footer.Size = UDim2.new(1,-24,0,36); footer.Position = UDim2.new(0,12,1,-44); footer.Parent = main
    local footerLabel = createLabel(footer, string.format("%s • v%s • %s", opts.Author or "Unknown", opts.Version or "0.0", (opts.ExecutorDisplay and Toba.Executor.Name) or ""), UDim2.new(1,0,1,0), theme.SubText, Enum.TextXAlignment.Left)
    footerLabel.Position = UDim2.new(0,6,0,0)

    -- floating toggle
    local float = Instance.new("TextButton"); float.Size=UDim2.new(0,64,0,64); float.Position=UDim2.new(1,-96,1,-176); float.AnchorPoint=Vector2.new(0,0); float.BackgroundColor3=theme.Accent; float.Text=""; float.ZIndex=1000; float.Parent = sg
    applyUICorner(float, UDim.new(0,32))
    local floatIcon = Instance.new("ImageLabel"); floatIcon.Size = UDim2.new(0,28,0,28); floatIcon.Position = UDim2.new(0.5,-14,0.5,-14); floatIcon.BackgroundTransparency = 1; floatIcon.Parent = float

    -- object
    local win = {
        ScreenGui = sg,
        Main = main,
        Header = header,
        Left = left,
        LeftList = leftList,
        Content = content,
        Scroll = scroll,
        ContentList = contentList,
        Tabs = {},
        Theme = theme,
        Props = opts,
        Locked = opts.Locked or false,
        Minimized = false,
        Float = float,
        FloatIcon = floatIcon,
        Configs = {},
    }

    -- set icon if provided
    if opts.Icon then
        local ok, icon = pcall(function() return parseIcon(opts.Icon) end)
        if ok and icon and icon.IconFrame then
            icon.IconFrame.Size = UDim2.new(0,44,0,44)
            icon.IconFrame.Position = UDim2.new(0,8,0,10)
            icon.IconFrame.Parent = header
        end
    end

    -- dragging
    do
        local dragging=false; local startPos; local startMouse
        local function begin(input)
            if win.Locked then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging=true; startPos = win.Main.Position; startMouse = input.Position
        end
        local function delta(input)
            if not dragging then return end
            local d = input.Position - startMouse
            win.Main.Position = UDim2.new(0, startPos.X.Offset + d.X, 0, startPos.Y.Offset + d.Y)
        end
        local function stop(input)
            dragging=false
        end
        win.Header.InputBegan:Connect(begin)
        UserInputService.InputChanged:Connect(delta)
        UserInputService.InputEnded:Connect(stop)
    end

    -- floating drag & click
    do
        local df=false; local startP; local startMouse; local downTick
        local function begin(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            df=true; startP = win.Float.Position; startMouse = input.Position; downTick = tick()
        end
        local function move(input)
            if not df then return end
            local d = input.Position - startMouse
            local pos = startP + UDim2.new(0, d.X, 0, d.Y)
            local screen = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1366,768)
            local x = clamp(pos.X.Offset, 0, screen.X - win.Float.AbsoluteSize.X)
            local y = clamp(pos.Y.Offset, 0, screen.Y - win.Float.AbsoluteSize.Y)
            win.Float.Position = UDim2.new(0, x, 0, y)
        end
        local function stop(input)
            if not df then return end
            df=false
            local dt = tick() - downTick
            if dt < 0.18 then win:ToggleVisibility() end
        end
        win.Float.InputBegan:Connect(begin)
        UserInputService.InputChanged:Connect(move)
        UserInputService.InputEnded:Connect(stop)
    end

    -- controls behavior
    btnMin.MouseButton1Click:Connect(function() win:ToggleMinimize() end)
    btnClose.MouseButton1Click:Connect(function() win:ToggleVisibility() end)
    btnLock.MouseButton1Click:Connect(function() win:ToggleLock() end)

    -- tab creation
    function win:AddTab(info)
        info = info or {}
        local idx = #win.Tabs + 1
        local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,-16,0,56); btn.BackgroundTransparency = 1; btn.AutoButtonColor = false; btn.Text=""; btn.LayoutOrder = idx; btn.Parent = win.Left
        local tIconCont = Instance.new("Frame"); tIconCont.Size = UDim2.new(0,44,0,44); tIconCont.Position = UDim2.new(0,8,0,6); tIconCont.BackgroundTransparency = 1; tIconCont.Parent = btn
        applyUICorner(tIconCont, UDim.new(0,10))
        local tLabel = createLabel(btn, info.Title or ("Tab "..idx), UDim2.new(1,-72,1,0), win.Theme.Text, Enum.TextXAlignment.Left); tLabel.Position = UDim2.new(0,64,0,0); tLabel.Font = Toba.Config.Font; tLabel.TextSize = 16

        if info.Icon then
            local ok, icon = pcall(function() return parseIcon(info.Icon) end)
            if ok and icon and icon.IconFrame then
                icon.IconFrame.Size = UDim2.new(0,20,0,20); icon.IconFrame.Position = UDim2.new(0,16,0,16); icon.IconFrame.Parent = btn
            end
        end

        local page = Instance.new("Frame"); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.LayoutOrder = idx; page.Visible = (#win.Tabs==0)
        page.Parent = win.Scroll
        local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0,12); list.Parent = page

        local tabObj = {
            Index = idx,
            Button = btn,
            Label = tLabel,
            Page = page,
            Sections = {},
        }

        btn.MouseButton1Click:Connect(function()
            for i,v in pairs(win.Tabs) do v.Page.Visible = false; tween(v.Button, {BackgroundTransparency = 1}, 0.16) end
            page.Visible = true
            tween(btn, {BackgroundTransparency = 0}, 0.16)
            tween(win.Left, {CanvasPosition = Vector2.new(0, (idx-1)*64)}, 0.28)
            local y = (idx-1) * (btn.AbsoluteSize.Y + 8)
            tween(win.Left, {Position = win.Left.Position}, 0.18)
            tween(win.Left, {}, 0.18)
            tween(win.Left, {}, 0.18)
            tween(win.Left, {}, 0.18)
            tween(win.Left, {}, 0.18)
        end)

        function tabObj:AddSection(sectionInfo)
            sectionInfo = sectionInfo or {}
            local sect = Instance.new("Frame"); sect.Size = UDim2.new(1,0,0,20); sect.BackgroundTransparency = 1; sect.Parent = page
            local sHeader = createLabel(sect, sectionInfo.Title or "Section", UDim2.new(1,0,0,20), win.Theme.Text); sHeader.Font = Toba.Config.Font; sHeader.TextSize = 16
            local container = Instance.new("Frame"); container.Size = UDim2.new(1,0,0,8); container.Position = UDim2.new(0,0,0,28); container.BackgroundTransparency = 1; container.Parent = sect
            local cl = Instance.new("UIListLayout"); cl.Parent = container; cl.Padding = UDim.new(0,8)
            cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sect.Size = UDim2.new(1,0,0, 36 + cl.AbsoluteContentSize.Y) absoluteCanvasUpdate(win.ContentList, win.Scroll) end)

            local section = { Frame = sect, Container = container, List = cl }

            -- elements
            function section:Button(opts)
                opts = opts or {}
                local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,44); b.Text = opts.Text or "Button"; b.Font = Toba.Config.Font; b.TextSize = 14; b.TextColor3 = win.Theme.Text; b.BackgroundColor3 = win.Theme.Panel; b.Parent = container
                applyUICorner(b, UDim.new(0,10))
                b.MouseButton1Click:Connect(function()
                    tween(b, {Position = UDim2.new(b.Position.X.Scale, b.Position.X.Offset, b.Position.Y.Scale, b.Position.Y.Offset+2)}, 0.06)
                    task.wait(0.06)
                    tween(b, {Position = UDim2.new(b.Position.X.Scale, b.Position.X.Offset, b.Position.Y.Scale, b.Position.Y.Offset-2)}, 0.06)
                    if opts.Callback then pcall(opts.Callback) end
                end)
                return b
            end

            function section:Toggle(opts)
                opts = opts or {}
                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,36); f.BackgroundTransparency = 1; f.Parent = container
                local label = createLabel(f, opts.Text or "Toggle", UDim2.new(1,-64,1,0), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local sw = Instance.new("Frame"); sw.Size = UDim2.new(0,48,0,26); sw.Position = UDim2.new(1,-56,0,5); sw.BackgroundColor3 = win.Theme.Muted; sw.Parent = f; applyUICorner(sw, UDim.new(0,12))
                local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,22,0,22); knob.Position = UDim2.new(1,-26,0,2); knob.BackgroundColor3 = win.Theme.Panel; knob.Parent = sw; applyUICorner(knob, UDim.new(0,10))
                local state = opts.Default == true
                local function set(s, noCb)
                    state = s
                    if s then tween(knob, {Position = UDim2.new(0,4,0,2)}, 0.16); tween(sw, {BackgroundColor3 = win.Theme.Accent}, 0.16) else tween(knob, {Position = UDim2.new(1,-26,0,2)}, 0.16); tween(sw, {BackgroundColor3 = win.Theme.Muted}, 0.16) end
                    if not noCb and opts.Callback then pcall(opts.Callback, state) end
                end
                sw.InputBegan:Connect(function() set(not state) end)
                set(state, true)
                return { Set = set, Get = function() return state end }
            end

            function section:Slider(opts)
                opts = opts or {}
                local min = opts.Min or 0
                local max = opts.Max or 100
                local step = opts.Step or 1
                local def = clamp(opts.Default or min, min, max)
                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,52); f.BackgroundTransparency = 1; f.Parent = container
                local label = createLabel(f, opts.Text or "Slider", UDim2.new(1,-64,0,18), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local valL = createLabel(f, tostring(def), UDim2.new(0,56,0,18), win.Theme.SubText, Enum.TextXAlignment.Right); valL.Position = UDim2.new(1,-56,0,0)
                local bar = Instance.new("Frame"); bar.Size = UDim2.new(1,0,0,12); bar.Position = UDim2.new(0,0,0,28); bar.BackgroundColor3 = win.Theme.Muted; bar.Parent = f; applyUICorner(bar, UDim.new(0,8))
                local fill = Instance.new("Frame"); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = win.Theme.Accent; fill.Parent = bar; applyUICorner(fill, UDim.new(0,8))
                local dragging=false
                local function update(x)
                    local absX = clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                    local p = absX / bar.AbsoluteSize.X
                    local v = min + (max-min)*p
                    v = math.floor(v/step + 0.5) * step
                    fill.Size = UDim2.new((v-min)/(max-min),0,1,0)
                    valL.Text = tostring(v)
                    if opts.Callback then pcall(opts.Callback, v) end
                end
                bar.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging=true; update(inp.Position.X) end end)
                bar.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging=false end end)
                UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end end)
                return { Get = function() return tonumber(valL.Text) end, Set = function(v) v = clamp(v,min,max); fill.Size = UDim2.new((v-min)/(max-min),0,1,0); valL.Text = tostring(v); if opts.Callback then pcall(opts.Callback,v) end end }
            end

            function section:Textbox(opts)
                opts = opts or {}
                local box = Instance.new("TextBox"); box.Size = UDim2.new(1,0,0,36); box.PlaceholderText = opts.Placeholder or ""; box.Text = ""; box.Font = Toba.Config.Font; box.TextSize = 14; box.TextColor3 = win.Theme.Text; box.BackgroundColor3 = win.Theme.Panel; box.Parent = container; applyUICorner(box, UDim.new(0,10))
                box.FocusLost:Connect(function(enter) if enter and opts.Callback then pcall(opts.Callback, box.Text) end end)
                return box
            end

            function section:Dropdown(opts)
                opts = opts or {}
                local frame = Instance.new("Frame"); frame.Size=UDim2.new(1,0,0,36); frame.BackgroundTransparency=1; frame.Parent = container
                local label = createLabel(frame, opts.Text or "Dropdown", UDim2.new(1,-36,1,0), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local arrow = createLabel(frame, "▾", UDim2.new(0,36,1,0), win.Theme.SubText, Enum.TextXAlignment.Center); arrow.Position = UDim2.new(1,-36,0,0)
                local menu = Instance.new("Frame"); menu.Size = UDim2.new(1,0,0,0); menu.Position = UDim2.new(0,0,0,36); menu.BackgroundColor3 = win.Theme.Panel; menu.Visible = false; menu.Parent = frame; applyUICorner(menu, UDim.new(0,8))
                local ml = Instance.new("UIListLayout"); ml.Parent = menu; ml.Padding = UDim.new(0,4)
                local selection = opts.Default
                local function rebuild()
                    for i,v in pairs(menu:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for i,opt in ipairs(opts.Options or {}) do
                        local it = Instance.new("TextButton"); it.Size=UDim2.new(1,-8,0,28); it.Position = UDim2.new(0,4,0,(i-1)*32); it.Text = tostring(opt); it.Font = Toba.Config.Font; it.TextColor3 = win.Theme.Text; it.BackgroundTransparency = 1; it.Parent = menu
                        it.MouseButton1Click:Connect(function() selection = opt; label.Text = (opts.Text or "Dropdown") .. " - " .. tostring(selection); menu.Visible = false; if opts.Callback then pcall(opts.Callback, selection) end end)
                    end
                    menu.Size = UDim2.new(1,0,0, ml.AbsoluteContentSize.Y + 8)
                end
                frame.InputBegan:Connect(function() menu.Visible = not menu.Visible end)
                rebuild()
                return { Get = function() return selection end, Set = function(v) selection = v; label.Text = (opts.Text or "Dropdown").." - "..tostring(v) end, Refresh = rebuild }
            end

            function section:MultiDropdown(opts)
                opts = opts or {}
                local selected = {}
                local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,36); frame.BackgroundTransparency = 1; frame.Parent = container
                local label = createLabel(frame, opts.Text or "Multi", UDim2.new(1,-36,1,0), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local arrow = createLabel(frame, "▾", UDim2.new(0,36,1,0), win.Theme.SubText, Enum.TextXAlignment.Center); arrow.Position=UDim2.new(1,-36,0,0)
                local menu = Instance.new("Frame"); menu.Size = UDim2.new(1,0,0,0); menu.Position = UDim2.new(0,0,0,36); menu.BackgroundColor3 = win.Theme.Panel; menu.Visible=false; menu.Parent = frame; applyUICorner(menu, UDim.new(0,8))
                local search = Instance.new("TextBox"); search.Size = UDim2.new(1,0,0,32); search.PlaceholderText = "Search..."; search.BackgroundTransparency = 1; search.Font = Toba.Config.Font; search.TextSize=14; search.Parent = menu
                local list = Instance.new("Frame"); list.Size = UDim2.new(1,0,0,0); list.Position = UDim2.new(0,0,0,36); list.BackgroundTransparency = 1; list.Parent = menu
                local ml = Instance.new("UIListLayout"); ml.Parent = list; ml.Padding=UDim.new(0,6)
                local function build(filter)
                    for i,v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for i,opt in ipairs(opts.Options or {}) do
                        if (not filter) or tostring(opt):lower():find(filter:lower()) then
                            local it = Instance.new("TextButton"); it.Size=UDim2.new(1,-12,0,30); it.BackgroundTransparency=1; it.Text = tostring(opt); it.Font = Toba.Config.Font; it.TextColor3 = win.Theme.Text; it.Parent = list
                            local chk = Instance.new("TextLabel"); chk.Size=UDim2.new(0,28,1,0); chk.Position = UDim2.new(1,-32,0,0); chk.BackgroundTransparency=1; chk.Text = (table.find(selected, opt) and "✓") or ""; chk.Font = Toba.Config.Font; chk.TextColor3 = win.Theme.Text; chk.Parent = it
                            it.MouseButton1Click:Connect(function()
                                if table.find(selected, opt) then
                                    for i=1,#selected do if selected[i]==opt then table.remove(selected,i); break end end
                                else table.insert(selected, opt) end
                                chk.Text = (table.find(selected,opt) and "✓") or ""
                                if opts.Callback then pcall(opts.Callback, selected) end
                                label.Text = (opts.Text or "Multi") .. " - " .. (#selected==0 and "None" or tostring(#selected).." selected")
                            end)
                        end
                    end
                    menu.Size = UDim2.new(1,0,0, 40 + ml.AbsoluteContentSize.Y)
                end
                search:GetPropertyChangedSignal("Text"):Connect(function() build(search.Text) end)
                frame.InputBegan:Connect(function() menu.Visible = not menu.Visible; if menu.Visible then build("") end end)
                build("")
                return { Get = function() return selected end, Set = function(t) selected = t; if opts.Callback then pcall(opts.Callback, selected) end end }
            end

            function section:Keybind(opts)
                opts = opts or {}
                local bind = opts.Default or Enum.KeyCode.F
                local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,36); frame.BackgroundTransparency=1; frame.Parent = container
                local label = createLabel(frame, opts.Text or "Keybind", UDim2.new(1,-120,1,0), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local bindBtn = Instance.new("TextButton"); bindBtn.Size = UDim2.new(0,120,1,0); bindBtn.Position = UDim2.new(1,-124,0,0); bindBtn.Text = tostring(bind); bindBtn.Font = Toba.Config.Font; bindBtn.Parent = frame; applyUICorner(bindBtn, UDim.new(0,8))
                local listening = false
                local conn
                bindBtn.MouseButton1Click:Connect(function()
                    listening = true; bindBtn.Text = "Press Key..."
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.KeyCode then
                            bind = input.KeyCode; bindBtn.Text = tostring(bind); listening = false
                            if conn then conn:Disconnect() end
                            if opts.Callback then pcall(opts.Callback, bind) end
                        end
                    end)
                end)
                return { Get = function() return bind end, Set = function(k) bind = k; bindBtn.Text = tostring(k) end }
            end

            function section:ColorPicker(opts)
                opts = opts or {}
                local default = opts.Default or win.Theme.Accent
                local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,48); frame.BackgroundTransparency=1; frame.Parent = container
                local label = createLabel(frame, opts.Text or "Color", UDim2.new(1,-56,0,18), win.Theme.Text); label.Position = UDim2.new(0,0,0,0)
                local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0,36,0,36); sw.Position = UDim2.new(1,-44,0,6); sw.BackgroundColor3 = default; sw.Parent = frame; applyUICorner(sw, UDim.new(0,8))
                local picker = Instance.new("Frame"); picker.Size = UDim2.new(0,220,0,160); picker.Position = UDim2.new(0,0,0,48); picker.BackgroundColor3 = win.Theme.Panel; picker.Visible=false; picker.Parent = frame; applyUICorner(picker, UDim.new(0,10))
                local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.new(0,24,0,24); grid.CellPadding = UDim2.new(0,8,0,8); grid.Parent = picker
                local presets = {
                    Color3.fromRGB(255,85,95), Color3.fromRGB(255,140,50), Color3.fromRGB(255,220,80),
                    Color3.fromRGB(120,200,80), Color3.fromRGB(0,160,255), Color3.fromRGB(150,100,255),
                    Color3.fromRGB(255,255,255), Color3.fromRGB(30,30,30)
                }
                for i,c in ipairs(presets) do
                    local p = Instance.new("TextButton"); p.Size = UDim2.new(0,24,0,24); p.BackgroundColor3 = c; p.Text=""; p.Parent = picker; applyUICorner(p, UDim.new(0,6))
                    p.MouseButton1Click:Connect(function() sw.BackgroundColor3 = c; picker.Visible=false; if opts.Callback then pcall(opts.Callback,c) end end)
                end
                sw.MouseButton1Click:Connect(function() picker.Visible = not picker.Visible end)
                return { Get = function() return sw.BackgroundColor3 end, Set = function(c) sw.BackgroundColor3 = c; if opts.Callback then pcall(opts.Callback,c) end end }
            end

            function section:Progress(opts)
                opts=opts or {}
                local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,36); frame.BackgroundTransparency=1; frame.Parent = container
                local bar = Instance.new("Frame"); bar.Size = UDim2.new(1,0,0,12); bar.Position = UDim2.new(0,0,0,18); bar.BackgroundColor3 = win.Theme.Muted; bar.Parent = frame; applyUICorner(bar, UDim.new(0,6))
                local fill = Instance.new("Frame"); fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = win.Theme.Accent; fill.Parent = bar; applyUICorner(fill, UDim.new(0,6))
                local pct = createLabel(frame, "0%", UDim2.new(1,-12,0,18), win.Theme.SubText, Enum.TextXAlignment.Right); pct.Position = UDim2.new(0,6,0,0)
                return { Set = function(v) v = clamp(v,0,100); fill:TweenSize(UDim2.new(v/100,0,1,0),"Out","Quad",0.28,true); pct.Text = tostring(math.floor(v)).."%"; if opts.Callback then pcall(opts.Callback,v) end end }
            end

            function section:Paragraph(text)
                local p = createLabel(container, text or "", UDim2.new(1,0,0,36), win.Theme.SubText); p.TextWrapped = true; p.Size = UDim2.new(1,0,0, math.max(36, p.TextBounds.Y + 12)); return p
            end

            function section:Divider()
                local d = Instance.new("Frame"); d.Size = UDim2.new(1,0,0,2); d.BackgroundColor3 = win.Theme.Muted; d.Parent = container; applyUICorner(d, UDim.new(0,4)); return d
            end

            function section:Search(opts)
                opts = opts or {}
                local frame = Instance.new("Frame"); frame.Size = UDim2.new(1,0,0,36); frame.BackgroundTransparency = 1; frame.Parent = container
                local box = Instance.new("TextBox"); box.Size = UDim2.new(1,0,0,36); box.PlaceholderText = opts.Placeholder or "Search..."; box.BackgroundColor3 = win.Theme.Panel; box.Font = Toba.Config.Font; box.TextSize=14; box.Parent = frame; applyUICorner(box, UDim.new(0,10))
                box:GetPropertyChangedSignal("Text"):Connect(function() if opts.Callback then pcall(opts.Callback, box.Text) end end)
                return box
            end

            function section:Expandable(title)
                local header = Instance.new("TextButton"); header.Size = UDim2.new(1,0,0,34); header.Text = " " .. (title or "Expandable"); header.Font = Toba.Config.Font; header.TextColor3 = win.Theme.Text; header.BackgroundColor3 = win.Theme.Panel; header.Parent = container; applyUICorner(header, UDim.new(0,10))
                local content = Instance.new("Frame"); content.Size = UDim2.new(1,0,0,0); content.BackgroundTransparency = 1; content.Parent = container
                local cl = Instance.new("UIListLayout"); cl.Parent = content; cl.Padding = UDim.new(0,8)
                local open = false
                header.MouseButton1Click:Connect(function()
                    open = not open
                    if open then tween(content, {Size = UDim2.new(1,0,0, cl.AbsoluteContentSize.Y)}, 0.28) else tween(content, {Size = UDim2.new(1,0,0,0)}, 0.28) end
                end)
                return { Header = header, Content = content, List = cl }
            end

            table.insert(tabObj.Sections, section)
            return section
        end

        table.insert(win.Tabs, tabObj)
        return tabObj
    end

    -- visibility/minimize/lock
    function win:ToggleVisibility()
        local visible = self.ScreenGui.Enabled
        if visible then
            tween(self.Main, {Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset, 0.5, 80)}, 0.28)
            task.delay(0.28, function() self.ScreenGui.Enabled = false end)
        else
            self.ScreenGui.Enabled = true
            tween(self.Main, {Position = UDim2.new(0.5,0,0.5,0)}, 0.28)
        end
    end
    function win:ToggleMinimize()
        self.Minimized = not self.Minimized
        if self.Minimized then tween(self.Main, {Size = UDim2.new(0,420,0,84)}, 0.28); self.Scroll.Visible = false else tween(self.Main, {Size = self.Props.Size or UDim2.new(0,920,0,680)}, 0.28); self.Scroll.Visible = true end
    end
    function win:ToggleLock()
        self.Locked = not self.Locked
        btnLock.Text = (self.Locked and "🔓") or "🔒"
    end

    function win:SetAccent(c)
        self.Theme.Accent = c
        tabIndicator.BackgroundColor3 = c
        win.Float.BackgroundColor3 = c
    end

    -- notifications
    function win:Notify(title, text, duration)
        duration = duration or 4
        local n = Instance.new("Frame"); n.Size = UDim2.new(0,320,0,84); n.AnchorPoint = Vector2.new(0.5,0); n.Position = UDim2.new(0.5,0,0.08,0); n.BackgroundColor3 = win.Theme.Panel; n.Parent = win.ScreenGui; applyUICorner(n, UDim.new(0,12))
        local t = createLabel(n, title, UDim2.new(1,-24,0,22), win.Theme.Text); t.Position = UDim2.new(0,12,0,8)
        local d = createLabel(n, text, UDim2.new(1,-24,0,44), win.Theme.SubText); d.Position = UDim2.new(0,12,0,30); d.TextWrapped = true
        tween(n, {Position = UDim2.new(0.5,0,0.06,0), Size = UDim2.new(0,320,0,84)}, 0.28)
        delay(duration, function() tween(n, {Position = UDim2.new(0.5,0,0.02,0), Size = UDim2.new(0,320,0,0)}, 0.28); task.wait(0.28); pcall(function() n:Destroy() end) end)
    end

    -- config save/load/export/import
    function win:SaveConfig(name)
        name = name or "default"
        local state = {
            Pos = {X = win.Main.Position.X.Offset, Y = win.Main.Position.Y.Offset},
            Size = {X = win.Main.Size.X.Offset, Y = win.Main.Size.Y.Offset},
            Theme = themeName,
            Accent = {R = win.Theme.Accent.R, G = win.Theme.Accent.G, B = win.Theme.Accent.B}
        }
        local encoded = HttpService:JSONEncode(state)
        if not safeWrite(name, encoded) then
            _G.TobaConfigs = _G.TobaConfigs or {}
            _G.TobaConfigs[name] = state
        end
    end

    function win:LoadConfig(name)
        name = name or "default"
        local raw = safeRead(name)
        local state
        if raw then pcall(function() state = HttpService:JSONDecode(raw) end) end
        if not state and _G.TobaConfigs then state = _G.TobaConfigs[name] end
        if state then
            if state.Accent then win:SetAccent(Color3.new(state.Accent.R, state.Accent.G, state.Accent.B)) end
            if state.Pos then win.Main.Position = UDim2.new(0, state.Pos.X, 0, state.Pos.Y) end
            if state.Size then win.Main.Size = UDim2.new(0, state.Size.X, 0, state.Size.Y) end
        end
    end

    function win:ExportConfig(name)
        name = name or "default"
        local raw = safeRead(name)
        if raw then return raw end
        if _G.TobaConfigs and _G.TobaConfigs[name] then return HttpService:JSONEncode(_G.TobaConfigs[name]) end
        return nil
    end

    function win:ImportConfig(json, name)
        name = name or "imported"
        local ok, state = pcall(function() return HttpService:JSONDecode(json) end)
        if ok and state then
            if not safeWrite(name, json) then _G.TobaConfigs = _G.TobaConfigs or {}; _G.TobaConfigs[name] = state end
            return true
        end
        return false
    end

    -- autosave loop
    if Toba.Config.AutoSave then
        spawn(function()
            while win and win.ScreenGui and win.ScreenGui.Parent do
                task.wait(Toba.Config.AutoSaveInterval)
                pcall(function() win:SaveConfig("autosave") end)
            end
        end)
    end

    table.insert(Toba, win)
    return win
end

-- return module
return {
    CreateWindow = Toba.CreateWindow,
    DetectExecutor = detectExecutor,
    IconModule = IconModule,
    Config = Toba.Config
}
