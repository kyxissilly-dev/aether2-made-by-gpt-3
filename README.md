# Aether Gen2

Aether Gen2 is a lightweight Roblox UI library focused on a clean, modern interface, smooth animations, simple APIs, and reusable stateful controls.

Current version:

```text
0.5.3
```

## Features

- Modern dark UI
- Animated windows and tabs
- Draggable window
- Minimize, hide, restore, and toggle controls
- Searchable tabs
- Profile display
- Theme overrides
- Built-in flags/state system
- Mouse and touch support
- Bottom-right notification stack
- Responsive Gen2-style sliders
- Automatic cleanup of managed connections

## Components

Aether currently includes:

- Windows
- Tabs
- Sections
- Toggles
- Buttons
- Textboxes
- Inputs
- Sliders
- Dropdowns
- Color pickers
- Keybinds
- Labels
- Paragraphs
- Notifications

## Loading Aether

```lua
local HttpService = game:GetService("HttpService")

local Aether = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kyxissilly-dev/aether2-made-by-gpt-3/refs/heads/main/AetherGen2.lua"
    .. "?nocache="
    .. HttpService:GenerateGUID()
))()
```

Check the loaded version:

```lua
print("Aether version:", Aether.Version)
```

## Quick Start

```lua
local HttpService = game:GetService("HttpService")

local Aether = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kyxissilly-dev/aether2-made-by-gpt-3/refs/heads/main/AetherGen2.lua"
    .. "?nocache="
    .. HttpService:GenerateGUID()
))()

local Window = Aether:CreateWindow({
    name = "Aether",
    subtitle = "Example UI",
    icon = "globe",
    size = Vector2.new(760, 520),
    showProfile = true,
    toggleKeybind = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab({
    name = "Main",
    icon = "globe",
})

Main:CreateSection("General")

local Enabled = Main:CreateToggle({
    name = "Enabled",
    flag = "enabled",
    value = false,
    callback = function(value)
        print("Enabled:", value)
    end,
})

local Speed = Main:CreateSlider({
    name = "Speed",
    flag = "speed",
    min = 10,
    max = 200,
    increment = 5,
    suffix = "studs/s",
    value = 70,
    callback = function(value)
        print("Speed:", value)
    end,
})

local Mode = Main:CreateDropdown({
    name = "Mode",
    flag = "mode",
    values = {
        "Normal",
        "Fast",
        "Extreme",
    },
    value = "Normal",
    callback = function(value)
        print("Mode:", value)
    end,
})

Main:CreateButton({
    name = "Notify",
    callback = function()
        Window:Notify({
            title = "Aether",
            description = "Everything is working.",
            type = "success",
            duration = 4,
        })
    end,
})
```

## Window

```lua
local Window = Aether:CreateWindow({
    name = "Aether",
    subtitle = "Example UI",
    icon = "globe",
    size = Vector2.new(760, 520),
    showProfile = true,
    toggleKeybind = Enum.KeyCode.RightShift,
})
```

Useful window methods:

```lua
Window:Minimize()
Window:Minimize(true)
Window:Minimize(false)

Window:Hide()
Window:Show()
Window:Toggle()

Window:Destroy()
```

## Tabs

```lua
local Visuals = Window:CreateTab({
    name = "Visuals",
    icon = "eye",
})
```

Select a tab manually:

```lua
Visuals:Select()
```

## Toggles

```lua
local Toggle = Visuals:CreateToggle({
    name = "Player ESP",
    flag = "playerESP",
    value = false,
    callback = function(value)
        print(value)
    end,
})
```

```lua
Toggle:Set(true)
Toggle:Set(false)
Toggle:Get()
Toggle:SetName("ESP")
```

Skip the callback when setting:

```lua
Toggle:Set(true, true)
```

## Buttons

```lua
local Button = Visuals:CreateButton({
    name = "Refresh",
    callback = function()
        print("clicked")
    end,
})
```

```lua
Button:Fire()
Button:SetName("Refresh ESP")
```

