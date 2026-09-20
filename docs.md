# Aether Gen2 Documentation

Aether Gen2 is a lightweight Roblox UI library for creating modern windows, tabs, controls, popups, and screen notifications.

Current library version:

```lua
print(Aether.Version)
```

The current release is:

```text
0.5.3
```

---

## Loading Aether

```lua
local HttpService = game:GetService("HttpService")

local Aether = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kyxissilly-dev/aether2-made-by-gpt-3/refs/heads/main/AetherGen2.lua"
    .. "?nocache="
    .. HttpService:GenerateGUID()
))()
```

You can check the loaded version with:

```lua
print("Aether version:", Aether.Version)
```

---

# Window

## Creating a Window

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

### Window options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Aether"` | Window title |
| `subtitle` | `string` | `""` | Smaller text below the title |
| `icon` | `string` / asset id | `"globe"` | Window icon |
| `size` | `Vector2` / `UDim2` | `685x450` | Window size |
| `theme` | `table` | default theme | Overrides supported theme values |
| `parent` | `Instance` | automatic | GUI parent |
| `showProfile` | `boolean` | `true` | Shows or hides the profile area |
| `toggleKeybind` | `Enum.KeyCode` | none | Key used to hide/show the window |

Aether accepts both lowercase and capitalized option names, for example:

```lua
name = "Aether"
```

and:

```lua
Name = "Aether"
```

### Custom size

```lua
local Window = Aether:CreateWindow({
    name = "My UI",
    size = Vector2.new(800, 500),
})
```

The minimum window size is approximately `560x350`.

---

## Window Methods

### Minimize

Toggle the minimized state:

```lua
Window:Minimize()
```

Force minimized:

```lua
Window:Minimize(true)
```

Restore:

```lua
Window:Minimize(false)
```

### Hide

```lua
Window:Hide()
```

When hidden, Aether collapses into its restore control.

### Show

```lua
Window:Show()
```

### Toggle visibility

```lua
Window:Toggle()
```

### Destroy

```lua
Window:Destroy()
```

Destroying the window disconnects Aether-managed connections and removes its UI, popups, and notifications.

---

# Tabs

## Creating a Tab

```lua
local MainTab = Window:CreateTab({
    name = "Main",
    icon = "globe",
})
```

### Tab options

| Option | Type | Description |
|---|---|---|
| `name` | `string` | Tab name |
| `icon` | `string` / asset id | Tab icon |

The first tab created is selected automatically.

### Select a tab

```lua
MainTab:Select()
```

---

# Icons

Aether includes several built-in icon names:

```lua
"globe"
"eye"
"search"
```

You can also use a Roblox asset id:

```lua
icon = 123456789
```

or:

```lua
icon = "rbxassetid://123456789"
```

If an unknown string is used where Aether cannot resolve an asset, it falls back to a simple text-based icon.

---

# Sections

Sections are labels used to organize controls.

```lua
local Section = MainTab:CreateSection({
    name = "General",
})
```

You can also pass a string directly:

```lua
local Section = MainTab:CreateSection("General")
```

### Rename a section

```lua
Section:Set("Updated Section")
```

---

# Toggles

```lua
local Toggle = MainTab:CreateToggle({
    name = "Example Toggle",
    flag = "exampleToggle",
    value = false,
    callback = function(value)
        print("Toggle:", value)
    end,
})
```

### Toggle options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Toggle name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `value` | `boolean` | `false` | Starting state |
| `callback` | `function` | empty function | Called when the value changes |

`currentValue` / `CurrentValue` can also be used instead of `value`.

### Get

```lua
local enabled = Toggle:Get()
```

### Set

```lua
Toggle:Set(true)
Toggle:Set(false)
```

`Set` normally calls the callback.

Skip the callback:

```lua
Toggle:Set(true, true)
```

### Rename

```lua
Toggle:SetName("New Toggle Name")
```

---

# Textboxes / Inputs

`CreateTextbox` creates a text input control.

```lua
local Username = MainTab:CreateTextbox({
    name = "Username",
    flag = "username",
    placeholder = "Type something",
    value = "",
    clearOnFocus = false,
    callback = function(value, enterPressed)
        print("Value:", value)
        print("Pressed Enter:", enterPressed)
    end,
})
```

