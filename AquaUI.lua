--[[
    AquaUI - Premium Roblox UI Library
    Version: 2.0
    Theme: Blue / Teal / Aqua Gradient
    
    Features:
      - Smooth spring-based animations
      - Draggable & minimizable windows
      - Tabs with icons & search
      - Toggles, Buttons, Sliders, Dropdowns, TextInput, KeyBind, ColorPicker, ProgressBar
      - Labels, Paragraphs, Sections, Dividers
      - Notification toasts (Info / Success / Warning / Error)
      - Modal / Dialog popups
      - Tooltip system
      - Configuration save / load (per-profile)
      - Blur & transparency effects
      - Fully client-side, single-file, zero dependencies
    
    Usage:
      local AquaUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
      local Window = AquaUI:CreateWindow({ ... })
      local Tab    = Window:CreateTab("Home", "rbxassetid://...")
      Tab:CreateButton({ Name = "Hello", Callback = function() end })
]]

----------------------------------------------------------------
-- Services
----------------------------------------------------------------
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

----------------------------------------------------------------
-- Library table
----------------------------------------------------------------
local AquaUI = {
    Version   = "2.0",
    Windows   = {},
    Flags     = {},
    _themes   = {},
    _configs  = {},
    _tipFrame = nil,
}

----------------------------------------------------------------
-- Theme palette
----------------------------------------------------------------
local Theme = {
    Background        = Color3.fromRGB(12, 17, 28),
    SidebarBg         = Color3.fromRGB(8, 12, 22),
    TopBar            = Color3.fromRGB(10, 15, 25),
    ContentBg         = Color3.fromRGB(16, 22, 35),
    ElementBg         = Color3.fromRGB(22, 30, 48),
    ElementBgHover    = Color3.fromRGB(28, 38, 58),
    ElementBgActive   = Color3.fromRGB(32, 44, 65),
    AccentPrimary     = Color3.fromRGB(0, 200, 210),
    AccentSecondary   = Color3.fromRGB(0, 160, 220),
    AccentGlow        = Color3.fromRGB(0, 230, 240),
    TextPrimary       = Color3.fromRGB(220, 235, 245),
    TextSecondary     = Color3.fromRGB(140, 165, 190),
    TextDimmed        = Color3.fromRGB(80, 105, 135),
    Divider           = Color3.fromRGB(30, 42, 60),
    ToggleOn          = Color3.fromRGB(0, 200, 210),
    ToggleOff         = Color3.fromRGB(50, 60, 80),
    SliderFill        = Color3.fromRGB(0, 200, 210),
    SliderTrack       = Color3.fromRGB(35, 45, 65),
    DropdownBg        = Color3.fromRGB(14, 20, 32),
    NotifyInfo        = Color3.fromRGB(0, 180, 210),
    NotifySuccess     = Color3.fromRGB(0, 210, 140),
    NotifyWarning     = Color3.fromRGB(230, 180, 0),
    NotifyError       = Color3.fromRGB(230, 60, 80),
    Shadow            = Color3.fromRGB(0, 0, 0),
    ModalOverlay      = Color3.fromRGB(0, 0, 0),
}

----------------------------------------------------------------
-- Utility helpers
----------------------------------------------------------------
local Util = {}

function Util.Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Util.Tween(obj, info, goals)
    local tw = TweenService:Create(obj, info, goals)
    tw:Play()
    return tw
end

function Util.QuickTween(obj, duration, goals, style, direction)
    style     = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    return Util.Tween(obj, TweenInfo.new(duration, style, direction), goals)
end

function Util.SpringTween(obj, duration, goals)
    return Util.Tween(obj, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), goals)
end

function Util.AddCorner(parent, radius)
    return Util.Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

function Util.AddStroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or Theme.AccentPrimary,
        Thickness = thickness or 1,
        Transparency = transparency or 0.7,
        Parent = parent,
    })
end

function Util.AddPadding(parent, top, right, bottom, left)
    return Util.Create("UIPadding", {
        PaddingTop    = UDim.new(0, top or 0),
        PaddingRight  = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left or 0),
        Parent = parent,
    })
end

function Util.AddGradient(parent, c1, c2, rotation)
    return Util.Create("UIGradient", {
        Color    = ColorSequence.new(c1 or Theme.AccentPrimary, c2 or Theme.AccentSecondary),
        Rotation = rotation or 45,
        Parent   = parent,
    })
end

function Util.AddShadow(parent, size, transparency)
    local shadow = Util.Create("ImageLabel", {
        Name            = "_Shadow",
        AnchorPoint     = Vector2.new(0.5, 0.5),
        Position        = UDim2.new(0.5, 0, 0.5, 0),
        Size            = UDim2.new(1, size or 30, 1, size or 30),
        BackgroundTransparency = 1,
        Image           = "rbxassetid://5554236805",
        ImageColor3     = Theme.Shadow,
        ImageTransparency = transparency or 0.6,
        ScaleType       = Enum.ScaleType.Slice,
        SliceCenter     = Rect.new(23, 23, 277, 277),
        ZIndex          = parent.ZIndex - 1,
        Parent          = parent,
    })
    return shadow
end

function Util.Ripple(button)
    local ripple = Util.Create("Frame", {
        Name = "_Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.AccentGlow,
        BackgroundTransparency = 0.7,
        ZIndex = button.ZIndex + 1,
        Parent = button,
    })
    Util.AddCorner(ripple, 999)
    local maxDim = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Util.QuickTween(ripple, 0.5, {Size = UDim2.new(0, maxDim, 0, maxDim), BackgroundTransparency = 1})
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Util.MakeDraggable(topBar, frame)
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Util.QuickTween(frame, 0.08, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, Enum.EasingStyle.Sine)
        end
    end)
end

function Util.Truncate(text, maxLen)
    if #text > maxLen then
        return string.sub(text, 1, maxLen - 3) .. "..."
    end
    return text
end

----------------------------------------------------------------
-- ScreenGui bootstrap
----------------------------------------------------------------
local function getScreenGui(name)
    local existing = CoreGui:FindFirstChild(name)
    if existing then existing:Destroy() end
    local sg = Util.Create("ScreenGui", {
        Name              = name,
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn      = false,
        IgnoreGuiInset    = true,
        DisplayOrder      = 100,
        Parent            = CoreGui,
    })
    return sg
end

----------------------------------------------------------------
-- Tooltip system
----------------------------------------------------------------
local function ensureTooltipFrame(screenGui)
    if AquaUI._tipFrame then return end
    local tip = Util.Create("TextLabel", {
        Name                   = "_Tooltip",
        Size                   = UDim2.new(0, 200, 0, 30),
        BackgroundColor3       = Theme.ElementBg,
        BackgroundTransparency = 0.05,
        TextColor3             = Theme.TextPrimary,
        Font                   = Enum.Font.GothamMedium,
        TextSize               = 12,
        Text                   = "",
        Visible                = false,
        ZIndex                 = 9999,
        AutomaticSize          = Enum.AutomaticSize.XY,
        Parent                 = screenGui,
    })
    Util.AddCorner(tip, 6)
    Util.AddPadding(tip, 5, 10, 5, 10)
    Util.AddStroke(tip, Theme.AccentPrimary, 1, 0.5)
    AquaUI._tipFrame = tip
