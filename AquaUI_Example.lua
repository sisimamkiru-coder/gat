--[[
    AquaUI - Example / Demo Script
    Shows all available elements and features
]]

local AquaUI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

-- Create the window
local Window = AquaUI:CreateWindow({
    Name              = "AquaUI Demo v2.0",
    LoadingTitle      = "AquaUI",
    LoadingSubtitle   = "Premium UI Library",
    Size              = UDim2.new(0, 640, 0, 440),
    MinimizeKey       = Enum.KeyCode.RightShift,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "AquaUI_Demo",
        FileName   = "default",
    },
})

----------------------------------------------------------------
-- Tab 1: Main
----------------------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Controls")

MainTab:CreateButton({
    Name     = "Print Hello",
    Tooltip  = "Prints Hello to the console",
    Callback = function()
        print("Hello from AquaUI!")
        Window:Notify({
            Title    = "Button Pressed",
            Content  = "You clicked the Hello button!",
            Duration = 3,
            Type     = "Success",
        })
    end,
})

MainTab:CreateToggle({
    Name         = "Auto Farm",
    CurrentValue = false,
    Flag         = "autoFarm",
    Tooltip      = "Toggles the auto farm feature",
    Callback     = function(value)
        print("Auto Farm:", value)
    end,
})

MainTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 200},
    Increment    = 1,
    CurrentValue = 16,
    Suffix       = " studs/s",
    Flag         = "walkSpeed",
    Tooltip      = "Adjusts your walk speed",
    Callback     = function(value)
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end,
})

MainTab:CreateDivider()

MainTab:CreateDropdown({
    Name         = "Select Mode",
    Options      = {"Normal", "Turbo", "Stealth", "Custom"},
    CurrentValue = "Normal",
    Flag         = "gameMode",
    Tooltip      = "Choose your game mode",
    Callback     = function(option)
        print("Selected mode:", option)
    end,
})

MainTab:CreateDropdown({
    Name            = "Select Items",
    Options         = {"Sword", "Shield", "Potion", "Scroll", "Ring", "Amulet"},
    MultipleOptions = true,
    Flag            = "itemSelect",
    Callback        = function(options)
        print("Selected items:", table.concat(options, ", "))
    end,
})

MainTab:CreateInput({
    Name            = "Player Name",
    PlaceholderText = "Enter name...",
    Flag            = "targetPlayer",
    Callback        = function(text)
        print("Input:", text)
    end,
})

----------------------------------------------------------------
-- Tab 2: Visuals
----------------------------------------------------------------
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateSection("Appearance")

VisualsTab:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(0, 200, 210),
    Flag     = "espColor",
    Callback = function(color)
        print("Color:", color)
    end,
})

VisualsTab:CreateToggle({
    Name         = "Show Tracers",
    CurrentValue = false,
    Flag         = "showTracers",
    Callback     = function(value)
        print("Tracers:", value)
    end,
})

VisualsTab:CreateSlider({
    Name         = "Transparency",
    Range        = {0, 100},
    Increment    = 5,
    CurrentValue = 50,
    Suffix       = "%",
    Flag         = "espTransparency",
    Callback     = function(value)
        print("Transparency:", value)
    end,
})

local progressBar = VisualsTab:CreateProgressBar({
    Name         = "Loading Assets",
    CurrentValue = 0,
})

VisualsTab:CreateButton({
    Name     = "Simulate Loading",
    Callback = function()
        task.spawn(function()
            for i = 1, 20 do
                progressBar:Set(i / 20)
                task.wait(0.15)
            end
            Window:Notify({
                Title    = "Complete",
                Content  = "All assets loaded successfully!",
                Duration = 3,
                Type     = "Success",
            })
        end)
    end,
})

----------------------------------------------------------------
-- Tab 3: Keybinds
----------------------------------------------------------------
local KeybindTab = Window:CreateTab("Keybinds", 4483362458)

KeybindTab:CreateSection("Hotkeys")

KeybindTab:CreateKeybind({
    Name           = "Toggle Fly",
    CurrentKeybind = "F",
    Flag           = "flyKey",
    Callback       = function(key)
        print("Fly toggled via:", key)
    end,
})

KeybindTab:CreateKeybind({
    Name           = "Toggle Noclip",
    CurrentKeybind = "N",
    Flag           = "noclipKey",
    Callback       = function(key)
        print("Noclip toggled via:", key)
    end,
})

KeybindTab:CreateKeybind({
    Name           = "Quick Teleport",
    CurrentKeybind = "T",
    Flag           = "tpKey",
    Callback       = function(key)
        print("Teleport via:", key)
    end,
})

----------------------------------------------------------------
-- Tab 4: Info
----------------------------------------------------------------
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("About")

InfoTab:CreateParagraph({
    Title   = "AquaUI v2.0",
    Content = "A premium, feature-rich Roblox UI library with blue-teal theme, smooth animations, and advanced elements. Inspired by Rayfield but redesigned from the ground up.",
})

InfoTab:CreateParagraph({
    Title   = "Features",
    Content = "Window dragging, minimize, search, tabs, buttons, toggles, sliders, dropdowns (single & multi), text input, keybind picker, color picker, progress bars, sections, dividers, labels, paragraphs, notifications (info/success/warning/error), modal dialogs, tooltips, config save/load.",
})

local statusLabel = InfoTab:CreateLabel("Status: Ready")

InfoTab:CreateDivider()

InfoTab:CreateButton({
    Name     = "Show Info Notification",
    Callback = function()
        Window:Notify({Title = "Info", Content = "This is an info notification.", Duration = 3, Type = "Info"})
    end,
})

InfoTab:CreateButton({
    Name     = "Show Warning Notification",
    Callback = function()
        Window:Notify({Title = "Warning", Content = "This is a warning notification.", Duration = 3, Type = "Warning"})
    end,
})

InfoTab:CreateButton({
    Name     = "Show Error Notification",
    Callback = function()
        Window:Notify({Title = "Error", Content = "This is an error notification.", Duration = 3, Type = "Error"})
    end,
})

InfoTab:CreateButton({
    Name     = "Show Dialog",
    Callback = function()
        Window:Dialog({
            Title   = "Confirm Action",
            Content = "Are you sure you want to proceed? This action cannot be undone.",
            Buttons = {
                {Text = "Cancel", Callback = function()
                    statusLabel:Set("Status: Cancelled")
                end},
                {Text = "Confirm", Primary = true, Callback = function()
                    statusLabel:Set("Status: Confirmed!")
                    Window:Notify({Title = "Done", Content = "Action confirmed.", Duration = 2, Type = "Success"})
                end},
            },
        })
    end,
})

----------------------------------------------------------------
-- Tab 5: Settings
----------------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
    Name     = "Save Config",
    Callback = function()
        Window:SaveConfig()
        Window:Notify({Title = "Config", Content = "Configuration saved!", Duration = 2, Type = "Success"})
    end,
})

SettingsTab:CreateButton({
    Name     = "Load Config",
    Callback = function()
        Window:LoadConfig()
        Window:Notify({Title = "Config", Content = "Configuration loaded!", Duration = 2, Type = "Info"})
    end,
})

SettingsTab:CreateDivider()

SettingsTab:CreateParagraph({
    Title   = "Minimize Key",
    Content = "Press RightShift to toggle the window visibility. You can change this when creating the window.",
})

SettingsTab:CreateButton({
    Name     = "Destroy GUI",
    Callback = function()
        Window:Destroy()
    end,
})