`CreateInput` is an alias of `CreateTextbox`:

```lua
local Input = MainTab:CreateInput({
    name = "Input",
    placeholder = "Enter text",
})
```

### Textbox options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Control name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `placeholder` | `string` | `"Type here"` | Placeholder text |
| `value` | any convertible to string | `""` | Initial value |
| `numeric` | `boolean` | `false` | Only accepts numeric text when enabled |
| `clearOnFocus` | `boolean` | `false` | Clears the box when focused |
| `callback` | `function` | empty function | Receives `value, enterPressed` |

`default` / `Default` can also be used for the starting value.

### Numeric input

```lua
local Amount = MainTab:CreateInput({
    name = "Amount",
    flag = "amount",
    value = "25",
    numeric = true,
    callback = function(value)
        print("Amount:", value)
    end,
})
```

If invalid numeric text is entered, Aether restores the previous valid value.

### Get

```lua
print(Username:Get())
```

### Set

```lua
Username:Set("kyx")
```

Skip the callback:

```lua
Username:Set("kyx", true)
```

### Rename

```lua
Username:SetName("Display Name")
```

---

# Sliders

Aether's slider uses the Gen 2-style layout with a formatted value, responsive track, progress glow, animated handle, mouse support, and touch support.

```lua
local FlySpeed = MainTab:CreateSlider({
    name = "Fly Speed",
    flag = "flySpeed",
    min = 10,
    max = 200,
    increment = 5,
    suffix = " studs/s",
    value = 70,
    callback = function(value)
        print("Fly speed:", value)
    end,
})
```

### Slider options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Slider name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `min` | `number` | `0` | Minimum value |
| `max` | `number` | `100` | Maximum value |
| `increment` | `number` | `1` | Snapping step |
| `step` | `number` | `1` | Alias for `increment` |
| `suffix` | `string` | `""` | Text displayed after the number |
| `value` | `number` | minimum | Initial value |
| `callback` | `function` | empty function | Called whenever the value changes |

`currentValue`, `default`, and their capitalized versions are accepted as starting-value aliases.

The slider automatically:

- clamps to `min` / `max`
- snaps to `increment`
- formats decimal precision from `increment`
- normalizes suffix spacing
- updates while dragging
- supports clicking anywhere on the track
- supports mouse and touch

### Examples

Integer slider:

```lua
MainTab:CreateSlider({
    name = "Walk Speed",
    min = 16,
    max = 100,
    increment = 1,
    value = 32,
})
```

Decimal slider:

```lua
MainTab:CreateSlider({
    name = "Opacity",
    min = 0,
    max = 1,
    increment = 0.01,
    value = 0.75,
})
```

Suffix:

```lua
MainTab:CreateSlider({
    name = "Fly Speed",
    min = 10,
    max = 200,
    increment = 5,
    suffix = "studs/s",
    value = 70,
})
```

Both `"studs/s"` and `" studs/s"` display cleanly.

### Get

```lua
print(FlySpeed:Get())
```

### Set

```lua
FlySpeed:Set(120)
```

`Set` clamps and snaps the supplied number before storing it.

Skip the callback:

```lua
FlySpeed:Set(120, true)
```

### Rename

```lua
FlySpeed:SetName("Flight Speed")
```

---

# Dropdowns

```lua
local Mode = MainTab:CreateDropdown({
    name = "Mode",
    flag = "mode",
    values = {
        "Normal",
        "Fast",
        "Insane",
    },
    value = "Normal",
    callback = function(value)
        print("Mode:", value)
    end,
})
```

### Dropdown options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Dropdown name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `values` | `table` | `{}` | Available values |
| `options` | `table` | `{}` | Alias for `values` |
| `value` | any | first value | Initial selection |
| `callback` | `function` | empty function | Called when the selection changes |

`default` / `Default` can also be used for the initial value.

### Get

```lua
print(Mode:Get())
```

### Set

```lua
Mode:Set("Fast")
```

Skip callback:

```lua
Mode:Set("Fast", true)
```

### Replace available values

```lua
Mode:SetValues({
    "One",
    "Two",
    "Three",
})
```

If the current selection no longer exists, Aether silently selects the first new value.

### Open or close the dropdown