## Textboxes

```lua
local Username = Visuals:CreateTextbox({
    name = "Username",
    flag = "username",
    placeholder = "Type something",
    value = "",
    clearOnFocus = false,
    callback = function(value, enterPressed)
        print(value, enterPressed)
    end,
})
```

`CreateInput` is also available:

```lua
local Input = Visuals:CreateInput({
    name = "Numeric Input",
    numeric = true,
    value = "25",
})
```

```lua
Username:Set("kyx")
Username:Get()
Username:SetName("Display Name")
```

## Sliders

Aether sliders use a responsive Gen2-style layout with a rounded track, progress glow, animated handle, mouse support, and touch support.

```lua
local FlySpeed = Visuals:CreateSlider({
    name = "Fly Speed",
    flag = "flySpeed",
    min = 10,
    max = 200,
    increment = 5,
    suffix = "studs/s",
    value = 70,
    callback = function(value)
        print(value)
    end,
})
```

```lua
FlySpeed:Set(120)
FlySpeed:Get()
FlySpeed:SetName("Flight Speed")
```

Sliders automatically:

- clamp to the configured range
- snap to `increment`
- format decimal precision
- normalize suffix spacing
- support click-to-set
- support continuous dragging
- support mouse and touch
- switch to a narrow layout when needed

## Dropdowns

```lua
local Mode = Visuals:CreateDropdown({
    name = "Mode",
    flag = "mode",
    values = {
        "Normal",
        "Fast",
        "Extreme",
    },
    value = "Normal",
    callback = function(value)
        print(value)
    end,
})
```

```lua
Mode:Set("Fast")
Mode:Get()

Mode:SetValues({
    "One",
    "Two",
    "Three",
})

Mode:SetOpen(true)
Mode:SetOpen(false)
Mode:SetName("Movement Mode")
```

## Color Pickers

```lua
local Color = Visuals:CreateColorPicker({
    name = "ESP Color",
    flag = "espColor",
    value = Color3.fromRGB(23, 153, 110),
    callback = function(value)
        print(value)
    end,
})
```

```lua
Color:Set(Color3.fromRGB(255, 100, 120))
Color:Get()
Color:SetOpen(true)
Color:SetOpen(false)
Color:SetName("Highlight Color")
```

## Keybinds

```lua
local Keybind = Visuals:CreateKeybind({
    name = "ESP Key",
    flag = "espKey",
    value = Enum.KeyCode.E,

    changedCallback = function(key)
        print("New key:", key.Name)
    end,

    callback = function(key)
        print("Pressed:", key.Name)
    end,
})
```

```lua
Keybind:Set(Enum.KeyCode.F)
Keybind:Get()
Keybind:SetName("Toggle Key")
```

## Labels

```lua
local Status = Visuals:CreateLabel("Ready")
```

```lua
Status:Set("Updated")
```

## Paragraphs

```lua
local Info = Visuals:CreateParagraph({
    title = "Player ESP",
    text = "Highlights players and displays useful information.",
})
```

```lua
Info:Set(
    "Updated Title",
    "Updated paragraph text."
)
```

## Notifications

Notifications appear near the bottom-right of the screen and stack upward.

```lua
Window:Notify({
    title = "ESP",
    description = "Player ESP enabled.",
    type = "success",
    duration = 3,
})
```

Supported types:

```text
info
success
warning
error
danger
```

You can override the icon:

```lua
Window:Notify({
    title = "Visuals",
    description = "ESP settings updated.",
    type = "info",
    icon = "eye",
    duration = 4,
})
```

Notifications:

- pause their timer while hovered
- dismiss when clicked
- automatically size to wrapped content
- animate in and out
- stack upward
- keep a small live notification limit

### Notification Handle

```lua
local Notice = Window:Notify({
    title = "Closable",
    description = "This can be closed from code.",
    duration = 20,
})
```

Close it manually:

```lua
Notice.Close()
```

Advanced instance access:

```lua
print(Notice.Instance)
print(Notice.Body)
```

You can also use:

```lua
Aether:Notify({
    title = "Loaded",
    description = "Aether is ready.",
    type = "success",
})
```

`Aether:Notify` forwards to the most recently created live Aether window.

## Flags

Stateful controls integrate with the window flag system.

```lua
local value = Window:GetFlag("speed")
print(value)
```

Set a flag:

```lua
Window:SetFlag("speed", 100)
```

If the flag belongs to a control, the control itself is updated too.

You can also access the flag table directly:

```lua
print(Window.Flags.speed)
```

## Theme Overrides

```lua
local Window = Aether:CreateWindow({
    name = "Aether",

    theme = {
        Accent = Color3.fromRGB(100, 140, 255),
        AccentStroke = Color3.fromRGB(130, 165, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(190, 190, 190),
    },
})
```

Common theme keys include:

```text
Window
Window2
Sidebar

Element
Element2
ElementHover
ElementHoverStroke

Tab
TabBottom
TabStrokeTop
TabStrokeBottom

Stroke
StrokeSoft

Text
Secondary
Muted

Field
FieldHover

SliderBackground
SliderBackgroundHover
SliderHandle
SliderStroke

Accent
AccentStroke
AccentGlow

ToggleTrack
ToggleKnob
ToggleKnobOn

Danger
Warning
Success
Info

Shadow
Glow
```

## Built-In Icons

Aether currently includes basic built-in names such as:

```text
globe
eye
search
```

Roblox asset IDs are also supported:

```lua
icon = 123456789
```

or:

```lua
icon = "rbxassetid://123456789"
```

## API Quick Reference

```lua
Aether.Version

Aether:CreateWindow(options)
Aether:Notify(options)

Window:CreateTab(options)

Window:GetFlag(flag)
Window:SetFlag(flag, value)
Window:Notify(options)

Window:Minimize()
Window:Hide()
Window:Show()
Window:Toggle()
Window:Destroy()

Window.Flags

Tab:Select()

Tab:CreateSection(options)
Tab:CreateToggle(options)
Tab:CreateButton(options)
Tab:CreateTextbox(options)
Tab:CreateInput(options)
Tab:CreateSlider(options)
Tab:CreateDropdown(options)
Tab:CreateColorPicker(options)
Tab:CreateKeybind(options)
Tab:CreateLabel(options)
Tab:CreateParagraph(options)

Section:Set(name)

Toggle:Set(value)
Toggle:Get()
Toggle:SetName(name)

Button:Fire()
Button:SetName(name)

Textbox:Set(value)
Textbox:Get()
Textbox:SetName(name)

Slider:Set(value)
Slider:Get()
Slider:SetName(name)

Dropdown:Set(value)
Dropdown:Get()
Dropdown:SetValues(values)
Dropdown:SetOpen(state)
Dropdown:SetName(name)

ColorPicker:Set(value)
ColorPicker:Get()
ColorPicker:SetOpen(state)
ColorPicker:SetName(name)

Keybind:Set(keyCode)
Keybind:Get()
Keybind:SetName(name)

Label:Set(text)

Paragraph:Set(body)
Paragraph:Set(title, body)

Notification.Close()
Notification.Instance
Notification.Body
```

## Documentation

For the full API documentation, see [`docs.md`](./docs.md).

## Repository Layout

```text
AetherGen2.lua
README.md
docs.md
```

## Notes

- Creating a new Aether window removes an existing `AetherGen2` GUI under the same parent.
- Stateful controls can be managed with `Window:GetFlag` and `Window:SetFlag`.
- Control callbacks are protected so a callback error does not immediately break the entire UI.
- Popups automatically close when another popup is opened.
- Sliders are responsive and support mouse and touch dragging.
- Notifications are screen-level rather than attached to the window.
- Aether cleans up its managed connections when destroyed.

## License

Add your preferred license to the repository if you plan to distribute Aether publicly.