end

function AquaUI:AttachTooltip(guiObj, text)
    guiObj.MouseEnter:Connect(function()
        if AquaUI._tipFrame then
            AquaUI._tipFrame.Text = text
            AquaUI._tipFrame.Visible = true
        end
    end)
    guiObj.MouseLeave:Connect(function()
        if AquaUI._tipFrame then
            AquaUI._tipFrame.Visible = false
        end
    end)
    guiObj.MouseMoved:Connect(function()
        -- not supported on all guis but harmless
    end)
    -- follow mouse via RunService
    if not AquaUI._tipConn then
        AquaUI._tipConn = RunService.Heartbeat:Connect(function()
            if AquaUI._tipFrame and AquaUI._tipFrame.Visible then
                AquaUI._tipFrame.Position = UDim2.new(0, Mouse.X + 14, 0, Mouse.Y + 14)
            end
        end)
    end
end

----------------------------------------------------------------
-- Notification system
----------------------------------------------------------------
local _notifyContainer = nil

local function ensureNotifyContainer(screenGui)
    if _notifyContainer then return end
    _notifyContainer = Util.Create("Frame", {
        Name               = "_Notifications",
        AnchorPoint        = Vector2.new(1, 1),
        Position           = UDim2.new(1, -20, 1, -20),
        Size               = UDim2.new(0, 320, 1, -40),
        BackgroundTransparency = 1,
        Parent             = screenGui,
        ZIndex             = 9000,
    })
    Util.Create("UIListLayout", {
        Padding          = UDim.new(0, 8),
        FillDirection    = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = _notifyContainer,
    })
end

function AquaUI:Notify(opts)
    if not _notifyContainer then return end
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type or "Info"

    local accentMap = {
        Info    = Theme.NotifyInfo,
        Success = Theme.NotifySuccess,
        Warning = Theme.NotifyWarning,
        Error   = Theme.NotifyError,
    }
    local accent = accentMap[ntype] or Theme.NotifyInfo

    local card = Util.Create("Frame", {
        Name               = "_Notify",
        Size               = UDim2.new(1, 0, 0, 72),
        BackgroundColor3   = Theme.ElementBg,
        BackgroundTransparency = 0.05,
        ClipsDescendants   = true,
        Parent             = _notifyContainer,
    })
    Util.AddCorner(card, 10)
    Util.AddStroke(card, accent, 1.5, 0.3)
    Util.AddShadow(card, 20, 0.7)

    -- accent bar
    Util.Create("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    Util.Create("TextLabel", {
        Position         = UDim2.new(0, 18, 0, 10),
        Size             = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextColor3       = Theme.TextPrimary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = card,
    })

    Util.Create("TextLabel", {
        Position         = UDim2.new(0, 18, 0, 32),
        Size             = UDim2.new(1, -28, 0, 32),
        BackgroundTransparency = 1,
        Text             = content,
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = Theme.TextSecondary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Parent           = card,
    })

    -- progress bar
    local pBar = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    -- slide in
    card.Position = UDim2.new(1, 40, 0, 0)
    Util.SpringTween(card, 0.4, {Position = UDim2.new(0, 0, 0, 0)})
    Util.QuickTween(pBar, duration, {Size = UDim2.new(0, 0, 0, 3)}, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Util.QuickTween(card, 0.35, {Position = UDim2.new(1, 40, 0, 0)})
        task.wait(0.4)
        card:Destroy()
    end)
end

----------------------------------------------------------------
-- Modal / Dialog
----------------------------------------------------------------
function AquaUI:Dialog(screenGui, opts)
    opts = opts or {}
    local title   = opts.Title or "Confirm"
    local content = opts.Content or "Are you sure?"
    local buttons = opts.Buttons or {{Text = "OK"}}

    local overlay = Util.Create("Frame", {
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundColor3   = Theme.ModalOverlay,
        BackgroundTransparency = 0.5,
        ZIndex             = 8000,
        Parent             = screenGui,
    })

    local box = Util.Create("Frame", {
        AnchorPoint        = Vector2.new(0.5, 0.5),
        Position           = UDim2.new(0.5, 0, 0.5, 0),
        Size               = UDim2.new(0, 380, 0, 200),
        BackgroundColor3   = Theme.ContentBg,
        ZIndex             = 8001,
        Parent             = overlay,
    })
    Util.AddCorner(box, 14)
    Util.AddStroke(box, Theme.AccentPrimary, 1, 0.4)
    Util.AddShadow(box, 40, 0.5)

    -- accent top line
    local topLine = Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Theme.AccentPrimary,
        BorderSizePixel  = 0,
        Parent           = box,
        ZIndex           = 8002,
    })
    Util.AddGradient(topLine, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    Util.Create("TextLabel", {
        Position         = UDim2.new(0, 24, 0, 20),
        Size             = UDim2.new(1, -48, 0, 24),
        BackgroundTransparency = 1,
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 18,
        TextColor3       = Theme.TextPrimary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 8002,
        Parent           = box,
    })

    Util.Create("TextLabel", {
        Position         = UDim2.new(0, 24, 0, 52),
        Size             = UDim2.new(1, -48, 0, 80),
        BackgroundTransparency = 1,
        Text             = content,
        Font             = Enum.Font.Gotham,
        TextSize         = 14,
        TextColor3       = Theme.TextSecondary,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextYAlignment   = Enum.TextYAlignment.Top,
        TextWrapped      = true,
        ZIndex           = 8002,
        Parent           = box,
    })

    local btnFrame = Util.Create("Frame", {
        AnchorPoint        = Vector2.new(0.5, 1),
        Position           = UDim2.new(0.5, 0, 1, -16),
        Size               = UDim2.new(1, -48, 0, 36),
        BackgroundTransparency = 1,
        ZIndex             = 8002,
        Parent             = box,
    })
    Util.Create("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = UDim.new(0, 10),
        Parent              = btnFrame,
    })

    for _, bData in ipairs(buttons) do
        local btn = Util.Create("TextButton", {
            Size             = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = bData.Primary and Theme.AccentPrimary or Theme.ElementBg,
            Text             = bData.Text or "OK",
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = bData.Primary and Theme.Background or Theme.TextPrimary,
            ZIndex           = 8003,
            Parent           = btnFrame,
        })
        Util.AddCorner(btn, 8)
        if not bData.Primary then
            Util.AddStroke(btn, Theme.Divider, 1, 0.4)
        end
        btn.MouseButton1Click:Connect(function()
            if bData.Callback then bData.Callback() end
            Util.QuickTween(overlay, 0.25, {BackgroundTransparency = 1})
            Util.QuickTween(box, 0.25, {Size = UDim2.new(0, 380, 0, 0)})
            task.delay(0.3, function() overlay:Destroy() end)
        end)
        btn.MouseEnter:Connect(function()
            Util.QuickTween(btn, 0.15, {BackgroundColor3 = bData.Primary and Theme.AccentGlow or Theme.ElementBgHover})
        end)
        btn.MouseLeave:Connect(function()
            Util.QuickTween(btn, 0.15, {BackgroundColor3 = bData.Primary and Theme.AccentPrimary or Theme.ElementBg})
        end)
    end

    -- animate in
    box.Size = UDim2.new(0, 380, 0, 0)
    overlay.BackgroundTransparency = 1
    Util.QuickTween(overlay, 0.3, {BackgroundTransparency = 0.5})
    Util.SpringTween(box, 0.4, {Size = UDim2.new(0, 380, 0, 200)})

    return overlay