```lua
Mode:SetOpen(true)
Mode:SetOpen(false)
```

### Rename

```lua
Mode:SetName("Movement Mode")
```

---

# Color Pickers

```lua
local ESPColor = MainTab:CreateColorPicker({
    name = "ESP Color",
    flag = "espColor",
    value = Color3.fromRGB(23, 153, 110),
    callback = function(color)
        print("Color:", color)
    end,
})
```

The control includes:

- a color swatch
- editable hex input
- saturation/value picker
- hue strip
- RGB readout

### Color picker options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Color picker name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `value` | `Color3` | current theme accent | Initial color |
| `callback` | `function` | empty function | Called with the selected `Color3` |

`default` / `Default` can also be used for the starting color.

### Get

```lua
local color = ESPColor:Get()
```

### Set

```lua
ESPColor:Set(Color3.fromRGB(255, 90, 120))
```

Skip callback:

```lua
ESPColor:Set(Color3.fromRGB(255, 90, 120), true)
```

### Open or close the picker

```lua
ESPColor:SetOpen(true)
ESPColor:SetOpen(false)
```

### Rename

```lua
ESPColor:SetName("Highlight Color")
```

---

# Keybinds

```lua
local ESPKeybind = MainTab:CreateKeybind({
    name = "ESP Toggle Key",
    flag = "espKey",
    value = Enum.KeyCode.E,

    changedCallback = function(key)
        print("New key:", key.Name)
    end,

    callback = function(key)
        print("Key pressed:", key.Name)
    end,
})
```

### Keybind options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Element"` | Keybind name |
| `icon` | `string` / asset id | none | Optional icon |
| `flag` | `string` | generated | Flag used by the window |
| `value` | `Enum.KeyCode` | `Enum.KeyCode.Unknown` | Bound key |
| `callback` | `function` | empty function | Called when the bound key is pressed |
| `changedCallback` | `function` | empty function | Called when the binding changes |

Click the keybind field and press a keyboard key to rebind it.

Press `Escape` or `Backspace` while listening to clear the keybind.

### Get

```lua
local key = ESPKeybind:Get()
```

### Set

```lua
ESPKeybind:Set(Enum.KeyCode.F)
```

Calling `Set` triggers `changedCallback`, not the normal key-pressed callback.

Skip `changedCallback`:

```lua
ESPKeybind:Set(Enum.KeyCode.F, true)
```

Clear programmatically:

```lua
ESPKeybind:Set(Enum.KeyCode.Unknown)
```

### Rename

```lua
ESPKeybind:SetName("Menu Key")
```

---

# Labels

Create simple text:

```lua
local Status = MainTab:CreateLabel({
    text = "Waiting...",
})
```

You can also pass a string:

```lua
local Status = MainTab:CreateLabel("Waiting...")
```

### Change label text

```lua
Status:Set("Ready")
```

---

# Paragraphs

Paragraphs display a title and wrapped body text.

```lua
local Help = MainTab:CreateParagraph({
    title = "Movement",
    text = "Use WASD to move while fly is enabled.",
})
```

`content` / `Content` can be used instead of `text`.

### Change title and body

```lua
Help:Set(
    "Updated Title",
    "Updated paragraph text."
)
```

### Set body only

If only one argument is supplied, it becomes the paragraph body and the title is removed:

```lua
Help:Set("Body text only")
```

---

# Buttons

```lua
local TestButton = MainTab:CreateButton({
    name = "Test Button",
    callback = function()
        print("button pressed")
    end,
})
```

### Button options

| Option | Type | Description |
|---|---|---|
| `name` | `string` | Button name |
| `icon` | `string` / asset id | Optional icon |
| `callback` | `function` | Function called when clicked |

### Fire manually

```lua
TestButton:Fire()
```

### Rename

```lua
TestButton:SetName("New Button Name")
```

---

# Notifications

Aether notifications appear as a bottom-right screen stack and are independent of the window's position.

```lua
Window:Notify({
    title = "ESP",
    description = "Player ESP enabled.",
    type = "success",
    duration = 2.5,
})
```

### Notification options

| Option | Type | Default | Description |
|---|---|---|---|
| `title` | `string` | `"Notification"` | Notification title |
| `description` | `string` | `""` | Notification body |
| `content` | `string` | `""` | Alias for `description` |
| `text` | `string` | `""` | Alias for `description` |
| `type` | `string` | `"info"` | Notification style |
| `duration` | `number` | automatic | Visible lifetime in seconds |
| `icon` | `string` / asset id | automatic | Explicit icon override |

Supported notification types:

```text
info
success
warning
error
danger
```

The notification surface stays neutral. The type mainly changes the status icon/accent.

If `duration` is omitted, Aether chooses a duration based on the description length.

Notifications:

- stack upward from the bottom-right
- pause their lifetime while hovered
- can be clicked/tapped to dismiss
- wrap long title and description text
- automatically dismiss the oldest notification when more than 6 are active

### Explicit icon

```lua
Window:Notify({
    title = "Visuals",
    description = "ESP settings updated.",
    type = "info",
    icon = "eye",
    duration = 4,
})
```

### Notification handle

`Window:Notify` returns a notification handle:

```lua
local Notice = Window:Notify({
    title = "Closable",
    description = "This can be closed from code.",
    duration = 20,
})
```

Dismiss it manually:

```lua
Notice.Close()
```

The handle also exposes the notification instances used by the UI:

```lua
print(Notice.Instance)
print(Notice.Body)
```

Treat those instances as advanced access. `Close()` is the intended public dismissal method.

---

## Global Notification Shortcut

After a window has been created, you can call:

```lua
Aether:Notify({
    title = "Loaded",
    description = "Aether is ready.",
    type = "success",
})
```

`Aether:Notify` forwards the notification to the most recently created live Aether window.

If no live Aether window exists, it returns `nil` and warns.

---

# Flags

All stateful controls register their value in the window flag system.

This includes:

- toggles
- textboxes / inputs
- sliders
- dropdowns
- color pickers
- keybinds

Example:

```lua
local Slider = MainTab:CreateSlider({
    name = "Speed",
    flag = "speed",
    min = 0,
    max = 100,
    value = 25,
})
```

### Read a flag

```lua
local speed = Window:GetFlag("speed")
print(speed)
```

You can also read the table directly:

```lua
print(Window.Flags.speed)
```

### Set a flag

```lua
Window:SetFlag("speed", 80)
```

If the flag belongs to a control with a `Set` method, Aether updates the actual control too.

This means:

```lua
Window:SetFlag("speed", 80)
```

updates both:

- `Window.Flags.speed`
- the slider's value and visual position

The control callback is also called because `SetFlag` uses the control's normal `Set` behavior.

### Automatic flags

If no flag is supplied, Aether generates one from the control name.

For example:

```lua
name = "Enable ESP"
```

becomes approximately:

```lua
enable_esp
```

Duplicate flags are automatically renamed by appending a number.

---

# Search

The search button in the top bar filters controls in the currently selected tab.

Search matches control names.

Sections are hidden while a search is active.

---

# Window Toggle Keybind

A window can be assigned a key that hides and shows it:

```lua
local Window = Aether:CreateWindow({
    name = "Aether",
    toggleKeybind = Enum.KeyCode.RightShift,
})
```

Pressing the key calls the window's visibility toggle behavior.

---

# Theme Overrides

You can override supported theme values when creating the window.

```lua
local Window = Aether:CreateWindow({
    name = "Aether",

    theme = {
        Accent = Color3.fromRGB(100, 140, 255),
        AccentStroke = Color3.fromRGB(130, 165, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(190, 190, 190),
        SliderHandle = Color3.fromRGB(255, 255, 255),
    },
})
```

### Theme keys

```lua
Window
Window2
Sidebar

Element
Element2
ElementHover
ElementHoverStroke
ElementTransparency
ElementStrokeTransparency
ElementStrokeHoverTransparency

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
ToggleTrackTransparency
ToggleKnob
ToggleKnobOn
ToggleKnobOffTransparency

Danger
Warning
Success
Info

Shadow
Glow
```

A theme override is only applied when the supplied value has the same Roblox type as the default theme value.

---

# Full API Example