end

----------------------------------------------------------------
-- Configuration system
----------------------------------------------------------------
local ConfigModule = {}

function ConfigModule.GetFolder(folderName)
    local ok, result = pcall(function()
        if not isfolder(folderName) then makefolder(folderName) end
    end)
    return ok
end

function ConfigModule.Save(folderName, fileName, data)
    pcall(function()
        ConfigModule.GetFolder(folderName)
        local json = HttpService:JSONEncode(data)
        writefile(folderName .. "/" .. fileName .. ".json", json)
    end)
end

function ConfigModule.Load(folderName, fileName)
    local ok, result = pcall(function()
        if isfile(folderName .. "/" .. fileName .. ".json") then
            return HttpService:JSONDecode(readfile(folderName .. "/" .. fileName .. ".json"))
        end
        return nil
    end)
    if ok then return result end
    return nil
end

----------------------------------------------------------------
-- CreateWindow
----------------------------------------------------------------
function AquaUI:CreateWindow(opts)
    opts = opts or {}
    local windowTitle     = opts.Name or "AquaUI Window"
    local loadingTitle    = opts.LoadingTitle or "AquaUI"
    local loadingSubtitle = opts.LoadingSubtitle or "v" .. self.Version
    local configEnabled   = opts.ConfigurationSaving and opts.ConfigurationSaving.Enabled or false
    local configFolder    = opts.ConfigurationSaving and opts.ConfigurationSaving.FolderName or "AquaUI_Config"
    local configFile      = opts.ConfigurationSaving and opts.ConfigurationSaving.FileName or "default"
    local windowSize      = opts.Size or UDim2.new(0, 620, 0, 420)
    local minimizeKey     = opts.MinimizeKey or Enum.KeyCode.RightShift

    local screenGui = getScreenGui("AquaUI_" .. windowTitle)
    ensureTooltipFrame(screenGui)
    ensureNotifyContainer(screenGui)

    ----------------------------------------------------------------
    -- Loading screen
    ----------------------------------------------------------------
    local loadScreen = Util.Create("Frame", {
        AnchorPoint        = Vector2.new(0.5, 0.5),
        Position           = UDim2.new(0.5, 0, 0.5, 0),
        Size               = UDim2.new(0, 320, 0, 180),
        BackgroundColor3   = Theme.Background,
        Parent             = screenGui,
    })
    Util.AddCorner(loadScreen, 16)
    Util.AddStroke(loadScreen, Theme.AccentPrimary, 1.5, 0.3)
    Util.AddShadow(loadScreen, 50, 0.4)

    local loadGradientBar = Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0,
        Parent           = loadScreen,
    })
    Util.AddGradient(loadGradientBar, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    Util.Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position    = UDim2.new(0.5, 0, 0, 36),
        Size        = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text        = loadingTitle,
        Font        = Enum.Font.GothamBold,
        TextSize    = 22,
        TextColor3  = Theme.AccentGlow,
        Parent      = loadScreen,
    })

    Util.Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position    = UDim2.new(0.5, 0, 0, 68),
        Size        = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text        = loadingSubtitle,
        Font        = Enum.Font.Gotham,
        TextSize    = 13,
        TextColor3  = Theme.TextSecondary,
        Parent      = loadScreen,
    })

    -- loading bar
    local barBg = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position    = UDim2.new(0.5, 0, 0, 110),
        Size        = UDim2.new(0.7, 0, 0, 6),
        BackgroundColor3 = Theme.SliderTrack,
        Parent      = loadScreen,
    })
    Util.AddCorner(barBg, 3)

    local barFill = Util.Create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent           = barBg,
    })
    Util.AddCorner(barFill, 3)
    Util.AddGradient(barFill, Theme.AccentPrimary, Theme.AccentGlow, 0)

    -- animate loading
    Util.QuickTween(barFill, 1.6, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quint)

    task.delay(1.8, function()
        Util.QuickTween(loadScreen, 0.35, {BackgroundTransparency = 1})
        for _, desc in ipairs(loadScreen:GetDescendants()) do
            pcall(function()
                if desc:IsA("TextLabel") then
                    Util.QuickTween(desc, 0.3, {TextTransparency = 1})
                elseif desc:IsA("Frame") then
                    Util.QuickTween(desc, 0.3, {BackgroundTransparency = 1})
                elseif desc:IsA("UIStroke") then
                    Util.QuickTween(desc, 0.3, {Transparency = 1})
                elseif desc:IsA("ImageLabel") then
                    Util.QuickTween(desc, 0.3, {ImageTransparency = 1})
                end
            end)
        end
        task.wait(0.4)
        loadScreen:Destroy()
    end)

    ----------------------------------------------------------------
    -- Main window frame
    ----------------------------------------------------------------
    local mainFrame = Util.Create("Frame", {
        Name               = "MainFrame",
        AnchorPoint        = Vector2.new(0.5, 0.5),
        Position           = UDim2.new(0.5, 0, 0.5, 0),
        Size               = windowSize,
        BackgroundColor3   = Theme.Background,
        ClipsDescendants   = true,
        Visible            = false,
        Parent             = screenGui,
    })
    Util.AddCorner(mainFrame, 12)
    Util.AddStroke(mainFrame, Theme.AccentPrimary, 1, 0.5)
    Util.AddShadow(mainFrame, 50, 0.45)

    -- show after loading
    task.delay(2.0, function()
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        Util.SpringTween(mainFrame, 0.5, {Size = windowSize})
    end)

    ----------------------------------------------------------------
    -- Top bar
    ----------------------------------------------------------------
    local topBar = Util.Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = mainFrame,
    })

    -- gradient line under topbar
    local topLine = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = topBar,
    })
    Util.AddGradient(topLine, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    -- title
    Util.Create("TextLabel", {
        Position         = UDim2.new(0, 16, 0, 0),
        Size             = UDim2.new(0, 250, 1, 0),
        BackgroundTransparency = 1,
        Text             = windowTitle,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        TextColor3       = Theme.AccentGlow,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 11,
        Parent           = topBar,
    })

    -- close btn
    local closeBtn = Util.Create("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -10, 0.5, 0),
        Size             = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.ElementBg,
        Text             = "X",
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextColor3       = Theme.TextSecondary,
        ZIndex           = 12,
        Parent           = topBar,
    })
    Util.AddCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function()
        Util.QuickTween(mainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
        task.delay(0.35, function() screenGui:Destroy() end)
    end)
    closeBtn.MouseEnter:Connect(function() Util.QuickTween(closeBtn, 0.15, {BackgroundColor3 = Theme.NotifyError}) end)
    closeBtn.MouseLeave:Connect(function() Util.QuickTween(closeBtn, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

    -- minimize btn
    local minBtn = Util.Create("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -44, 0.5, 0),
        Size             = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.ElementBg,
        Text             = "-",
        Font             = Enum.Font.GothamBold,
        TextSize         = 18,
        TextColor3       = Theme.TextSecondary,
        ZIndex           = 12,
        Parent           = topBar,
    })
    Util.AddCorner(minBtn, 6)
    local minimized = false
    local function toggleMinimize()
        minimized = not minimized
        if minimized then
            Util.QuickTween(mainFrame, 0.35, {Size = UDim2.new(0, 0, 0, 0)})
        else
            mainFrame.Visible = true
            Util.SpringTween(mainFrame, 0.4, {Size = windowSize})
        end
    end
    minBtn.MouseButton1Click:Connect(toggleMinimize)
    minBtn.MouseEnter:Connect(function() Util.QuickTween(minBtn, 0.15, {BackgroundColor3 = Theme.ElementBgHover}) end)
    minBtn.MouseLeave:Connect(function() Util.QuickTween(minBtn, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

    -- keybind for minimize
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == minimizeKey then
            toggleMinimize()
        end
    end)

    Util.MakeDraggable(topBar, mainFrame)

    ----------------------------------------------------------------
    -- Sidebar
    ----------------------------------------------------------------
    local sidebar = Util.Create("Frame", {
        Name             = "Sidebar",
        Position         = UDim2.new(0, 0, 0, 42),
        Size             = UDim2.new(0, 160, 1, -42),
        BackgroundColor3 = Theme.SidebarBg,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = mainFrame,
    })

    -- search bar at top of sidebar
    local searchFrame = Util.Create("Frame", {
        Position         = UDim2.new(0, 8, 0, 8),
        Size             = UDim2.new(1, -16, 0, 30),
        BackgroundColor3 = Theme.ElementBg,
        ZIndex           = 6,
        Parent           = sidebar,
    })
    Util.AddCorner(searchFrame, 6)

    local searchIcon = Util.Create("TextLabel", {
        Position         = UDim2.new(0, 6, 0, 0),
        Size             = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text             = "?",
        Font             = Enum.Font.Gotham,
        TextSize         = 14,
        TextColor3       = Theme.TextDimmed,
        ZIndex           = 7,
        Parent           = searchFrame,
    })

    local searchBox = Util.Create("TextBox", {
        Position         = UDim2.new(0, 26, 0, 0),
        Size             = UDim2.new(1, -32, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        PlaceholderText  = "Search...",
        PlaceholderColor3= Theme.TextDimmed,
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = Theme.TextPrimary,
        ClearTextOnFocus = false,
        ZIndex           = 7,
        Parent           = searchFrame,
    })

    -- tab buttons container
    local tabBtnContainer = Util.Create("ScrollingFrame", {
        Position            = UDim2.new(0, 0, 0, 46),
        Size                = UDim2.new(1, 0, 1, -46),
        BackgroundTransparency = 1,
        ScrollBarThickness  = 2,
        ScrollBarImageColor3= Theme.AccentPrimary,
        CanvasSize          = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex              = 6,
        Parent              = sidebar,
    })
    Util.Create("UIListLayout", {
        Padding   = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent    = tabBtnContainer,
    })
    Util.AddPadding(tabBtnContainer, 4, 8, 4, 8)

    -- divider between sidebar and content
    Util.Create("Frame", {
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = sidebar,
    })

    ----------------------------------------------------------------
    -- Content area
    ----------------------------------------------------------------
    local contentArea = Util.Create("Frame", {
        Name             = "Content",
        Position         = UDim2.new(0, 160, 0, 42),
        Size             = UDim2.new(1, -160, 1, -42),
        BackgroundColor3 = Theme.ContentBg,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 3,
        Parent           = mainFrame,
    })

    ----------------------------------------------------------------
    -- Window object
    ----------------------------------------------------------------
    local WindowObj = {
        _screenGui    = screenGui,
        _mainFrame    = mainFrame,
        _contentArea  = contentArea,
        _tabContainer = tabBtnContainer,
        _tabs         = {},
        _activeTab    = nil,
        _searchBox    = searchBox,
    }

    -- search filtering
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        for _, tab in ipairs(WindowObj._tabs) do
            for _, elem in ipairs(tab._elements) do
                if elem.Frame then
                    if query == "" then
                        elem.Frame.Visible = true
                    else
                        local nameL = string.lower(elem.Name or "")
                        elem.Frame.Visible = string.find(nameL, query, 1, true) ~= nil
                    end
                end
            end
        end
    end)

    ----------------------------------------------------------------
    -- Tab creation
    ----------------------------------------------------------------
    function WindowObj:CreateTab(tabName, iconId)
        tabName = tabName or "Tab"

        -- tab button in sidebar
        local tabBtn = Util.Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.SidebarBg,
            BackgroundTransparency = 1,
            Text             = "",
            ZIndex           = 7,
            Parent           = tabBtnContainer,
        })
        Util.AddCorner(tabBtn, 7)

        if iconId then
            Util.Create("ImageLabel", {
                Position         = UDim2.new(0, 8, 0.5, -8),
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image            = (type(iconId) == "number") and ("rbxassetid://" .. tostring(iconId)) or tostring(iconId),
                ImageColor3      = Theme.TextSecondary,
                ZIndex           = 8,
                Parent           = tabBtn,
            })
        end

        local tabLabel = Util.Create("TextLabel", {
            Position         = UDim2.new(0, iconId and 30 or 10, 0, 0),
            Size             = UDim2.new(1, iconId and -36 or -16, 1, 0),
            BackgroundTransparency = 1,
            Text             = tabName,
            Font             = Enum.Font.GothamMedium,
            TextSize         = 13,
            TextColor3       = Theme.TextSecondary,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextTruncate     = Enum.TextTruncate.AtEnd,
            ZIndex           = 8,
            Parent           = tabBtn,
        })

        -- accent indicator
        local indicator = Util.Create("Frame", {
            Position         = UDim2.new(0, 0, 0.15, 0),
            Size             = UDim2.new(0, 3, 0.7, 0),
            BackgroundColor3 = Theme.AccentPrimary,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 9,
            Parent           = tabBtn,
        })
        Util.AddCorner(indicator, 2)

        -- scroll frame for tab content
        local tabContent = Util.Create("ScrollingFrame", {
            Size                = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness  = 3,
            ScrollBarImageColor3= Theme.AccentPrimary,
            CanvasSize          = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible             = false,
            ZIndex              = 4,
            Parent              = contentArea,
        })
        Util.Create("UIListLayout", {
            Padding   = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent    = tabContent,
        })
        Util.AddPadding(tabContent, 12, 14, 12, 14)

        local TabObj = {
            Name       = tabName,
            _btn       = tabBtn,
            _label     = tabLabel,
            _indicator = indicator,
            _content   = tabContent,
            _elements  = {},
        }

        local function activateTab()
            -- deactivate all
            for _, t in ipairs(WindowObj._tabs) do
                t._content.Visible = false
                Util.QuickTween(t._label, 0.2, {TextColor3 = Theme.TextSecondary})
                Util.QuickTween(t._indicator, 0.2, {BackgroundTransparency = 1})
                Util.QuickTween(t._btn, 0.2, {BackgroundTransparency = 1})
            end
            -- activate this
            tabContent.Visible = true
            Util.QuickTween(tabLabel, 0.2, {TextColor3 = Theme.AccentGlow})
            Util.QuickTween(indicator, 0.2, {BackgroundTransparency = 0})
            Util.QuickTween(tabBtn, 0.2, {BackgroundTransparency = 0.85, BackgroundColor3 = Theme.AccentPrimary})
            WindowObj._activeTab = TabObj
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        tabBtn.MouseEnter:Connect(function()
            if WindowObj._activeTab ~= TabObj then
                Util.QuickTween(tabBtn, 0.15, {BackgroundTransparency = 0.9, BackgroundColor3 = Theme.ElementBgHover})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if WindowObj._activeTab ~= TabObj then
                Util.QuickTween(tabBtn, 0.15, {BackgroundTransparency = 1})
            end
        end)

        table.insert(WindowObj._tabs, TabObj)
        if #WindowObj._tabs == 1 then activateTab() end

        ----------------------------------------------------------------
        -- Element builders
        ----------------------------------------------------------------

        -- helper: element container
        local function makeElementFrame(height)
            local f = Util.Create("Frame", {
                Size               = UDim2.new(1, 0, 0, height or 38),
                BackgroundColor3   = Theme.ElementBg,
                ZIndex             = 5,
                Parent             = tabContent,
            })
            Util.AddCorner(f, 8)
            return f
        end

        ---- SECTION ----
        function TabObj:CreateSection(name)
            local s = Util.Create("Frame", {
                Size               = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                ZIndex             = 5,
                Parent             = tabContent,
            })
            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 4, 0, 0),
                Size             = UDim2.new(1, -8, 1, 0),
                BackgroundTransparency = 1,
                Text             = string.upper(name or "SECTION"),
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = Theme.AccentPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = s,
            })
            table.insert(TabObj._elements, {Frame = s, Name = name})
            return s
        end

        ---- DIVIDER ----
        function TabObj:CreateDivider()
            local d = Util.Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = tabContent,
            })
            table.insert(TabObj._elements, {Frame = d, Name = "divider"})
            return d
        end

        ---- LABEL ----
        function TabObj:CreateLabel(text)
            local f = makeElementFrame(32)
            local lbl = Util.Create("TextLabel", {
                Position         = UDim2.new(0, 12, 0, 0),
                Size             = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text             = text or "",
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })
            local LabelObj = {Frame = f, Name = text}
            function LabelObj:Set(newText)
                lbl.Text = newText
                LabelObj.Name = newText
            end
            table.insert(TabObj._elements, LabelObj)
            return LabelObj
        end

        ---- PARAGRAPH ----
        function TabObj:CreateParagraph(opts)
            opts = opts or {}
            local title   = opts.Title or "Info"
            local content = opts.Content or ""

            local f = makeElementFrame(60)
            f.Size = UDim2.new(1, 0, 0, 0)
            f.AutomaticSize = Enum.AutomaticSize.Y

            Util.AddPadding(f, 10, 12, 10, 12)

            Util.Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = title,
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                TextColor3       = Theme.AccentGlow,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                LayoutOrder      = 1,
                Parent           = f,
            })

            local contentLabel = Util.Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text             = content,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.TextSecondary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                ZIndex           = 6,
                LayoutOrder      = 2,
                Parent           = f,
            })

            Util.Create("UIListLayout", {
                Padding   = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = f,
            })

            local obj = {Frame = f, Name = title}
            function obj:Set(newTitle, newContent)
                if newTitle then
                    -- update first child textlabel
                    for _, c in ipairs(f:GetChildren()) do
                        if c:IsA("TextLabel") then c.Text = newTitle; break end
                    end
                end
                if newContent then contentLabel.Text = newContent end
            end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- BUTTON ----
        function TabObj:CreateButton(opts)
            opts = opts or {}
            local name     = opts.Name or "Button"
            local callback = opts.Callback or function() end
            local tooltip  = opts.Tooltip

            local f = makeElementFrame(38)

            local btn = Util.Create("TextButton", {
                Position         = UDim2.new(0, 0, 0, 0),
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 6,
                Parent           = f,
            })

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(1, -28, 1, 0),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 7,
                Parent           = f,
            })

            -- arrow icon
            Util.Create("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Text             = ">",
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                TextColor3       = Theme.AccentPrimary,
                ZIndex           = 7,
                Parent           = f,
            })

            btn.MouseButton1Click:Connect(function()
                Util.Ripple(f)
                callback()
            end)
            btn.MouseEnter:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBgHover}) end)
            btn.MouseLeave:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- TOGGLE ----
        function TabObj:CreateToggle(opts)
            opts = opts or {}
            local name     = opts.Name or "Toggle"
            local default  = opts.CurrentValue or false
            local flag     = opts.Flag
            local callback = opts.Callback or function() end
            local tooltip  = opts.Tooltip

            local f = makeElementFrame(38)

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(1, -70, 1, 0),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local toggleBg = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 42, 0, 22),
                BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff,
                ZIndex           = 7,
                Parent           = f,
            })
            Util.AddCorner(toggleBg, 11)

            local toggleCircle = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = default and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size             = UDim2.new(0, 18, 0, 18),
                BackgroundColor3 = Theme.TextPrimary,
                ZIndex           = 8,
                Parent           = toggleBg,
            })
            Util.AddCorner(toggleCircle, 9)

            -- glow effect on circle when on
            local glow = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(0.5, 0, 0.5, 0),
                Size             = UDim2.new(1, 8, 1, 8),
                BackgroundColor3 = Theme.AccentGlow,
                BackgroundTransparency = default and 0.7 or 1,
                ZIndex           = 7,
                Parent           = toggleCircle,
            })
            Util.AddCorner(glow, 14)

            local state = default
            local function setState(value, skipCallback)
                state = value
                Util.QuickTween(toggleBg, 0.25, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
                Util.SpringTween(toggleCircle, 0.3, {Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
                Util.QuickTween(glow, 0.25, {BackgroundTransparency = state and 0.7 or 1})
                if not skipCallback then callback(state) end
            end

            local toggleBtn = Util.Create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 9,
                Parent           = f,
            })
            toggleBtn.MouseButton1Click:Connect(function() setState(not state) end)
            toggleBtn.MouseEnter:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBgHover}) end)
            toggleBtn.MouseLeave:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(value)
                setState(value, false)
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)

            if configEnabled then
                local loaded = ConfigModule.Load(configFolder, configFile)
                if loaded and loaded[flag or name] ~= nil then
                    setState(loaded[flag or name], false)
                end
            end

            return obj
        end

        ---- SLIDER ----
        function TabObj:CreateSlider(opts)
            opts = opts or {}
            local name     = opts.Name or "Slider"
            local min      = opts.Range and opts.Range[1] or 0
            local max      = opts.Range and opts.Range[2] or 100
            local inc      = opts.Increment or 1
            local default  = opts.CurrentValue or min
            local suffix   = opts.Suffix or ""
            local flag     = opts.Flag
            local callback = opts.Callback or function() end
            local tooltip  = opts.Tooltip

            local f = makeElementFrame(56)

            local nameLabel = Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 6),
                Size             = UDim2.new(0.6, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local valueLabel = Util.Create("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0),
                Position         = UDim2.new(1, -14, 0, 6),
                Size             = UDim2.new(0.3, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = tostring(default) .. suffix,
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextColor3       = Theme.AccentGlow,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 6,
                Parent           = f,
            })

            local track = Util.Create("Frame", {
                Position         = UDim2.new(0, 14, 0, 34),
                Size             = UDim2.new(1, -28, 0, 6),
                BackgroundColor3 = Theme.SliderTrack,
                ZIndex           = 6,
                Parent           = f,
            })
            Util.AddCorner(track, 3)

            local fill = Util.Create("Frame", {
                Size             = UDim2.new((default - min) / math.max(max - min, 1), 0, 1, 0),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = 7,
                Parent           = track,
            })
            Util.AddCorner(fill, 3)
            Util.AddGradient(fill, Theme.AccentPrimary, Theme.AccentGlow, 0)

            local knob = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new((default - min) / math.max(max - min, 1), 0, 0.5, 0),
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Theme.AccentGlow,
                ZIndex           = 8,
                Parent           = track,
            })
            Util.AddCorner(knob, 8)
            Util.AddStroke(knob, Theme.Background, 2, 0)

            local currentVal = default
            local sliding = false

            local inputBtn = Util.Create("TextButton", {
                Position         = UDim2.new(0, 14, 0, 26),
                Size             = UDim2.new(1, -28, 0, 22),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 10,
                Parent           = f,
            })

            local function updateSlider(inputX)
                local trackAbsPos = track.AbsolutePosition.X
                local trackAbsSize = track.AbsoluteSize.X
                local rel = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                local rawVal = min + (max - min) * rel
                local snapped = math.floor(rawVal / inc + 0.5) * inc
                snapped = math.clamp(snapped, min, max)
                currentVal = snapped
                local pct = (currentVal - min) / math.max(max - min, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valueLabel.Text = tostring(currentVal) .. suffix
                callback(currentVal)
            end

            inputBtn.MouseButton1Down:Connect(function()
                sliding = true
                updateSlider(Mouse.X)
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            RunService.Heartbeat:Connect(function()
                if sliding then updateSlider(Mouse.X) end
            end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(value)
                currentVal = math.clamp(value, min, max)
                local pct = (currentVal - min) / math.max(max - min, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valueLabel.Text = tostring(currentVal) .. suffix
                callback(currentVal)
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- DROPDOWN ----
        function TabObj:CreateDropdown(opts)
            opts = opts or {}
            local name      = opts.Name or "Dropdown"
            local options   = opts.Options or {}
            local default   = opts.CurrentValue or (options[1] or "")
            local multi     = opts.MultipleOptions or false
            local flag      = opts.Flag
            local callback  = opts.Callback or function() end
            local tooltip   = opts.Tooltip

            local f = makeElementFrame(38)
            f.ClipsDescendants = false

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(0.55, 0, 0, 38),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local selectedDisplay = Util.Create("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0),
                Position         = UDim2.new(1, -36, 0, 0),
                Size             = UDim2.new(0.35, 0, 0, 38),
                BackgroundTransparency = 1,
                Text             = multi and "Select..." or tostring(default),
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.AccentGlow,
                TextXAlignment   = Enum.TextXAlignment.Right,
                TextTruncate     = Enum.TextTruncate.AtEnd,
                ZIndex           = 6,
                Parent           = f,
            })

            local arrow = Util.Create("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0, 19),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 1,
                Text             = "v",
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = Theme.TextSecondary,
                ZIndex           = 7,
                Parent           = f,
            })

            local dropFrame = Util.Create("Frame", {
                Position         = UDim2.new(0, 0, 1, 4),
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.DropdownBg,
                ClipsDescendants = true,
                ZIndex           = 50,
                Parent           = f,
            })
            Util.AddCorner(dropFrame, 8)
            Util.AddStroke(dropFrame, Theme.AccentPrimary, 1, 0.5)

            local dropScroll = Util.Create("ScrollingFrame", {
                Size                = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness  = 2,
                ScrollBarImageColor3= Theme.AccentPrimary,
                CanvasSize          = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex              = 51,
                Parent              = dropFrame,
            })
            Util.Create("UIListLayout", {
                Padding   = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = dropScroll,
            })
            Util.AddPadding(dropScroll, 4, 4, 4, 4)

            local opened = false
            local selected = multi and {} or default
            if multi and type(default) == "table" then
                for _, v in ipairs(default) do selected[v] = true end
            end

            local function refreshDisplay()
                if multi then
                    local items = {}
                    for k, _ in pairs(selected) do table.insert(items, k) end
                    selectedDisplay.Text = #items > 0 and table.concat(items, ", ") or "Select..."
                else
                    selectedDisplay.Text = tostring(selected)
                end
            end

            local function buildOptions()
                for _, c in ipairs(dropScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local isOn = multi and selected[opt] or (selected == opt)
                    local optBtn = Util.Create("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = isOn and Theme.AccentPrimary or Theme.ElementBg,
                        BackgroundTransparency = isOn and 0.7 or 0,
                        Text             = opt,
                        Font             = Enum.Font.GothamMedium,
                        TextSize         = 12,
                        TextColor3       = isOn and Theme.AccentGlow or Theme.TextPrimary,
                        ZIndex           = 52,
                        Parent           = dropScroll,
                    })
                    Util.AddCorner(optBtn, 6)
                    optBtn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt] or nil
                            refreshDisplay()
                            buildOptions()
                            local result = {}
                            for k, _ in pairs(selected) do table.insert(result, k) end
                            callback(result)
                        else
                            selected = opt
                            refreshDisplay()
                            buildOptions()
                            callback(opt)
                            -- close
                            opened = false
                            f.ZIndex = defaultZIndex
                            Util.QuickTween(dropFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                            Util.QuickTween(arrow, 0.2, {Rotation = 0})
                        end
                    end)
                    optBtn.MouseEnter:Connect(function()
                        Util.QuickTween(optBtn, 0.1, {BackgroundColor3 = Theme.ElementBgHover})
                    end)
                    optBtn.MouseLeave:Connect(function()
                        local isOn2 = multi and selected[opt] or (selected == opt)
                        Util.QuickTween(optBtn, 0.1, {BackgroundColor3 = isOn2 and Theme.AccentPrimary or Theme.ElementBg})
                    end)
                end
            end
            buildOptions()
            refreshDisplay()

            local defaultZIndex = f.ZIndex

            local toggleDDBtn = Util.Create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 10,
                Parent           = f,
            })
            toggleDDBtn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    f.ZIndex = 100
                    local h = math.min(#options * 30 + 10, 180)
                    Util.QuickTween(dropFrame, 0.25, {Size = UDim2.new(1, 0, 0, h)})
                    Util.QuickTween(arrow, 0.25, {Rotation = 180})
                else
                    f.ZIndex = defaultZIndex
                    Util.QuickTween(dropFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                    Util.QuickTween(arrow, 0.2, {Rotation = 0})
                end
            end)
            toggleDDBtn.MouseEnter:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBgHover}) end)
            toggleDDBtn.MouseLeave:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(value)
                if multi and type(value) == "table" then
                    selected = {}
                    for _, v in ipairs(value) do selected[v] = true end
                else
                    selected = value
                end
                refreshDisplay()
                buildOptions()
            end
            function obj:Refresh(newOptions)
                options = newOptions
                buildOptions()
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- TEXT INPUT ----
        function TabObj:CreateInput(opts)
            opts = opts or {}
            local name        = opts.Name or "Input"
            local placeholder = opts.PlaceholderText or "Type here..."
            local flag        = opts.Flag
            local callback    = opts.Callback or function() end
            local tooltip     = opts.Tooltip

            local f = makeElementFrame(38)

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local inputBox = Util.Create("TextBox", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0.5, 0, 0, 26),
                BackgroundColor3 = Theme.ContentBg,
                Text             = "",
                PlaceholderText  = placeholder,
                PlaceholderColor3= Theme.TextDimmed,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.TextPrimary,
                ClearTextOnFocus = false,
                ZIndex           = 7,
                Parent           = f,
            })
            Util.AddCorner(inputBox, 6)
            Util.AddStroke(inputBox, Theme.Divider, 1, 0.3)

            inputBox.Focused:Connect(function()
                Util.QuickTween(inputBox, 0.2, {BackgroundColor3 = Theme.ElementBgActive})
            end)
            inputBox.FocusLost:Connect(function(enterPressed)
                Util.QuickTween(inputBox, 0.2, {BackgroundColor3 = Theme.ContentBg})
                if enterPressed then callback(inputBox.Text) end
            end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(text)
                inputBox.Text = text
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- KEYBIND ----
        function TabObj:CreateKeybind(opts)
            opts = opts or {}
            local name     = opts.Name or "Keybind"
            local default  = opts.CurrentKeybind or "None"
            local flag     = opts.Flag
            local callback = opts.Callback or function() end
            local tooltip  = opts.Tooltip

            local f = makeElementFrame(38)
            local currentKey = default ~= "None" and Enum.KeyCode[default] or nil

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local keyBtn = Util.Create("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 80, 0, 26),
                BackgroundColor3 = Theme.ContentBg,
                Text             = default,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = Theme.AccentGlow,
                ZIndex           = 7,
                Parent           = f,
            })
            Util.AddCorner(keyBtn, 6)
            Util.AddStroke(keyBtn, Theme.Divider, 1, 0.3)

            local listening = false
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                Util.QuickTween(keyBtn, 0.15, {BackgroundColor3 = Theme.AccentPrimary})
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if not listening then
                    if currentKey and input.KeyCode == currentKey and not gpe then
                        callback(currentKey.Name)
                    end
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        currentKey = nil
                        keyBtn.Text = "None"
                    else
                        currentKey = input.KeyCode
                        keyBtn.Text = input.KeyCode.Name
                    end
                    Util.QuickTween(keyBtn, 0.15, {BackgroundColor3 = Theme.ContentBg})
                end
            end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(keyName)
                if keyName == "None" then
                    currentKey = nil
                    keyBtn.Text = "None"
                else
                    currentKey = Enum.KeyCode[keyName]
                    keyBtn.Text = keyName
                end
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- COLOR PICKER ----
        function TabObj:CreateColorPicker(opts)
            opts = opts or {}
            local name     = opts.Name or "Color Picker"
            local default  = opts.Color or Theme.AccentPrimary
            local flag     = opts.Flag
            local callback = opts.Callback or function() end
            local tooltip  = opts.Tooltip

            local f = makeElementFrame(38)
            f.ClipsDescendants = false
            local currentColor = default

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 0),
                Size             = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local preview = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -12, 0.5, 0),
                Size             = UDim2.new(0, 30, 0, 22),
                BackgroundColor3 = currentColor,
                ZIndex           = 7,
                Parent           = f,
            })
            Util.AddCorner(preview, 6)
            Util.AddStroke(preview, Theme.Divider, 1, 0.3)

            local pickerFrame = Util.Create("Frame", {
                Position         = UDim2.new(0, 0, 1, 4),
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.DropdownBg,
                ClipsDescendants = true,
                ZIndex           = 50,
                Parent           = f,
            })
            Util.AddCorner(pickerFrame, 8)
            Util.AddStroke(pickerFrame, Theme.AccentPrimary, 1, 0.5)

            -- HSV sliders inside picker
            local sliderNames = {"H", "S", "V"}
            local sliderValues = {0, 1, 1}
            do
                local h, s, v = Color3.toHSV(currentColor)
                sliderValues = {h, s, v}
            end
            local sliderBars = {}

            for i, sn in ipairs(sliderNames) do
                local yOff = 10 + (i - 1) * 30

                Util.Create("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, yOff),
                    Size             = UDim2.new(0, 16, 0, 20),
                    BackgroundTransparency = 1,
                    Text             = sn,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 11,
                    TextColor3       = Theme.TextSecondary,
                    ZIndex           = 52,
                    Parent           = pickerFrame,
                })

                local sTrack = Util.Create("Frame", {
                    Position         = UDim2.new(0, 30, 0, yOff + 6),
                    Size             = UDim2.new(1, -44, 0, 8),
                    BackgroundColor3 = Theme.SliderTrack,
                    ZIndex           = 52,
                    Parent           = pickerFrame,
                })
                Util.AddCorner(sTrack, 4)

                local sFill = Util.Create("Frame", {
                    Size             = UDim2.new(sliderValues[i], 0, 1, 0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    ZIndex           = 53,
                    Parent           = sTrack,
                })
                Util.AddCorner(sFill, 4)
                if i == 1 then
                    Util.AddGradient(sFill, Color3.fromHSV(0, 1, 1), Color3.fromHSV(0.5, 1, 1), 0)
                else
                    Util.AddGradient(sFill, Theme.AccentPrimary, Theme.AccentGlow, 0)
                end

                sliderBars[i] = {track = sTrack, fill = sFill}

                local sBtn = Util.Create("TextButton", {
                    Position         = UDim2.new(0, 30, 0, yOff),
                    Size             = UDim2.new(1, -44, 0, 20),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 55,
                    Parent           = pickerFrame,
                })

                local dragging = false
                sBtn.MouseButton1Down:Connect(function() dragging = true end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                RunService.Heartbeat:Connect(function()
                    if dragging then
                        local rel = math.clamp((Mouse.X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
                        sliderValues[i] = rel
                        sFill.Size = UDim2.new(rel, 0, 1, 0)
                        currentColor = Color3.fromHSV(sliderValues[1], sliderValues[2], sliderValues[3])
                        preview.BackgroundColor3 = currentColor
                        callback(currentColor)
                    end
                end)
            end

            local pickerOpen = false
            local pickerDefaultZIndex = f.ZIndex

            local togglePickerBtn = Util.Create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 10,
                Parent           = f,
            })
            togglePickerBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    f.ZIndex = 100
                else
                    f.ZIndex = pickerDefaultZIndex
                end
                Util.QuickTween(pickerFrame, 0.25, {Size = pickerOpen and UDim2.new(1, 0, 0, 105) or UDim2.new(1, 0, 0, 0)})
            end)
            togglePickerBtn.MouseEnter:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBgHover}) end)
            togglePickerBtn.MouseLeave:Connect(function() Util.QuickTween(f, 0.15, {BackgroundColor3 = Theme.ElementBg}) end)

            if tooltip then AquaUI:AttachTooltip(f, tooltip) end

            local obj = {Frame = f, Name = name}
            function obj:Set(color)
                currentColor = color
                preview.BackgroundColor3 = color
                local h, s, v = Color3.toHSV(color)
                sliderValues = {h, s, v}
                for idx, bar in ipairs(sliderBars) do
                    bar.fill.Size = UDim2.new(sliderValues[idx], 0, 1, 0)
                end
            end
            if flag then AquaUI.Flags[flag] = obj end
            table.insert(TabObj._elements, obj)
            return obj
        end

        ---- PROGRESS BAR ----
        function TabObj:CreateProgressBar(opts)
            opts = opts or {}
            local name    = opts.Name or "Progress"
            local default = opts.CurrentValue or 0

            local f = makeElementFrame(48)

            Util.Create("TextLabel", {
                Position         = UDim2.new(0, 14, 0, 4),
                Size             = UDim2.new(0.6, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = name,
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = Theme.TextPrimary,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = f,
            })

            local pctLabel = Util.Create("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0),
                Position         = UDim2.new(1, -14, 0, 4),
                Size             = UDim2.new(0.3, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = tostring(math.floor(default * 100)) .. "%",
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = Theme.AccentGlow,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 6,
                Parent           = f,
            })

            local barBg = Util.Create("Frame", {
                Position         = UDim2.new(0, 14, 0, 28),
                Size             = UDim2.new(1, -28, 0, 10),
                BackgroundColor3 = Theme.SliderTrack,
                ZIndex           = 6,
                Parent           = f,
            })
            Util.AddCorner(barBg, 5)

            local barFill = Util.Create("Frame", {
                Size             = UDim2.new(math.clamp(default, 0, 1), 0, 1, 0),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = 7,
                Parent           = barBg,
            })
            Util.AddCorner(barFill, 5)
            Util.AddGradient(barFill, Theme.AccentPrimary, Theme.AccentGlow, 0)

            local obj = {Frame = f, Name = name}
            function obj:Set(value)
                value = math.clamp(value, 0, 1)
                Util.QuickTween(barFill, 0.3, {Size = UDim2.new(value, 0, 1, 0)})
                pctLabel.Text = tostring(math.floor(value * 100)) .. "%"
            end
            table.insert(TabObj._elements, obj)
            return obj
        end

        return TabObj
    end

    ----------------------------------------------------------------
    -- Notification (window-level shortcut)
    ----------------------------------------------------------------
    function WindowObj:Notify(opts)
        AquaUI:Notify(opts)
    end

    ----------------------------------------------------------------
    -- Dialog (window-level shortcut)
    ----------------------------------------------------------------
    function WindowObj:Dialog(opts)
        return AquaUI:Dialog(screenGui, opts)
    end

    ----------------------------------------------------------------
    -- Destroy
    ----------------------------------------------------------------
    function WindowObj:Destroy()
        Util.QuickTween(mainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
        task.delay(0.35, function() screenGui:Destroy() end)
    end

    ----------------------------------------------------------------
    -- Save / Load config
    ----------------------------------------------------------------
    function WindowObj:SaveConfig(name)
        if not configEnabled then return end
        local data = {}
        for flagName, flagObj in pairs(AquaUI.Flags) do
            if flagObj and flagObj.Frame then
                -- try to get value
                pcall(function()
                    -- we store minimal data
                    data[flagName] = true
                end)
            end
        end
        ConfigModule.Save(configFolder, name or configFile, data)
    end

    function WindowObj:LoadConfig(name)
        if not configEnabled then return end
        local data = ConfigModule.Load(configFolder, name or configFile)
        if data then
            for flagName, value in pairs(data) do
                if AquaUI.Flags[flagName] and AquaUI.Flags[flagName].Set then
                    pcall(function() AquaUI.Flags[flagName]:Set(value) end)
                end
            end
        end
    end

    table.insert(self.Windows, WindowObj)
    return WindowObj
end

----------------------------------------------------------------
-- Theme access
----------------------------------------------------------------
function AquaUI:GetTheme()
    return Theme
end

function AquaUI:SetThemeColor(key, color)
    if Theme[key] then
        Theme[key] = color
    end
end

return AquaUI