```lua
local HttpService = game:GetService("HttpService")

local Aether = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kyxissilly-dev/aether2-made-by-gpt-3/refs/heads/main/AetherGen2.lua"
    .. "?nocache="
    .. HttpService:GenerateGUID()
))()

local Window = Aether:CreateWindow({
    name = "Aether",
    subtitle = "API Example",
    icon = "globe",
    size = Vector2.new(760, 520),
    showProfile = true,
    toggleKeybind = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab({
    name = "Main",
    icon = "globe",
})

Main:CreateSection("Controls")

local Enabled = Main:CreateToggle({
    name = "Enabled",
    flag = "enabled",
    value = false,
    callback = function(value)
        print("Enabled:", value)
    end,
})

local NameInput = Main:CreateTextbox({
    name = "Name",
    flag = "name",
    placeholder = "Enter a name",
    callback = function(value, enterPressed)
        print(value, enterPressed)
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
    values = {"Normal", "Fast", "Extreme"},
    value = "Normal",
    callback = function(value)
        print("Mode:", value)
    end,
})

local Color = Main:CreateColorPicker({
    name = "Accent Color",
    flag = "color",
    value = Color3.fromRGB(23, 153, 110),
    callback = function(value)
        print("Color:", value)
    end,
})

local Bind = Main:CreateKeybind({
    name = "Action Key",
    flag = "actionKey",
    value = Enum.KeyCode.E,
    callback = function(key)
        Window:Notify({
            title = "Keybind",
            description = key.Name .. " was pressed.",
            type = "info",
        })
    end,
    changedCallback = function(key)
        print("New bind:", key.Name)
    end,
})

local Status = Main:CreateLabel("Ready")

local Info = Main:CreateParagraph({
    title = "Aether",
    text = "This example demonstrates the main control APIs.",
})

local Button = Main:CreateButton({
    name = "Show Values",
    callback = function()
        print("Enabled:", Enabled:Get())
        print("Name:", NameInput:Get())
        print("Speed:", Speed:Get())
        print("Mode:", Mode:Get())
        print("Color:", Color:Get())
        print("Bind:", Bind:Get())

        Status:Set("Values printed")

        Window:Notify({
            title = "Done",
            description = "Current control values were printed.",
            type = "success",
            duration = 4,
        })
    end,
})
```

---

# API Quick Reference

```lua
Aether.Version

Aether:CreateWindow(options)
Aether:Notify(options)

Window:CreateTab(options)
Window:GetFlag(flag)
Window:SetFlag(flag, value)

Window:Notify(options)

Window:Minimize()
Window:Minimize(true)
Window:Minimize(false)
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
Toggle:Set(value, skipCallback)
Toggle:Get()
Toggle:SetName(name)

Button:Fire()
Button:SetName(name)

Textbox:Set(value)
Textbox:Set(value, skipCallback)
Textbox:Get()
Textbox:SetName(name)

Slider:Set(value)
Slider:Set(value, skipCallback)
Slider:Get()
Slider:SetName(name)

Dropdown:Set(value)
Dropdown:Set(value, skipCallback)
Dropdown:Get()
Dropdown:SetValues(values)
Dropdown:SetOpen(state)
Dropdown:SetName(name)

ColorPicker:Set(value)
ColorPicker:Set(value, skipCallback)
ColorPicker:Get()
ColorPicker:SetOpen(state)
ColorPicker:SetName(name)

Keybind:Set(keyCode)
Keybind:Set(keyCode, skipChangedCallback)
Keybind:Get()
Keybind:SetName(name)

Label:Set(text)

Paragraph:Set(bodyText)
Paragraph:Set(titleText, bodyText)

Notification.Close()
Notification.Instance
Notification.Body
```

---

# Notes

- Creating a new Aether window removes an existing `AetherGen2` GUI under the same parent.
- Control callbacks are protected so callback errors are warned instead of immediately breaking the UI.
- Stateful controls integrate with `Window.Flags`, `Window:GetFlag`, and `Window:SetFlag`.
- Dropdown and color-picker popups automatically close when another popup is opened.
- The slider is responsive and changes layout when the available row width is too narrow for the desktop layout.
- Slider dragging supports mouse and touch and only uses its active drag update connection while being dragged.
- Notifications are screen-level, bottom-right, hover-paused, clickable, and limited to approximately six live notifications.
- `Aether:Notify` requires a previously created live Aether window.
