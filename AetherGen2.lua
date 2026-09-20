local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Aether = {}
Aether.__index = Aether
Aether.Version = "0.5.3"

local DefaultTheme = {
    Window = Color3.fromRGB(18, 18, 19),
    Window2 = Color3.fromRGB(22, 22, 23),
    Sidebar = Color3.fromRGB(17, 17, 18),
    Element = Color3.fromRGB(30, 30, 30),
    Element2 = Color3.fromRGB(35, 35, 35),
    ElementHover = Color3.fromRGB(255, 255, 255),
    ElementHoverStroke = Color3.fromRGB(50, 50, 50),
    ElementTransparency = 0,
    ElementStrokeTransparency = 0,
    ElementStrokeHoverTransparency = 0,
    Tab = Color3.fromRGB(50, 50, 50),
    TabBottom = Color3.fromRGB(35, 35, 35),
    TabStrokeTop = Color3.fromRGB(95, 95, 95),
    TabStrokeBottom = Color3.fromRGB(50, 50, 50),
    Stroke = Color3.fromRGB(35, 35, 35),
    StrokeSoft = Color3.fromRGB(62, 62, 67),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(178, 178, 178),
    Muted = Color3.fromRGB(112, 112, 119),
    Field = Color3.fromRGB(24, 24, 25),
    FieldHover = Color3.fromRGB(29, 29, 30),
    SliderBackground = Color3.fromRGB(47, 47, 47),
    SliderBackgroundHover = Color3.fromRGB(60, 60, 60),
    SliderHandle = Color3.fromRGB(255, 255, 255),
    SliderStroke = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(23, 153, 110),
    AccentStroke = Color3.fromRGB(32, 201, 144),
    AccentGlow = 0.4,
    ToggleTrack = Color3.fromRGB(0, 0, 0),
    ToggleTrackTransparency = 0.9,
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    ToggleKnobOn = Color3.fromRGB(23, 153, 110),
    ToggleKnobOffTransparency = 0.8,
    Danger = Color3.fromRGB(215, 115, 120),
    Warning = Color3.fromRGB(231, 174, 70),
    Success = Color3.fromRGB(75, 190, 125),
    Info = Color3.fromRGB(86, 145, 230),
    Shadow = Color3.fromRGB(20, 20, 20),
    Glow = Color3.fromRGB(255, 255, 255)
}

local Layout = {
    Width = 685,
    Height = 450,
    TopbarHeight = 64,
    RailWidth = 219,
    RowHeight = 38,
    RowCorner = 14,
    RowSpacing = 4,
    RailPadding = 17,
    RowInset = 15,
    RowPadding = 10,
    RowContentSpacing = 6,
    RowIconSize = 20,
    FooterHeight = 60,
    AvatarSize = 34,
    ElementHeight = 43,
    ElementInset = 10,
    ElementContentInset = 20,
    ActionReserve = 118,
    SearchReserve = 346
}

local Tweens = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Hover = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Move = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
    Reveal = TweenInfo.new(0.42, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
}

local function create(className, properties)
    local object = Instance.new(className)
    local parent

    for property, value in pairs(properties or {}) do
        if property == "Parent" then
            parent = value
        else
            object[property] = value
        end
    end

    if object:IsA("GuiObject") and not (properties and properties.BorderSizePixel ~= nil) then
        object.BorderSizePixel = 0
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius)
    })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function shadow(parent, color, blur, transparency, offset, spread)
    local ok, result = pcall(function()
        return create("UIShadow", {
            Parent = parent,
            Color = color,
            BlurRadius = UDim.new(0, blur or 20),
            Transparency = transparency == nil and 1 or transparency,
            Offset = offset,
            Spread = spread,
            ZIndex = -1
        })
    end)

    return ok and result or nil
end

local function tween(object, info, properties)
    if not object then
        return nil
    end

    local ok, result = pcall(TweenService.Create, TweenService, object, info, properties)
    if not ok or not result then
        warn("Aether tween error: " .. tostring(result))
        return nil
    end

    result:Play()
    return result
end

local function option(options, ...)
    if type(options) ~= "table" then
        return nil
    end

    for index = 1, select("#", ...) do
        local key = select(index, ...)
        if options[key] ~= nil then
            return options[key]
        end
    end

    return nil
end

local function cloneTheme(customTheme)
    local theme = table.clone(DefaultTheme)

    if type(customTheme) == "table" then
        for key, value in pairs(customTheme) do
            if theme[key] ~= nil and typeof(value) == typeof(theme[key]) then
                theme[key] = value
            end
        end
    end

    return theme
end

local function font(weight)
    local ok, builder = pcall(Font.fromEnum, Enum.Font.BuilderSans)
    if ok and builder then
        return Font.new(builder.Family, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    end

    local fallback = Font.fromEnum(Enum.Font.Gotham)
    return Font.new(fallback.Family, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end

local FontMedium = font(Enum.FontWeight.Medium)
local FontSemiBold = font(Enum.FontWeight.SemiBold)
local FontRegular = font(Enum.FontWeight.Regular)

local function resolveAsset(asset)
    if type(asset) == "number" then
        return "rbxassetid://" .. tostring(asset)
    end

    if type(asset) ~= "string" then
        return nil
    end

    if asset:match("^%d+$") then
        return "rbxassetid://" .. asset
    end

    if asset:match("^rbxassetid://") or asset:match("^rbxthumb://") or asset:match("^rbxasset://") then
        return asset
    end

    return nil
end

local function makeEyeIcon(parent, color, size)
    local container = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    })

    local outline = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.floor(size * 0.9), math.floor(size * 0.56)),
        BackgroundTransparency = 1
    })

    corner(outline, size)
    stroke(outline, color, 0.12, 1.25)

    local pupil = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.max(4, math.floor(size * 0.23)), math.max(4, math.floor(size * 0.23))),
        BackgroundColor3 = color
    })

    corner(pupil, size)
    return container
end

local function makeGlobeIcon(parent, color, size)
    local container = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    })

    local outer = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size - 2, size - 2),
        BackgroundTransparency = 1
    })

    corner(outer, size)
    stroke(outer, color, 0.16, 1.2)

    local center = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.floor(size * 0.36), size - 4),
        BackgroundTransparency = 1
    })

    corner(center, size)
    stroke(center, color, 0.3, 1)

    create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size - 5, 1),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.3
    })

    return container
end

local function makeSearchIcon(parent, color, size)
    local container = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    })

    local ring = create("Frame", {
        Parent = container,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(size - 7, size - 7),
        BackgroundTransparency = 1
    })

    corner(ring, size)
    stroke(ring, color, 0.15, 1.35)

    create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(math.floor(size * 0.38), 1),
        Rotation = 45,
        BackgroundColor3 = color,
        BackgroundTransparency = 0.12
    })

    return container
end

local function makeLetterIcon(parent, text, color, size)
    return create("TextLabel", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Text = string.upper(string.sub(tostring(text or "?"), 1, 1)),
        TextColor3 = color,
        TextTransparency = 0.15,
        TextSize = math.max(12, size - 4),
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })
end

local function makeIcon(parent, asset, color, size, fallback)
    local resolved = resolveAsset(asset)

    if resolved then
        return create("ImageLabel", {
            Parent = parent,
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            Image = resolved,
            ImageColor3 = color,
            ImageTransparency = 0.08,
            ScaleType = Enum.ScaleType.Fit
        })
    end

    local name = type(asset) == "string" and string.lower(asset) or nil

    if name == "eye" then
        return makeEyeIcon(parent, color, size)
    elseif name == "globe" then
        return makeGlobeIcon(parent, color, size)
    elseif name == "search" then
        return makeSearchIcon(parent, color, size)
    end

    return makeLetterIcon(parent, fallback, color, size)
end

local function makeCloseIcon(parent, color)
    local container = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1
    })

    local a = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 1),
        Rotation = 45,
        BackgroundColor3 = color
    })

    local b = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 1),
        Rotation = -45,
        BackgroundColor3 = color
    })

    return container, a, b
end

local function makeMinimizeIcon(parent, color)
    local container = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1
    })

    local horizontal = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 1),
        BackgroundColor3 = color
    })

    local vertical = create("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, 11),
        BackgroundColor3 = color,
        BackgroundTransparency = 1
    })

    return container, horizontal, vertical
end

local function resolveParent(options)
    local customParent = option(options, "parent", "Parent")
    if customParent and typeof(customParent) == "Instance" then
        return customParent
    end

    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    return game:GetService("CoreGui")
end

local function colorToHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function hexToColor(value)
    value = tostring(value or ""):gsub("#", ""):gsub("%s", "")

    if #value == 3 then
        value = value:sub(1, 1):rep(2) .. value:sub(2, 2):rep(2) .. value:sub(3, 3):rep(2)
    end

    if #value ~= 6 or not value:match("^[%da-fA-F]+$") then
        return nil
    end

    return Color3.fromRGB(
        tonumber(value:sub(1, 2), 16),
        tonumber(value:sub(3, 4), 16),
        tonumber(value:sub(5, 6), 16)
    )
end

local function measureTextHeight(text, fontFace, textSize, width)
    text = tostring(text or "")

    if text == "" then
        return 0
    end

    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = fontFace
    params.Size = textSize
    params.Width = math.max(width, 1)

    local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
    params:Destroy()

    if ok and bounds then
        return math.max(textSize, math.ceil(bounds.Y))
    end

    local approximateCharacters = math.max(1, math.floor(width / math.max(textSize * 0.52, 1)))
    local lines = math.max(1, math.ceil(#text / approximateCharacters))
    return math.ceil(lines * textSize * 1.2)
end

local function sliderDecimalPlaces(increment)
    local decimals = 0

    while decimals < 6 do
        local scaled = increment * 10 ^ decimals
        if math.abs(scaled - math.round(scaled)) < 1e-9 then
            break
        end
        decimals += 1
    end

    return decimals
end

local function snapSliderValue(minimum, maximum, increment, value)
    local snapped = minimum + math.round((value - minimum) / increment) * increment
    return math.clamp(snapped, minimum, maximum)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Toggle = {}
Toggle.__index = Toggle

local Button = {}
Button.__index = Button

local Textbox = {}
Textbox.__index = Textbox

local Slider = {}
Slider.__index = Slider

local Dropdown = {}
Dropdown.__index = Dropdown

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local Keybind = {}
Keybind.__index = Keybind

local Label = {}
Label.__index = Label

local Paragraph = {}
Paragraph.__index = Paragraph

local function registerConnection(window, connection)
    table.insert(window._connections, connection)
    return connection
end

local function safeCallback(label, callback, ...)
    local args = table.pack(...)
    task.spawn(function()
        local ok, result = pcall(callback, table.unpack(args, 1, args.n))
        if not ok then
            warn("Aether " .. label .. " callback error: " .. tostring(result))
        end
    end)
end

local function setTabVisual(tab, state, instant)
    local states = {
        selected = {
            background = 0.4,
            stroke = 0.5,
            content = 0,
            shadow = 0.8
        },
        hover = {
            background = 0.7,
            stroke = 0.8,
            content = 0.3,
            shadow = 1
        },
        unselected = {
            background = 1,
            stroke = 1,
            content = 0.5,
            shadow = 1
        }
    }

    local visual = states[state] or states.unselected

    local function apply(object, properties)
        if not object then
            return
        end

        if instant then
            for property, value in pairs(properties) do
                object[property] = value
            end
        else
            tween(object, Tweens.Hover, properties)
        end
    end

    apply(tab.selector, {BackgroundTransparency = visual.background})
    apply(tab.selectorStroke, {Transparency = visual.stroke})
    apply(tab.selectorTitle, {TextTransparency = visual.content})
    apply(tab.selectorShadow, {Transparency = visual.shadow})
    apply(tab.selectorIcon, {GroupTransparency = visual.content})
end

function Tab:Select()
    if self.window.selectedTab == self then
        return self
    end

    local previous = self.window.selectedTab
    self.window.selectedTab = self

    if previous then
        previous.page.Visible = false
        setTabVisual(previous, "unselected", false)
    end

    self.page.Visible = true
    setTabVisual(self, "selected", false)
    self.window:_applySearch(self.window.searchBox.Text)

    return self
end

function Tab:_addElement(element)
    table.insert(self.elements, element)
    element.main.LayoutOrder = #self.elements * 10

    if self.window.selectedTab == self and self.window.searchBox and self.window.searchBox.Text ~= "" then
        self.window:_applySearch(self.window.searchBox.Text)
    end

    return element
end

function Tab:CreateSection(options)
    local name = type(options) == "string" and options or option(options, "name", "Name") or "Section"
    local topPadding = #self.elements > 0 and 13 or 0

    local main = create("Frame", {
        Parent = self.page,
        Size = UDim2.new(1, -40, 0, 20 + topPadding),
        BackgroundTransparency = 1
    })

    local text = create("TextLabel", {
        Parent = main,
        Position = UDim2.fromOffset(0, topPadding),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.window.theme.Text,
        TextTransparency = 0.42,
        TextSize = 15,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local element = {
        main = main,
        label = text,
        name = name,
        isSection = true,
        searchName = ""
    }

    function element:Set(value)
        self.name = tostring(value)
        self.label.Text = self.name
    end

    return self:_addElement(element)
end

local function createBaseElement(tab, height, options, actionReserve)
    local window = tab.window
    local name = option(options, "name", "Name") or "Element"
    local icon = option(options, "icon", "Icon")
    actionReserve = actionReserve or Layout.ElementContentInset

    local main = create("Frame", {
        Parent = tab.page,
        Size = UDim2.new(1, -20, 0, height),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = window.theme.ElementTransparency
    })

    corner(main, 12)

    local gradient = create("UIGradient", {
        Parent = main,
        Rotation = 270,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, window.theme.Element),
            ColorSequenceKeypoint.new(0.9999, window.theme.Element2),
            ColorSequenceKeypoint.new(1, window.theme.Element2)
        })
    })

    local mainStroke = stroke(main, window.theme.Stroke, window.theme.ElementStrokeTransparency, 1)

    local hover = create("Frame", {
        Parent = main,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        ZIndex = 1
    })

    corner(hover, 12)

    local contentWidth = math.max(40, window.size.X - Layout.RailWidth - Layout.ElementContentInset - actionReserve - 20)

    local content = create("Frame", {
        Parent = main,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, Layout.ElementContentInset, 0.5, 0),
        Size = UDim2.fromOffset(contentWidth, 20),
        BackgroundTransparency = 1,
        ZIndex = 4
    })

    create("UIListLayout", {
        Parent = content,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local iconObject
    if icon ~= nil and icon ~= 0 and icon ~= "" then
        iconObject = makeIcon(content, icon, window.theme.Text, 16, name)
        iconObject.LayoutOrder = 0
    end

    local title = create("TextLabel", {
        Parent = content,
        Size = UDim2.fromOffset(contentWidth - (iconObject and 21 or 0), 18),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = window.theme.Text,
        TextTransparency = 0,
        TextSize = 16,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 1,
        ZIndex = 4
    })

    local interact = create("TextButton", {
        Parent = main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 2
    })

    registerConnection(window, interact.MouseEnter:Connect(function()
        tween(mainStroke, Tweens.Hover, {
            Transparency = window.theme.ElementStrokeHoverTransparency,
            Color = window.theme.ElementHoverStroke
        })
        tween(hover, Tweens.Hover, {BackgroundTransparency = 0.97})
    end))

    registerConnection(window, interact.MouseLeave:Connect(function()
        tween(mainStroke, Tweens.Hover, {
            Transparency = window.theme.ElementStrokeTransparency,
            Color = window.theme.Stroke
        })
        tween(hover, Tweens.Hover, {BackgroundTransparency = 1})
    end))

    return {
        main = main,
        stroke = mainStroke,
        gradient = gradient,
        hover = hover,
        content = content,
        title = title,
        interact = interact,
        icon = iconObject,
        name = name,
        searchName = string.lower(name)
    }
end

local function reserveFlag(window, requested, fallback)
    local flag = requested or fallback
    local base = flag
    local suffix = 1

    while window.controls[flag] do
        suffix += 1
        flag = base .. "_" .. suffix
    end

    if flag ~= base then
        warn(string.format("Aether: duplicate flag '%s' renamed to '%s'", base, flag))
    end

    return flag
end

function Tab:CreateToggle(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, Layout.ElementHeight, options, 77)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)
    local value = option(options, "value", "Value", "currentValue", "CurrentValue") == true

    local track = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(50, 21),
        BackgroundColor3 = window.theme.ToggleTrack,
        BackgroundTransparency = window.theme.ToggleTrackTransparency,
        ZIndex = 5
    })

    corner(track, 15)
    stroke(track, Color3.fromRGB(255, 255, 255), 0.85, 1)

    local knob = create("Frame", {
        Parent = track,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = value and UDim2.new(1, -28, 0.5, 0) or UDim2.new(1, -47, 0.5, 0),
        Size = UDim2.fromOffset(25, 17),
        BackgroundColor3 = value and window.theme.Accent or window.theme.ToggleKnob,
        BackgroundTransparency = value and 0 or window.theme.ToggleKnobOffTransparency,
        ZIndex = 8
    })

    corner(knob, 99)
    local knobStroke = stroke(knob, value and window.theme.AccentStroke or Color3.fromRGB(255, 255, 255), value and 0 or 0.7, 1)
    local knobGlow = shadow(knob, window.theme.Accent, 20, value and window.theme.AccentGlow or 1)

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        interact = base.interact,
        baseStroke = base.stroke,
        track = track,
        knob = knob,
        knobStroke = knobStroke,
        knobGlow = knobGlow,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        value = value
    }, Toggle)

    window.controls[flag] = control
    window.Flags[flag] = value
    control:_render(true)

    registerConnection(window, base.interact.MouseButton1Click:Connect(function()
        tween(base.main, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -26, 0, Layout.ElementHeight)
        })

        control:Set(not control.value)

        task.delay(0.09, function()
            if base.main.Parent then
                tween(base.main, Tweens.Hover, {
                    Size = UDim2.new(1, -20, 0, Layout.ElementHeight)
                })
            end
        end)
    end))

    return self:_addElement(control)
end

function Toggle:_render(instant)
    local enabled = self.value
    local knobProperties = {
        Position = enabled and UDim2.new(1, -28, 0.5, 0) or UDim2.new(1, -47, 0.5, 0),
        BackgroundColor3 = enabled and self.window.theme.Accent or self.window.theme.ToggleKnob,
        BackgroundTransparency = enabled and 0 or self.window.theme.ToggleKnobOffTransparency
    }

    local strokeProperties = {
        Color = enabled and self.window.theme.AccentStroke or Color3.fromRGB(255, 255, 255),
        Transparency = enabled and 0 or 0.7
    }

    if instant then
        for property, value in pairs(knobProperties) do
            self.knob[property] = value
        end
        for property, value in pairs(strokeProperties) do
            self.knobStroke[property] = value
        end
    else
        tween(self.knob, Tweens.Hover, knobProperties)
        tween(self.knobStroke, Tweens.Hover, strokeProperties)
    end

    if self.knobGlow then
        self.knobGlow.Color = self.window.theme.Accent
        if instant then
            self.knobGlow.Transparency = enabled and self.window.theme.AccentGlow or 1
        else
            tween(self.knobGlow, Tweens.Hover, {
                Transparency = enabled and self.window.theme.AccentGlow or 1
            })
        end
    end
end

function Toggle:Set(value, silent)
    self.value = value == true
    self.window.Flags[self.flag] = self.value
    self:_render(false)

    if not silent then
        safeCallback("toggle", self.callback, self.value)
    end

    return self.value
end

function Toggle:Get()
    return self.value
end

function Toggle:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateButton(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, Layout.ElementHeight, options, Layout.ElementContentInset)
    local callback = option(options, "callback", "Callback") or function() end

    local arrow = create("TextLabel", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = self.window.theme.Secondary,
        TextTransparency = 0.2,
        TextSize = 24,
        FontFace = FontMedium,
        ZIndex = 6
    })

    local control = setmetatable({
        window = self.window,
        tab = self,
        main = base.main,
        title = base.title,
        arrow = arrow,
        name = base.name,
        searchName = base.searchName,
        callback = callback
    }, Button)

    registerConnection(self.window, base.interact.MouseButton1Click:Connect(function()
        tween(arrow, Tweens.Fast, {Position = UDim2.new(1, -13, 0.5, 0)})
        safeCallback("button", callback)

        task.delay(0.1, function()
            if arrow.Parent then
                tween(arrow, Tweens.Hover, {Position = UDim2.new(1, -18, 0.5, 0)})
            end
        end)
    end))

    return self:_addElement(control)
end

function Button:Fire()
    safeCallback("button", self.callback)
end

function Button:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateTextbox(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, 51, options, 210)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local placeholder = option(options, "placeholder", "Placeholder") or "Type here"
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)
    local value = tostring(option(options, "value", "Value", "default", "Default") or "")
    local numeric = option(options, "numeric", "Numeric") == true
    local clearOnFocus = option(options, "clearOnFocus", "ClearOnFocus") == true

    local field = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(180, 31),
        BackgroundColor3 = window.theme.Field,
        BackgroundTransparency = 0.08,
        Active = true,
        ZIndex = 5
    })

    corner(field, 9)
    local fieldStroke = stroke(field, window.theme.StrokeSoft, 0.42, 1)

    local box = create("TextBox", {
        Parent = field,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = clearOnFocus,
        Text = value,
        PlaceholderText = placeholder,
        TextColor3 = window.theme.Text,
        PlaceholderColor3 = window.theme.Muted,
        TextSize = 14,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Active = true,
        ZIndex = 6
    })

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        value = value,
        field = field,
        fieldStroke = fieldStroke,
        box = box,
        numeric = numeric
    }, Textbox)

    window.controls[flag] = control
    window.Flags[flag] = value

    registerConnection(window, box.Focused:Connect(function()
        tween(field, Tweens.Hover, {BackgroundColor3 = window.theme.FieldHover})
        tween(fieldStroke, Tweens.Hover, {Color = window.theme.AccentStroke, Transparency = 0.15})
    end))

    registerConnection(window, box.FocusLost:Connect(function(enterPressed)
        tween(field, Tweens.Hover, {BackgroundColor3 = window.theme.Field})
        tween(fieldStroke, Tweens.Hover, {Color = window.theme.StrokeSoft, Transparency = 0.42})

        local newValue = box.Text
        if numeric and newValue ~= "" and tonumber(newValue) == nil then
            box.Text = control.value
            return
        end

        control:Set(newValue, false, enterPressed)
    end))

    return self:_addElement(control)
end

Tab.CreateInput = Tab.CreateTextbox

function Textbox:Set(value, silent, enterPressed)
    value = tostring(value or "")

    if self.numeric and value ~= "" and tonumber(value) == nil then
        return self.value
    end

    self.value = value
    self.box.Text = value
    self.window.Flags[self.flag] = value

    if not silent then
        safeCallback("textbox", self.callback, value, enterPressed == true)
    end

    return value
end

function Textbox:Get()
    return self.value
end

function Textbox:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateSlider(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, 65, options, 250)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local minimum = tonumber(option(options, "min", "Min")) or 0
    local maximum = tonumber(option(options, "max", "Max")) or 100
    local increment = tonumber(option(options, "increment", "Increment", "step", "Step")) or 1
    local suffix = tostring(option(options, "suffix", "Suffix") or "")
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)

    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end

    if increment <= 0 then
        increment = 1
    end

    suffix = suffix:gsub("^%s+", ""):gsub("%s+$", "")

    local initial = tonumber(option(options, "value", "Value", "currentValue", "CurrentValue", "default", "Default"))
    if initial == nil then
        initial = minimum
    end
    initial = snapSliderValue(minimum, maximum, increment, initial)

    base.content.AnchorPoint = Vector2.new(0, 0)
    base.content.Position = UDim2.fromOffset(20, 16)
    base.content.Size = UDim2.fromOffset(170, 18)

    local valueLabel = create("TextLabel", {
        Parent = base.main,
        Position = UDim2.fromOffset(20, 35),
        Size = UDim2.fromOffset(170, 16),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = window.theme.Text,
        TextTransparency = 0.3,
        TextSize = 15,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 6
    })

    local track = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(222, 14),
        BackgroundColor3 = window.theme.SliderBackground,
        BackgroundTransparency = 0,
        ZIndex = 6
    })

    corner(track, 13)

    local progress = create("Frame", {
        Parent = track,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        ZIndex = 7
    })

    corner(progress, 13)

    create("UIGradient", {
        Parent = progress,
        Rotation = 2,
        Offset = Vector2.new(0, 0.5),
        Color = ColorSequence.new(window.theme.Accent),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0)
        })
    })

    local progressGlow = shadow(
        progress,
        window.theme.Accent,
        20,
        math.max(0.55, window.theme.AccentGlow)
    )

    local handle = create("Frame", {
        Parent = progress,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(35, 20),
        BackgroundColor3 = window.theme.SliderHandle,
        BackgroundTransparency = 0,
        ZIndex = 50
    })

    corner(handle, 999)

    local handleStroke = stroke(handle, window.theme.SliderStroke, 1, 1)
    local handleGlow = shadow(handle, Color3.fromRGB(255, 255, 255), 10, 0.8)

    local interact = create("TextButton", {
        Parent = track,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 60
    })

    local displayValue = create("NumberValue", {
        Parent = base.main,
        Value = initial
    })

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        value = initial,
        minimum = minimum,
        maximum = maximum,
        increment = increment,
        suffix = suffix,
        decimals = sliderDecimalPlaces(increment),
        content = base.content,
        valueLabel = valueLabel,
        displayValue = displayValue,
        track = track,
        bar = track,
        hitbox = interact,
        interact = interact,
        progress = progress,
        fill = progress,
        progressGlow = progressGlow,
        fillGlow = progressGlow,
        handle = handle,
        knob = handle,
        handleStroke = handleStroke,
        handleGlow = handleGlow,
        dragging = false,
        dragInput = nil,
        _dragConnection = nil,
        _displayTween = nil,
        _layoutMode = nil
    }, Slider)

    window.controls[flag] = control
    window.Flags[flag] = initial

    registerConnection(window, displayValue:GetPropertyChangedSignal("Value"):Connect(function()
        valueLabel.Text = control:_format(displayValue.Value)
    end))

    local function updateFromX(x)
        local width = math.max(track.AbsoluteSize.X, 1)
        local ratio = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        local raw = minimum + ratio * (maximum - minimum)
        local value = snapSliderValue(minimum, maximum, increment, raw)

        if value == control.value then
            return
        end

        control.value = value
        window.Flags[flag] = value
        control:_render(false, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), true)
        safeCallback("slider", callback, value)
    end

    function control:_currentPointerX()
        if self.dragInput then
            return self.dragInput.Position.X
        end
        return UserInputService:GetMouseLocation().X
    end

    function control:_setHeld(held)
        local size = held and Vector2.new(41, 22) or Vector2.new(35, 20)
        local animation = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

        tween(self.handle, animation, {
            Size = UDim2.fromOffset(size.X, size.Y),
            BackgroundTransparency = held and 0.7 or 0
        })
        tween(self.handleStroke, animation, {
            Transparency = held and 0.6 or 1
        })
        self:_render(false, animation, true)
    end

    function control:_endDrag()
        if not self.dragging then
            return
        end

        self.dragging = false
        self.dragInput = nil
        self:_setHeld(false)

        if self._dragConnection then
            self._dragConnection:Disconnect()
            self._dragConnection = nil
        end
    end

    function control:_beginDrag(input)
        if self.dragging or self.window.destroyed then
            return
        end

        self.dragging = true
        self.dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
        self:_setHeld(true)
        updateFromX(self:_currentPointerX())

        if self._dragConnection then
            self._dragConnection:Disconnect()
            self._dragConnection = nil
        end

        self._dragConnection = RunService.RenderStepped:Connect(function()
            if self.window.destroyed or not self.dragging or not self.main.Parent then
                self:_endDrag()
                return
            end

            updateFromX(self:_currentPointerX())
        end)
    end

    registerConnection(window, base.main.MouseEnter:Connect(function()
        if window.destroyed then
            return
        end
        tween(track, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            BackgroundColor3 = window.theme.SliderBackgroundHover
        })
    end))

    registerConnection(window, base.main.MouseLeave:Connect(function()
        tween(track, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            BackgroundColor3 = window.theme.SliderBackground
        })
    end))

    registerConnection(window, interact.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        control:_beginDrag(input)
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if not control.dragging then
            return
        end

        if control.dragInput then
            if input == control.dragInput then
                control:_endDrag()
            end
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            control:_endDrag()
        end
    end))

    registerConnection(window, UserInputService.WindowFocusReleased:Connect(function()
        control:_endDrag()
    end))

    registerConnection(window, base.main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not window.destroyed then
            control:_applyLayout()
        end
    end))

    control:_applyLayout()
    control:_render(true, nil, true)

    return self:_addElement(control)
end

function Slider:_format(value)
    local formatted = string.format("%." .. self.decimals .. "f", value)
    if self.suffix ~= "" then
        return formatted .. " " .. self.suffix
    end
    return formatted
end

function Slider:_applyLayout()
    local width = self.main.AbsoluteSize.X
    local mode = width > 0 and width < 430 and "narrow" or "wide"

    if self._layoutMode == mode then
        return
    end

    self._layoutMode = mode

    if mode == "narrow" then
        self.main.Size = UDim2.new(1, -20, 0, 70)
        self.content.AnchorPoint = Vector2.new(0, 0)
        self.content.Position = UDim2.fromOffset(20, 14)
        self.content.Size = UDim2.new(1, -150, 0, 18)
        self.valueLabel.AnchorPoint = Vector2.new(1, 0)
        self.valueLabel.Position = UDim2.new(1, -20, 0, 14)
        self.valueLabel.Size = UDim2.fromOffset(105, 18)
        self.valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        self.track.AnchorPoint = Vector2.new(0.5, 1)
        self.track.Position = UDim2.new(0.5, 0, 1, -14)
        self.track.Size = UDim2.new(1, -30, 0, 14)
    else
        self.main.Size = UDim2.new(1, -20, 0, 65)
        self.content.AnchorPoint = Vector2.new(0, 0)
        self.content.Position = UDim2.fromOffset(20, 16)
        self.content.Size = UDim2.fromOffset(170, 18)
        self.valueLabel.AnchorPoint = Vector2.new(0, 0)
        self.valueLabel.Position = UDim2.fromOffset(20, 35)
        self.valueLabel.Size = UDim2.fromOffset(170, 16)
        self.valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.track.AnchorPoint = Vector2.new(1, 0.5)
        self.track.Position = UDim2.new(1, -15, 0.5, 0)
        self.track.Size = UDim2.fromOffset(222, 14)
    end
end

function Slider:_render(instant, animation, snapDisplay)
    local range = self.maximum - self.minimum
    local ratio = range == 0 and 0 or math.clamp((self.value - self.minimum) / range, 0, 1)
    local target = UDim2.new(ratio, 0, 1, 0)

    if instant then
        self.progress.Size = target
    else
        tween(
            self.progress,
            animation or TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {Size = target}
        )
    end

    if self._displayTween then
        pcall(self._displayTween.Cancel, self._displayTween)
        self._displayTween = nil
    end

    if instant or snapDisplay then
        self.displayValue.Value = self.value
    else
        self._displayTween = tween(
            self.displayValue,
            TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Value = self.value}
        )
    end
end

function Slider:Set(value, silent)
    value = tonumber(value) or self.minimum
    value = snapSliderValue(self.minimum, self.maximum, self.increment, value)

    self.value = value
    self.window.Flags[self.flag] = value
    self:_render(false, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), false)

    if not silent then
        safeCallback("slider", self.callback, value)
    end

    return value
end

function Slider:Get()
    return self.value
end

function Slider:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Slider:_cleanup()
    self.dragging = false
    self.dragInput = nil

    if self._dragConnection then
        pcall(self._dragConnection.Disconnect, self._dragConnection)
        self._dragConnection = nil
    end

    if self._displayTween then
        pcall(self._displayTween.Cancel, self._displayTween)
        self._displayTween = nil
    end
end

function Tab:CreateDropdown(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, 51, options, 210)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local values = option(options, "values", "Values", "options", "Options") or {}
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)
    local initial = option(options, "value", "Value", "default", "Default")

    if initial == nil and #values > 0 then
        initial = values[1]
    end

    local field = create("TextButton", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(180, 31),
        BackgroundColor3 = window.theme.Field,
        BackgroundTransparency = 0.08,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12
    })

    corner(field, 9)
    local fieldStroke = stroke(field, window.theme.StrokeSoft, 0.42, 1)

    local valueLabel = create("TextLabel", {
        Parent = field,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(initial or "Select"),
        TextColor3 = window.theme.Text,
        TextSize = 14,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 13
    })

    local arrow = create("TextLabel", {
        Parent = field,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Text = "⌄",
        TextColor3 = window.theme.Secondary,
        TextSize = 16,
        FontFace = FontMedium,
        ZIndex = 13
    })

    local popup = create("Frame", {
        Parent = window.screen,
        Size = UDim2.fromOffset(180, 0),
        BackgroundColor3 = window.theme.Window2,
        BackgroundTransparency = 0.02,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 500
    })

    corner(popup, 11)
    stroke(popup, window.theme.StrokeSoft, 0.28, 1)
    shadow(popup, window.theme.Shadow, 24, 0.35)

    local list = create("ScrollingFrame", {
        Parent = popup,
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 501
    })

    local listLayout = create("UIListLayout", {
        Parent = list,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        values = table.clone(values),
        value = initial,
        field = field,
        fieldStroke = fieldStroke,
        valueLabel = valueLabel,
        arrow = arrow,
        popup = popup,
        list = list,
        listLayout = listLayout,
        open = false,
        optionButtons = {}
    }, Dropdown)

    window.controls[flag] = control
    window.Flags[flag] = initial

    function control:_positionPopup()
        local position = field.AbsolutePosition
        popup.Position = UDim2.fromOffset(position.X, position.Y + field.AbsoluteSize.Y + 6)
    end

    function control:_rebuild()
        for _, button in ipairs(self.optionButtons) do
            button:Destroy()
        end
        table.clear(self.optionButtons)

        for index, item in ipairs(self.values) do
            local button = create("TextButton", {
                Parent = list,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = window.theme.Element,
                BackgroundTransparency = 1,
                Text = tostring(item),
                TextColor3 = window.theme.Text,
                TextTransparency = item == self.value and 0 or 0.18,
                TextSize = 14,
                FontFace = item == self.value and FontSemiBold or FontRegular,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = index,
                ZIndex = 502
            })

            create("UIPadding", {
                Parent = button,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })

            corner(button, 8)

            registerConnection(window, button.MouseEnter:Connect(function()
                tween(button, Tweens.Hover, {BackgroundTransparency = 0.4})
            end))

            registerConnection(window, button.MouseLeave:Connect(function()
                tween(button, Tweens.Hover, {BackgroundTransparency = 1})
            end))

            registerConnection(window, button.MouseButton1Click:Connect(function()
                self:Set(item)
                self:SetOpen(false)
            end))

            table.insert(self.optionButtons, button)
        end
    end

    control:_rebuild()

    registerConnection(window, field.MouseButton1Click:Connect(function()
        control:SetOpen(not control.open)
    end))

    registerConnection(window, RunService.RenderStepped:Connect(function()
        if control.open and popup.Visible and not window.destroyed then
            control:_positionPopup()
        end
    end))

    return self:_addElement(control)
end

function Dropdown:SetOpen(state)
    state = state == true
    self.open = state

    if state then
        self.window:_closePopups(self)
        self:_positionPopup()
        local height = math.min(180, #self.values * 33 + 10)
        self.popup.Size = UDim2.fromOffset(180, 0)
        self.popup.Visible = true
        tween(self.popup, Tweens.Hover, {Size = UDim2.fromOffset(180, height)})
        tween(self.arrow, Tweens.Hover, {Rotation = 180})
        tween(self.fieldStroke, Tweens.Hover, {Color = self.window.theme.AccentStroke, Transparency = 0.15})
        self.window._openPopup = self
    else
        tween(self.arrow, Tweens.Hover, {Rotation = 0})
        tween(self.fieldStroke, Tweens.Hover, {Color = self.window.theme.StrokeSoft, Transparency = 0.42})
        local closing = tween(self.popup, Tweens.Fast, {Size = UDim2.fromOffset(180, 0)})

        if self.window._openPopup == self then
            self.window._openPopup = nil
        end

        if closing then
            closing.Completed:Once(function()
                if not self.open and self.popup.Parent then
                    self.popup.Visible = false
                end
            end)
        else
            self.popup.Visible = false
        end
    end
end

function Dropdown:Set(value, silent)
    self.value = value
    self.valueLabel.Text = tostring(value == nil and "Select" or value)
    self.window.Flags[self.flag] = value
    self:_rebuild()

    if not silent then
        safeCallback("dropdown", self.callback, value)
    end

    return value
end

function Dropdown:Get()
    return self.value
end

function Dropdown:SetValues(values)
    self.values = type(values) == "table" and table.clone(values) or {}
    self:_rebuild()

    if self.value ~= nil and not table.find(self.values, self.value) then
        self:Set(self.values[1], true)
    end
end

function Dropdown:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateColorPicker(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, 51, options, 228)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)
    local initial = option(options, "value", "Value", "default", "Default")

    if typeof(initial) ~= "Color3" then
        initial = window.theme.Accent
    end

    local field = create("TextButton", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(198, 31),
        BackgroundColor3 = window.theme.Field,
        BackgroundTransparency = 0.08,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12
    })

    corner(field, 9)
    local fieldStroke = stroke(field, window.theme.StrokeSoft, 0.42, 1)

    local swatch = create("Frame", {
        Parent = field,
        Position = UDim2.fromOffset(7, 6),
        Size = UDim2.fromOffset(19, 19),
        BackgroundColor3 = initial,
        ZIndex = 13
    })

    corner(swatch, 6)
    stroke(swatch, Color3.fromRGB(255, 255, 255), 0.78, 1)

    local hexBox = create("TextBox", {
        Parent = field,
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(1, -42, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Text = colorToHex(initial),
        PlaceholderText = "#FFFFFF",
        TextColor3 = window.theme.Text,
        PlaceholderColor3 = window.theme.Muted,
        TextSize = 14,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    })

    local popup = create("Frame", {
        Parent = window.screen,
        Size = UDim2.fromOffset(235, 0),
        BackgroundColor3 = window.theme.Window2,
        BackgroundTransparency = 0.02,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 520
    })

    corner(popup, 12)
    stroke(popup, window.theme.StrokeSoft, 0.25, 1)
    shadow(popup, window.theme.Shadow, 26, 0.3)

    local sv = create("Frame", {
        Parent = popup,
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(184, 136),
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        Active = true,
        ZIndex = 521
    })

    corner(sv, 9)

    create("UIGradient", {
        Parent = sv,
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })

    local blackOverlay = create("Frame", {
        Parent = sv,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0,
        ZIndex = 522
    })

    corner(blackOverlay, 9)

    create("UIGradient", {
        Parent = blackOverlay,
        Rotation = 90,
        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
    })

    local svCursor = create("Frame", {
        Parent = sv,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        ZIndex = 524
    })

    corner(svCursor, 99)
    stroke(svCursor, Color3.new(1, 1, 1), 0, 1.5)

    local hue = create("Frame", {
        Parent = popup,
        Position = UDim2.fromOffset(204, 10),
        Size = UDim2.fromOffset(21, 136),
        Active = true,
        ZIndex = 521
    })

    corner(hue, 8)

    create("UIGradient", {
        Parent = hue,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.1667, Color3.fromHSV(0.1667, 1, 1)),
            ColorSequenceKeypoint.new(0.3333, Color3.fromHSV(0.3333, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.6667, Color3.fromHSV(0.6667, 1, 1)),
            ColorSequenceKeypoint.new(0.8333, Color3.fromHSV(0.8333, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        })
    })

    local hueCursor = create("Frame", {
        Parent = hue,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(1, 6, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 524
    })

    corner(hueCursor, 99)
    stroke(hueCursor, Color3.new(0, 0, 0), 0.45, 1)

    local rgbLabel = create("TextLabel", {
        Parent = popup,
        Position = UDim2.fromOffset(10, 153),
        Size = UDim2.new(1, -20, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = window.theme.Secondary,
        TextSize = 13,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 521
    })

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        value = initial,
        field = field,
        fieldStroke = fieldStroke,
        swatch = swatch,
        hexBox = hexBox,
        popup = popup,
        sv = sv,
        svCursor = svCursor,
        hue = hue,
        hueCursor = hueCursor,
        rgbLabel = rgbLabel,
        open = false,
        draggingSV = false,
        draggingHue = false
    }, ColorPicker)

    control.h, control.s, control.v = initial:ToHSV()
    window.controls[flag] = control
    window.Flags[flag] = initial

    function control:_positionPopup()
        local position = field.AbsolutePosition
        popup.Position = UDim2.fromOffset(position.X - 37, position.Y + field.AbsoluteSize.Y + 6)
    end

    function control:_renderPicker()
        self.sv.BackgroundColor3 = Color3.fromHSV(self.h, 1, 1)
        self.svCursor.Position = UDim2.fromScale(self.s, 1 - self.v)
        self.hueCursor.Position = UDim2.fromScale(0.5, self.h)
        self.swatch.BackgroundColor3 = self.value
        self.hexBox.Text = colorToHex(self.value)
        self.rgbLabel.Text = string.format(
            "RGB  %d, %d, %d",
            math.floor(self.value.R * 255 + 0.5),
            math.floor(self.value.G * 255 + 0.5),
            math.floor(self.value.B * 255 + 0.5)
        )
    end

    local function setFromHSV(silent)
        control.value = Color3.fromHSV(control.h, control.s, control.v)
        control.window.Flags[control.flag] = control.value
        control:_renderPicker()

        if not silent then
            safeCallback("color picker", control.callback, control.value)
        end
    end

    local function updateSV(position)
        control.s = math.clamp((position.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
        control.v = 1 - math.clamp((position.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
        setFromHSV(false)
    end

    local function updateHue(position)
        control.h = math.clamp((position.Y - hue.AbsolutePosition.Y) / math.max(hue.AbsoluteSize.Y, 1), 0, 1)
        setFromHSV(false)
    end

    registerConnection(window, field.MouseButton1Click:Connect(function()
        if not hexBox:IsFocused() then
            control:SetOpen(not control.open)
        end
    end))

    registerConnection(window, hexBox.Focused:Connect(function()
        tween(fieldStroke, Tweens.Hover, {Color = window.theme.AccentStroke, Transparency = 0.15})
    end))

    registerConnection(window, hexBox.FocusLost:Connect(function()
        local parsed = hexToColor(hexBox.Text)
        if parsed then
            control:Set(parsed)
        else
            hexBox.Text = colorToHex(control.value)
        end

        if not control.open then
            tween(fieldStroke, Tweens.Hover, {Color = window.theme.StrokeSoft, Transparency = 0.42})
        end
    end))

    registerConnection(window, sv.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            control.draggingSV = true
            updateSV(input.Position)
        end
    end))

    registerConnection(window, hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            control.draggingHue = true
            updateHue(input.Position)
        end
    end))

    registerConnection(window, UserInputService.InputChanged:Connect(function(input)
        if window.destroyed then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if control.draggingSV then
            updateSV(input.Position)
        elseif control.draggingHue then
            updateHue(input.Position)
        end
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            control.draggingSV = false
            control.draggingHue = false
        end
    end))

    registerConnection(window, RunService.RenderStepped:Connect(function()
        if control.open and popup.Visible and not window.destroyed then
            control:_positionPopup()
        end
    end))

    control:_renderPicker()
    return self:_addElement(control)
end

function ColorPicker:SetOpen(state)
    state = state == true
    self.open = state

    if state then
        self.window:_closePopups(self)
        self:_positionPopup()
        self.popup.Size = UDim2.fromOffset(235, 0)
        self.popup.Visible = true
        tween(self.popup, Tweens.Hover, {Size = UDim2.fromOffset(235, 185)})
        tween(self.fieldStroke, Tweens.Hover, {Color = self.window.theme.AccentStroke, Transparency = 0.15})
        self.window._openPopup = self
    else
        local closing = tween(self.popup, Tweens.Fast, {Size = UDim2.fromOffset(235, 0)})

        if not self.hexBox:IsFocused() then
            tween(self.fieldStroke, Tweens.Hover, {Color = self.window.theme.StrokeSoft, Transparency = 0.42})
        end

        if self.window._openPopup == self then
            self.window._openPopup = nil
        end

        if closing then
            closing.Completed:Once(function()
                if not self.open and self.popup.Parent then
                    self.popup.Visible = false
                end
            end)
        else
            self.popup.Visible = false
        end
    end
end

function ColorPicker:Set(value, silent)
    if typeof(value) ~= "Color3" then
        return self.value
    end

    self.value = value
    self.h, self.s, self.v = value:ToHSV()
    self.window.Flags[self.flag] = value
    self:_renderPicker()

    if not silent then
        safeCallback("color picker", self.callback, value)
    end

    return value
end

function ColorPicker:Get()
    return self.value
end

function ColorPicker:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateKeybind(options)
    options = type(options) == "table" and options or {}

    local base = createBaseElement(self, 51, options, 130)
    local window = self.window
    local callback = option(options, "callback", "Callback") or function() end
    local changedCallback = option(options, "changedCallback", "ChangedCallback") or function() end
    local defaultFlag = string.lower(base.name:gsub("%s+", "_"))
    local flag = reserveFlag(window, option(options, "flag", "Flag"), defaultFlag)
    local value = option(options, "value", "Value", "default", "Default")

    if typeof(value) ~= "EnumItem" or value.EnumType ~= Enum.KeyCode then
        value = Enum.KeyCode.Unknown
    end

    local button = create("TextButton", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(100, 31),
        BackgroundColor3 = window.theme.Field,
        BackgroundTransparency = 0.08,
        Text = value == Enum.KeyCode.Unknown and "None" or value.Name,
        TextColor3 = window.theme.Text,
        TextSize = 13,
        FontFace = FontMedium,
        AutoButtonColor = false,
        ZIndex = 12
    })

    corner(button, 9)
    local buttonStroke = stroke(button, window.theme.StrokeSoft, 0.42, 1)

    local control = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        changedCallback = changedCallback,
        value = value,
        button = button,
        buttonStroke = buttonStroke,
        listening = false
    }, Keybind)

    window.controls[flag] = control
    window.Flags[flag] = value

    registerConnection(window, button.MouseButton1Click:Connect(function()
        control.listening = true
        button.Text = "..."
        tween(buttonStroke, Tweens.Hover, {Color = window.theme.AccentStroke, Transparency = 0.15})
    end))

    registerConnection(window, UserInputService.InputBegan:Connect(function(input, processed)
        if control.listening then
            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            control.listening = false

            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                control:Set(Enum.KeyCode.Unknown)
            else
                control:Set(input.KeyCode)
            end

            tween(buttonStroke, Tweens.Hover, {Color = window.theme.StrokeSoft, Transparency = 0.42})
            return
        end

        if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if control.value ~= Enum.KeyCode.Unknown and input.KeyCode == control.value then
            safeCallback("keybind", callback, input.KeyCode)
        end
    end))

    return self:_addElement(control)
end

function Keybind:Set(value, silent)
    if typeof(value) ~= "EnumItem" or value.EnumType ~= Enum.KeyCode then
        value = Enum.KeyCode.Unknown
    end

    self.value = value
    self.window.Flags[self.flag] = value
    self.button.Text = value == Enum.KeyCode.Unknown and "None" or value.Name

    if not silent then
        safeCallback("keybind changed", self.changedCallback, value)
    end

    return value
end

function Keybind:Get()
    return self.value
end

function Keybind:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
end

function Tab:CreateLabel(options)
    local text = type(options) == "string" and options or option(options, "text", "Text", "name", "Name") or "Label"

    local main = create("Frame", {
        Parent = self.page,
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1
    })

    local label = create("TextLabel", {
        Parent = main,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.Secondary,
        TextSize = 14,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true
    })

    local control = setmetatable({
        window = self.window,
        tab = self,
        main = main,
        label = label,
        name = text,
        searchName = string.lower(text)
    }, Label)

    return self:_addElement(control)
end

function Label:Set(text)
    self.name = tostring(text)
    self.searchName = string.lower(self.name)
    self.label.Text = self.name
end

function Tab:CreateParagraph(options)
    options = type(options) == "table" and options or {Text = tostring(options or "")}

    local titleText = option(options, "title", "Title", "name", "Name") or ""
    local bodyText = option(options, "text", "Text", "content", "Content") or ""

    local main = create("Frame", {
        Parent = self.page,
        Size = UDim2.new(1, -20, 0, 76),
        BackgroundColor3 = self.window.theme.Element,
        BackgroundTransparency = 0.15
    })

    corner(main, 12)
    stroke(main, self.window.theme.Stroke, 0.2, 1)

    local title = create("TextLabel", {
        Parent = main,
        Position = UDim2.fromOffset(15, 10),
        Size = UDim2.new(1, -30, 0, 18),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = self.window.theme.Text,
        TextSize = 15,
        FontFace = FontSemiBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = titleText ~= ""
    })

    local body = create("TextLabel", {
        Parent = main,
        Position = UDim2.fromOffset(15, titleText ~= "" and 31 or 10),
        Size = UDim2.new(1, -30, 0, titleText ~= "" and 35 or 55),
        BackgroundTransparency = 1,
        Text = bodyText,
        TextColor3 = self.window.theme.Secondary,
        TextTransparency = 0.08,
        TextSize = 13,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })

    local control = setmetatable({
        window = self.window,
        tab = self,
        main = main,
        title = title,
        body = body,
        name = titleText .. " " .. bodyText,
        searchName = string.lower(titleText .. " " .. bodyText)
    }, Paragraph)

    return self:_addElement(control)
end

function Paragraph:Set(titleText, bodyText)
    if bodyText == nil then
        bodyText = titleText
        titleText = ""
    end

    titleText = tostring(titleText or "")
    bodyText = tostring(bodyText or "")

    self.title.Text = titleText
    self.title.Visible = titleText ~= ""
    self.body.Text = bodyText
    self.body.Position = UDim2.fromOffset(15, titleText ~= "" and 31 or 10)
    self.body.Size = UDim2.new(1, -30, 0, titleText ~= "" and 35 or 55)
    self.name = titleText .. " " .. bodyText
    self.searchName = string.lower(self.name)
end

function Window:_closePopups(except)
    if self._openPopup and self._openPopup ~= except and self._openPopup.SetOpen then
        self._openPopup:SetOpen(false)
    end
end

function Window:_applySearch(query)
    query = string.lower(tostring(query or ""))

    local selected = self.selectedTab
    if not selected then
        return
    end

    for _, element in ipairs(selected.elements) do
        if element.isSection then
            element.main.Visible = query == ""
        else
            element.main.Visible = query == "" or string.find(element.searchName or "", query, 1, true) ~= nil
        end
    end
end

function Window:_updateDragArea()
    local reserve = self.searchOpen and Layout.SearchReserve or Layout.ActionReserve
    self.dragArea.Size = UDim2.new(1, -reserve, 1, 0)
end

function Window:CreateTab(options)
    options = type(options) == "table" and options or {}

    local name = option(options, "name", "Name") or "Tab"
    local icon = option(options, "icon", "Icon")

    local selector = create("TextButton", {
        Parent = self.tabList,
        Size = UDim2.new(1, -Layout.RowInset * 2, 0, Layout.RowHeight),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false
    })

    corner(selector, Layout.RowCorner)

    local selectorGradient = create("UIGradient", {
        Parent = selector,
        Rotation = 90,
        Color = ColorSequence.new(self.theme.Tab, self.theme.TabBottom)
    })

    local selectorStroke = stroke(selector, Color3.fromRGB(255, 255, 255), 1, 1)

    local selectorStrokeGradient = create("UIGradient", {
        Parent = selectorStroke,
        Rotation = 90,
        Color = ColorSequence.new(self.theme.TabStrokeTop, self.theme.TabStrokeBottom)
    })

    local selectorShadow = shadow(selector, Color3.fromRGB(255, 255, 255), 20, 1, UDim2.new(0, 0, 0, -15), UDim2.new(0, 10, 0, -30))

    local content = create("Frame", {
        Parent = selector,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, Layout.RowPadding, 0.5, 0),
        Size = UDim2.new(1, -Layout.RowPadding, 0, 24),
        BackgroundTransparency = 1
    })

    create("UIListLayout", {
        Parent = content,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Layout.RowContentSpacing)
    })

    local iconGroup = create("CanvasGroup", {
        Parent = content,
        Size = UDim2.fromOffset(Layout.RowIconSize, Layout.RowIconSize),
        BackgroundTransparency = 1,
        GroupTransparency = 0.5,
        LayoutOrder = 0
    })

    if icon ~= nil and icon ~= 0 and icon ~= "" then
        makeIcon(iconGroup, icon, self.theme.Text, Layout.RowIconSize, name)
    else
        makeLetterIcon(iconGroup, name, self.theme.Text, Layout.RowIconSize)
    end

    local selectorTitle = create("TextLabel", {
        Parent = content,
        Size = UDim2.fromOffset(120, 16),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.theme.Text,
        TextTransparency = 0.5,
        TextSize = 16,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 1
    })

    local page = create("ScrollingFrame", {
        Parent = self.pageHost,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    })

    create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 17),
        PaddingBottom = UDim.new(0, 17)
    })

    create("UIListLayout", {
        Parent = page,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local tab = setmetatable({
        window = self,
        name = name,
        icon = icon,
        selector = selector,
        selectorStroke = selectorStroke,
        selectorGradient = selectorGradient,
        selectorStrokeGradient = selectorStrokeGradient,
        selectorShadow = selectorShadow,
        selectorIcon = iconGroup,
        selectorTitle = selectorTitle,
        page = page,
        elements = {}
    }, Tab)

    table.insert(self.tabs, tab)
    selector.LayoutOrder = #self.tabs * 10

    registerConnection(self, selector.MouseEnter:Connect(function()
        if self.selectedTab ~= tab then
            setTabVisual(tab, "hover", false)
            selectorGradient.Rotation = -270
            selectorStrokeGradient.Rotation = -270
            tween(selectorGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 90})
            tween(selectorStrokeGradient, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 90})
        end
    end))

    registerConnection(self, selector.MouseLeave:Connect(function()
        if self.selectedTab ~= tab then
            setTabVisual(tab, "unselected", false)
        end
    end))

    registerConnection(self, selector.MouseButton1Click:Connect(function()
        self:_closePopups()
        tab:Select()
    end))

    setTabVisual(tab, "unselected", true)

    if not self.selectedTab then
        tab:Select()
    end

    return tab
end

function Window:GetFlag(flag)
    return self.Flags[flag]
end

function Window:SetFlag(flag, value)
    local control = self.controls[flag]

    if control and control.Set then
        return control:Set(value)
    end

    self.Flags[flag] = value
    return value
end

function Window:Notify(options)
    options = type(options) == "table" and options or {Description = tostring(options or "Notification")}

    if self.destroyed then
        return nil
    end

    local titleText = tostring(option(options, "title", "Title") or "Notification")
    local description = tostring(option(options, "description", "Description", "content", "Content", "text", "Text") or "")
    local typeName = string.lower(tostring(option(options, "type", "Type") or "info"))
    local requestedIcon = option(options, "icon", "Icon")
    local duration = tonumber(option(options, "duration", "Duration"))

    if duration == nil then
        duration = math.clamp(#description * 0.06 + 3, 3, 9)
    end
    duration = math.max(duration, 0.1)

    local typeColors = {
        info = self.theme.Info,
        success = self.theme.Success,
        warning = self.theme.Warning,
        error = self.theme.Danger,
        danger = self.theme.Danger
    }

    local typeSymbols = {
        info = "i",
        success = "✓",
        warning = "!",
        error = "×",
        danger = "×"
    }

    local accent = typeColors[typeName] or self.theme.Info
    local symbol = typeSymbols[typeName] or "i"
    local explicitIcon = requestedIcon ~= nil and requestedIcon ~= 0 and requestedIcon ~= ""
    local hasIcon = explicitIcon or typeSymbols[typeName] ~= nil
    local textWidth = hasIcon and 222 or 260
    local titleHeight = measureTextHeight(titleText, FontSemiBold, 16, textWidth)
    local descriptionHeight = description ~= "" and measureTextHeight(description, FontRegular, 15, textWidth) or 0
    local contentHeight = titleHeight + (descriptionHeight > 0 and 4 + descriptionHeight or 0)
    local bodyHeight = math.max(contentHeight, hasIcon and 24 or 0) + 28
    local targetHeight = bodyHeight + 8

    self._notificationCount = (self._notificationCount or 0) + 1
    self._liveNotifications = self._liveNotifications or {}
    self._notificationRecords = self._notificationRecords or {}

    local wrapper = create("Frame", {
        Parent = self.notificationList,
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = self._notificationCount,
        ZIndex = 900
    })

    create("UIPadding", {
        Parent = wrapper,
        PaddingTop = UDim.new(0, 8)
    })

    local body = create("Frame", {
        Parent = wrapper,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 360, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 901
    })

    corner(body, 18)

    create("UIGradient", {
        Parent = body,
        Rotation = 270,
        Offset = Vector2.new(0, -0.1),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.theme.Window),
            ColorSequenceKeypoint.new(0.9999, self.theme.Window2),
            ColorSequenceKeypoint.new(1, self.theme.Element)
        })
    })

    local bodyStroke = stroke(body, self.theme.Text, 1, 1)
    local bodyShadow = shadow(body, self.theme.Shadow, 20, 1)

    create("UIPadding", {
        Parent = body,
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20)
    })

    create("UIListLayout", {
        Parent = body,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14)
    })

    local iconGroup

    if hasIcon then
        iconGroup = create("CanvasGroup", {
            Parent = body,
            Size = UDim2.fromOffset(24, 24),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            LayoutOrder = 1,
            ZIndex = 902
        })

        if explicitIcon then
            local visual = makeIcon(iconGroup, requestedIcon, self.theme.Text, 24, titleText)
            visual.AnchorPoint = Vector2.new(0.5, 0.5)
            visual.Position = UDim2.fromScale(0.5, 0.5)
        else
            create("TextLabel", {
                Parent = iconGroup,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = symbol,
                TextColor3 = accent,
                TextSize = typeName == "success" and 18 or 17,
                FontFace = FontSemiBold,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 903
            })
        end
    end

    local textContainer = create("Frame", {
        Parent = body,
        Size = UDim2.fromOffset(textWidth, contentHeight),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        ZIndex = 902
    })

    create("UIListLayout", {
        Parent = textContainer,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local titleLabel = create("TextLabel", {
        Parent = textContainer,
        Size = UDim2.new(1, 0, 0, titleHeight),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = self.theme.Text,
        TextSize = 16,
        FontFace = FontSemiBold,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTransparency = 1,
        LayoutOrder = 1,
        ZIndex = 903
    })

    local descriptionLabel

    if description ~= "" then
        descriptionLabel = create("TextLabel", {
            Parent = textContainer,
            Size = UDim2.new(1, 0, 0, descriptionHeight),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = self.theme.Text,
            TextSize = 15,
            FontFace = FontRegular,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTransparency = 1,
            LayoutOrder = 2,
            ZIndex = 903
        })
    end

    local record = {
        Instance = wrapper,
        Body = body,
        _connections = {},
        _dismissed = false,
        _hovered = false
    }

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(record._connections, connection)
        return connection
    end

    local function disconnectAll()
        for _, connection in ipairs(record._connections) do
            pcall(connection.Disconnect, connection)
        end
        table.clear(record._connections)
    end

    local function removeFromLive()
        if not self._liveNotifications then
            return
        end

        local index = table.find(self._liveNotifications, record)
        if index then
            table.remove(self._liveNotifications, index)
        end
    end

    local function removeFromRecords()
        if not self._notificationRecords then
            return
        end

        local index = table.find(self._notificationRecords, record)
        if index then
            table.remove(self._notificationRecords, index)
        end
    end

    local function destroyNow()
        if record._dismissed then
            removeFromLive()
            removeFromRecords()
            disconnectAll()
            if wrapper.Parent then
                wrapper:Destroy()
            end
            return
        end

        record._dismissed = true
        removeFromLive()
        removeFromRecords()
        disconnectAll()

        if wrapper.Parent then
            wrapper:Destroy()
        end
    end

    local function dismiss()
        if record._dismissed then
            return
        end

        record._dismissed = true
        removeFromLive()

        if not wrapper.Parent then
            disconnectAll()
            return
        end

        tween(body, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        tween(bodyStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Transparency = 1
        })
        if bodyShadow then
            tween(bodyShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Transparency = 1
            })
        end
        tween(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            TextTransparency = 1
        })
        if descriptionLabel then
            tween(descriptionLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                TextTransparency = 1
            })
        end
        if iconGroup then
            tween(iconGroup, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                GroupTransparency = 1
            })
        end

        tween(body, TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -90, 1, 0)
        })

        local collapse = tween(wrapper, TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0)
        })

        local function finish()
            removeFromRecords()
            disconnectAll()
            if wrapper.Parent then
                wrapper:Destroy()
            end
        end

        if collapse then
            collapse.Completed:Once(finish)
        else
            task.delay(0.92, finish)
        end
    end

    record.Close = dismiss
    record._destroyImmediately = destroyNow

    table.insert(self._liveNotifications, record)
    table.insert(self._notificationRecords, record)

    while #self._liveNotifications > 6 do
        local oldest = table.remove(self._liveNotifications, 1)
        if oldest and oldest ~= record and oldest.Close then
            task.spawn(oldest.Close)
        end
    end

    connect(body.MouseEnter, function()
        record._hovered = true
    end)

    connect(body.MouseLeave, function()
        record._hovered = false
    end)

    connect(body.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dismiss()
        end
    end)

    task.spawn(function()
        if record._dismissed or self.destroyed or not wrapper.Parent then
            return
        end

        tween(wrapper, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        })
        tween(body, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween(body, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        })
        tween(bodyStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Transparency = 0.95
        })
        if bodyShadow then
            tween(bodyShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Transparency = 0.6
            })
        end
        tween(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })

        task.wait(0.05)

        if record._dismissed or self.destroyed or not wrapper.Parent then
            return
        end

        if iconGroup then
            tween(iconGroup, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                GroupTransparency = 0
            })
        end

        task.wait(0.05)

        if record._dismissed or self.destroyed or not wrapper.Parent then
            return
        end

        if descriptionLabel then
            tween(descriptionLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                TextTransparency = 0.35
            })
        end

        local elapsed = 0

        while elapsed < duration and not record._dismissed and not self.destroyed and wrapper.Parent do
            local delta = task.wait()
            if not record._hovered then
                elapsed += delta
            end
        end

        if not record._dismissed then
            dismiss()
        end
    end)

    return record
end

function Window:Minimize(state)
    if state == nil then
        state = not self.minimized
    end

    state = state == true

    if self.minimized == state or self.animating or self.hidden then
        return
    end

    self:_closePopups()
    self.minimized = state
    self.animating = true

    local offset = (state and Layout.TopbarHeight - self.size.Y or self.size.Y - Layout.TopbarHeight) / 2
    local currentPosition = self.main.Position
    local targetPosition = UDim2.new(
        currentPosition.X.Scale,
        currentPosition.X.Offset,
        currentPosition.Y.Scale,
        currentPosition.Y.Offset + offset
    )

    if state then
        tween(self.body, Tweens.Fast, {GroupTransparency = 1})

        task.delay(0.12, function()
            if self.main.Parent and self.minimized then
                self.body.Visible = false
            end
        end)

        tween(self.main, Tweens.Move, {
            Size = UDim2.fromOffset(self.size.X, Layout.TopbarHeight),
            Position = targetPosition
        })
        tween(self.minimizeVLine, Tweens.Hover, {BackgroundTransparency = 0})
    else
        self.body.Visible = true
        self.body.GroupTransparency = 1

        tween(self.main, Tweens.Move, {
            Size = UDim2.fromOffset(self.size.X, self.size.Y),
            Position = targetPosition
        })
        tween(self.minimizeVLine, Tweens.Hover, {BackgroundTransparency = 1})

        task.delay(0.09, function()
            if self.main.Parent and not self.minimized then
                tween(self.body, Tweens.Reveal, {GroupTransparency = 0})
            end
        end)
    end

    task.delay(0.38, function()
        self.animating = false
    end)
end

function Window:Show()
    if self.destroyed or not self.hidden or self.animating then
        return
    end

    self.animating = true
    self.hidden = false
    self.screen.Enabled = true

    local restorePosition = self._restorePosition or UDim2.new(0.5, 0, 0.5, 0)
    local shellTween = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

    self.collapsedInteract.Visible = true
    self.collapsedInteract.Active = true
    tween(self.collapsedFace, Tweens.Fast, {GroupTransparency = 1})

    local animation = tween(self.collapsedShell, shellTween, {
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        Position = restorePosition
    })

    tween(self.collapsedInteract, shellTween, {
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        Position = restorePosition
    })

    tween(self.collapsedShellCorner, shellTween, {CornerRadius = UDim.new(0, 18)})

    task.delay(0.22, function()
        if self.hidden or self.destroyed then
            return
        end

        self.main.Position = restorePosition
        self.main.Size = UDim2.fromOffset(self.size.X, self.size.Y)
        self.main.Visible = true
        self.main.GroupTransparency = 1
        self.scale.Scale = 1
        self.topbar.Visible = true
        self.body.Visible = true
        self.topbar.GroupTransparency = 0
        self.body.GroupTransparency = 0

        tween(self.main, Tweens.Reveal, {GroupTransparency = 0})
        tween(self.shadow, Tweens.Reveal, {Transparency = 0.6})
        tween(self.mainStroke, Tweens.Reveal, {Transparency = 0.6})
        tween(self.collapsedShell, Tweens.Reveal, {BackgroundTransparency = 1})
        tween(self.collapsedShellStroke, Tweens.Reveal, {Transparency = 1})
        tween(self.collapsedShellShadow, Tweens.Reveal, {Transparency = 1})
    end)

    local function finish()
        if self.destroyed or self.hidden then
            return
        end

        self.main.Position = restorePosition
        self.main.Size = UDim2.fromOffset(self.size.X, self.size.Y)
        self.main.Visible = true
        self.main.GroupTransparency = 0
        self.collapsedShell.BackgroundTransparency = 1
        self.collapsedShell.Visible = false
        self.collapsedFace.GroupTransparency = 1
        self.collapsedInteract.Visible = false
        self.animating = false
    end

    if animation then
        animation.Completed:Once(finish)
    else
        task.delay(0.4, finish)
    end
end

function Window:Hide()
    if self.destroyed or self.hidden or self.animating then
        return
    end

    self:_closePopups()
    self.animating = true
    self.hidden = true

    if self.minimized then
        self.minimized = false
        local position = self.main.Position
        self.main.Position = UDim2.new(
            position.X.Scale,
            position.X.Offset,
            position.Y.Scale,
            position.Y.Offset + (self.size.Y - Layout.TopbarHeight) / 2
        )
        self.minimizeVLine.BackgroundTransparency = 1
        self.main.Size = UDim2.fromOffset(self.size.X, self.size.Y)
        self.body.Visible = true
        self.body.GroupTransparency = 0
    end

    self._restorePosition = self.main.Position
    self.screen.Enabled = true

    if self.searchOpen then
        self.searchOpen = false
        self.searchBox:ReleaseFocus()
        self.searchBox.Text = ""
        self:_applySearch("")
        self.searchPill.Visible = false
        self:_updateDragArea()
    end

    local collapsedSize = UDim2.fromOffset(185, 50)
    local collapsedPosition = self._collapsedPosition or UDim2.new(0.5, 0, 0, 45)

    self.collapsedShell.Visible = true
    self.collapsedShell.Position = self.main.Position
    self.collapsedShell.Size = self.main.Size
    self.collapsedShell.BackgroundTransparency = 1
    self.collapsedShellCorner.CornerRadius = UDim.new(0, 18)
    self.collapsedShellStroke.Transparency = 1

    if self.collapsedShellShadow then
        self.collapsedShellShadow.Transparency = 1
    end

    self.collapsedFace.Visible = true
    self.collapsedFace.GroupTransparency = 1
    self.collapsedInteract.Visible = true
    self.collapsedInteract.Active = true
    self.collapsedInteract.Position = self.main.Position
    self.collapsedInteract.Size = self.main.Size

    tween(self.topbar, Tweens.Fast, {GroupTransparency = 1})
    tween(self.body, Tweens.Fast, {GroupTransparency = 1})
    tween(self.mainStroke, Tweens.Fast, {Transparency = 1})
    tween(self.shadow, Tweens.Fast, {Transparency = 1})
    tween(self.main, Tweens.Fast, {GroupTransparency = 1})
    tween(self.collapsedShell, Tweens.Fast, {BackgroundTransparency = 0})
    tween(self.collapsedShellStroke, Tweens.Fast, {Transparency = 0.6})
    tween(self.collapsedShellShadow, Tweens.Fast, {Transparency = 0.6})

    local animation = tween(self.collapsedShell, Tweens.Move, {
        Size = collapsedSize,
        Position = collapsedPosition
    })

    tween(self.collapsedInteract, Tweens.Move, {
        Size = collapsedSize,
        Position = collapsedPosition
    })

    tween(self.collapsedShellCorner, Tweens.Move, {CornerRadius = UDim.new(1, 0)})

    task.delay(0.18, function()
        if not self.hidden or self.destroyed then
            return
        end

        self.main.Visible = false
        self.main.GroupTransparency = 0
        self.topbar.GroupTransparency = 0
        self.body.GroupTransparency = 0
        tween(self.collapsedFace, Tweens.Hover, {GroupTransparency = 0})
    end)

    local function finish()
        if self.destroyed or not self.hidden then
            return
        end

        self.collapsedShell.Position = collapsedPosition
        self.collapsedShell.Size = collapsedSize
        self.collapsedInteract.Position = collapsedPosition
        self.collapsedInteract.Size = collapsedSize
        self.collapsedInteract.Visible = true
        self.collapsedShellCorner.CornerRadius = UDim.new(1, 0)
        self.collapsedInteract.Active = true
        self.animating = false
    end

    if animation then
        animation.Completed:Once(finish)
    else
        task.delay(0.4, finish)
    end
end

function Window:Toggle()
    if self.hidden then
        self:Show()
    else
        self:Hide()
    end
end

function Window:_cleanup()
    if self.controls then
        for _, control in pairs(self.controls) do
            if type(control) == "table" and control._cleanup then
                pcall(control._cleanup, control)
            end
        end
    end

    if self._notificationRecords then
        local records = table.clone(self._notificationRecords)
        table.clear(self._notificationRecords)

        if self._liveNotifications then
            table.clear(self._liveNotifications)
        end

        for _, notification in ipairs(records) do
            if notification and notification._destroyImmediately then
                pcall(notification._destroyImmediately)
            end
        end
    end

    for _, connection in ipairs(self._connections) do
        pcall(connection.Disconnect, connection)
    end
    table.clear(self._connections)
end

function Window:Destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    self:_cleanup()

    tween(self.main, Tweens.Fast, {GroupTransparency = 1})
    tween(self.scale, Tweens.Fast, {Scale = 0.96})
    tween(self.shadow, Tweens.Fast, {Transparency = 1})
    tween(self.collapsedShell, Tweens.Fast, {BackgroundTransparency = 1})
    tween(self.collapsedShellStroke, Tweens.Fast, {Transparency = 1})
    tween(self.collapsedShellShadow, Tweens.Fast, {Transparency = 1})
    tween(self.collapsedFace, Tweens.Fast, {GroupTransparency = 1})

    if self.collapsedInteract then
        self.collapsedInteract.Visible = false
    end

    task.delay(0.17, function()
        if self.screen then
            self.screen:Destroy()
        end
    end)
end

function Aether:CreateWindow(options)
    options = type(options) == "table" and options or {}

    local name = option(options, "name", "Name") or "Aether"
    local subtitle = option(options, "subtitle", "Subtitle") or ""
    local icon = option(options, "icon", "Icon")

    if icon == nil then
        icon = "globe"
    end

    local requestedSize = option(options, "size", "Size")
    local width = Layout.Width
    local height = Layout.Height

    if typeof(requestedSize) == "Vector2" then
        width = math.max(560, math.floor(requestedSize.X))
        height = math.max(350, math.floor(requestedSize.Y))
    elseif typeof(requestedSize) == "UDim2" then
        if requestedSize.X.Offset > 0 then
            width = math.max(560, requestedSize.X.Offset)
        end
        if requestedSize.Y.Offset > 0 then
            height = math.max(350, requestedSize.Y.Offset)
        end
    end

    local theme = cloneTheme(option(options, "theme", "Theme"))
    local parent = resolveParent(options)
    local old = parent:FindFirstChild("AetherGen2")

    if old then
        old:Destroy()
    end

    local screen = create("ScreenGui", {
        Name = "AetherGen2",
        Parent = parent,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 1000
    })

    local notificationHolder = create("Frame", {
        Parent = screen,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.fromOffset(300, 800),
        BackgroundTransparency = 1,
        ZIndex = 890
    })

    local notificationList = create("Frame", {
        Parent = notificationHolder,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 890
    })

    create("UIListLayout", {
        Parent = notificationList,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    local main = create("CanvasGroup", {
        Parent = screen,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = theme.Window,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 1
    })

    local mainCorner = corner(main, 18)
    local mainStroke = stroke(main, theme.Stroke, 0.6, 1)
    local mainShadow = shadow(main, theme.Shadow, 20, 1)

    create("UIGradient", {
        Parent = main,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Window2),
            ColorSequenceKeypoint.new(0.23, theme.Window),
            ColorSequenceKeypoint.new(1, theme.Window)
        })
    })

    local clip = create("Frame", {
        Parent = main,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2
    })

    corner(clip, 18)

    local scale = create("UIScale", {
        Parent = main,
        Scale = 0.94
    })

    local topbar = create("CanvasGroup", {
        Parent = clip,
        Size = UDim2.new(1, 0, 0, Layout.TopbarHeight),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        ZIndex = 20
    })

    local dragArea = create("Frame", {
        Parent = topbar,
        Name = "DragArea",
        Size = UDim2.new(1, -Layout.ActionReserve, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 21
    })

    local iconHost = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ZIndex = 22
    })

    local mainIcon = makeIcon(iconHost, icon, theme.Secondary, 24, name)
    mainIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    mainIcon.Position = UDim2.fromScale(0.5, 0.5)

    local title = create("TextLabel", {
        Parent = topbar,
        Position = UDim2.fromOffset(58, subtitle ~= "" and 11 or 21),
        Size = UDim2.new(1, -190, 0, 21),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.Text,
        TextSize = 18,
        FontFace = FontSemiBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 22
    })

    local subtitleLabel = create("TextLabel", {
        Parent = topbar,
        Position = UDim2.fromOffset(58, 32),
        Size = UDim2.new(1, -190, 0, 16),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = theme.Secondary,
        TextTransparency = 0.35,
        TextSize = 13,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = subtitle ~= "",
        ZIndex = 22
    })

    create("Frame", {
        Parent = clip,
        Position = UDim2.fromOffset(0, Layout.TopbarHeight - 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.StrokeSoft,
        BackgroundTransparency = 0.68,
        ZIndex = 19
    })

    local actionContainer = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(98, 30),
        BackgroundTransparency = 1,
        ZIndex = 24
    })

    create("UIListLayout", {
        Parent = actionContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local function actionButton(order)
        return create("TextButton", {
            Parent = actionContainer,
            Size = UDim2.fromOffset(28, 28),
            BackgroundTransparency = 1,
            Text = "",
            TextTransparency = 1,
            AutoButtonColor = false,
            LayoutOrder = order,
            ZIndex = 25
        })
    end

    local searchButton = actionButton(1)
    local searchIconHost = create("Frame", {
        Parent = searchButton,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1
    })
    makeSearchIcon(searchIconHost, theme.Secondary, 16)

    local minimizeButton = actionButton(2)
    local minimizeIcon, minimizeLine, minimizeVLine = makeMinimizeIcon(minimizeButton, theme.Secondary)
    minimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeIcon.Position = UDim2.fromScale(0.5, 0.5)

    local closeButton = actionButton(3)
    local closeIcon, closeA, closeB = makeCloseIcon(closeButton, theme.Secondary)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)

    local collapsedShell = create("Frame", {
        Parent = screen,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 45),
        Size = UDim2.fromOffset(185, 50),
        BackgroundColor3 = theme.Window,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Active = true,
        Visible = false,
        ZIndex = 200
    })

    local collapsedShellCorner = corner(collapsedShell, 99)
    local collapsedShellStroke = stroke(collapsedShell, theme.Stroke, 0.6, 1)
    local collapsedShellShadow = shadow(collapsedShell, theme.Shadow, 20, 0.6)

    create("UIGradient", {
        Parent = collapsedShell,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Window2),
            ColorSequenceKeypoint.new(0.23, theme.Window),
            ColorSequenceKeypoint.new(1, theme.Window)
        })
    })

    local collapsedFace = create("CanvasGroup", {
        Parent = collapsedShell,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        ZIndex = 210
    })

    local collapsedIconHost = create("Frame", {
        Parent = collapsedFace,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        ZIndex = 211
    })

    local collapsedIcon = makeIcon(collapsedIconHost, icon, theme.Text, 24, name)
    collapsedIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    collapsedIcon.Position = UDim2.fromScale(0.5, 0.5)

    local collapsedText = create("Frame", {
        Parent = collapsedFace,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 50, 0.5, 0),
        Size = UDim2.new(1, -60, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 211
    })

    create("UIListLayout", {
        Parent = collapsedText,
        Padding = UDim.new(0, 1),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local collapsedTitle = create("TextLabel", {
        Parent = collapsedText,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.Text,
        TextSize = 16,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = 212
    })

    local collapsedSubtitle = create("TextLabel", {
        Parent = collapsedText,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = "Tap to show",
        TextColor3 = theme.Text,
        TextTransparency = 0.5,
        TextSize = 14,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 212
    })

    local collapsedInteract = create("TextButton", {
        Parent = screen,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 45),
        Size = UDim2.fromOffset(185, 50),
        BackgroundTransparency = 1,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        Active = true,
        Selectable = false,
        Visible = false,
        ZIndex = 10000
    })

    local body = create("CanvasGroup", {
        Parent = clip,
        Position = UDim2.fromOffset(0, Layout.TopbarHeight),
        Size = UDim2.new(1, 0, 1, -Layout.TopbarHeight),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        ZIndex = 3
    })

    local sidebar = create("Frame", {
        Parent = body,
        Size = UDim2.new(0, Layout.RailWidth, 1, 0),
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.28,
        ZIndex = 3
    })

    corner(sidebar, 18)

    create("Frame", {
        Parent = body,
        Position = UDim2.fromOffset(Layout.RailWidth - 1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = theme.StrokeSoft,
        BackgroundTransparency = 0.68,
        ZIndex = 4
    })

    local tabList = create("ScrollingFrame", {
        Parent = sidebar,
        Active = true,
        Size = UDim2.new(1, 0, 1, -Layout.FooterHeight),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 5
    })

    create("UIPadding", {
        Parent = tabList,
        PaddingTop = UDim.new(0, Layout.RailPadding),
        PaddingBottom = UDim.new(0, Layout.RailPadding)
    })

    create("UIListLayout", {
        Parent = tabList,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Layout.RowSpacing)
    })

    local profile = create("Frame", {
        Parent = sidebar,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.new(1, 0, 0, Layout.FooterHeight),
        BackgroundTransparency = 1,
        ZIndex = 6
    })

    local profileInner = create("Frame", {
        Parent = profile,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, Layout.RowInset, 0.5, 0),
        Size = UDim2.new(1, -Layout.RowInset * 2, 0, Layout.AvatarSize),
        BackgroundTransparency = 1,
        ZIndex = 7
    })

    local avatar = create("ImageLabel", {
        Parent = profileInner,
        Size = UDim2.fromOffset(Layout.AvatarSize, Layout.AvatarSize),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 8
    })

    corner(avatar, 99)

    create("TextLabel", {
        Parent = profileInner,
        Position = UDim2.fromOffset(Layout.AvatarSize + 10, 0),
        Size = UDim2.new(1, -(Layout.AvatarSize + 10), 1, 0),
        BackgroundTransparency = 1,
        Text = LocalPlayer and LocalPlayer.DisplayName or "Player",
        TextColor3 = theme.Text,
        TextTransparency = 0.04,
        TextSize = 16,
        FontFace = FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8
    })

    local pageHost = create("Frame", {
        Parent = body,
        Position = UDim2.fromOffset(Layout.RailWidth, 0),
        Size = UDim2.new(1, -Layout.RailWidth, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    })

    local searchPill = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -118, 0.5, 0),
        Size = UDim2.fromOffset(220, 32),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 30
    })

    corner(searchPill, 12)
    local searchPillStroke = stroke(searchPill, Color3.fromRGB(255, 255, 255), 1, 1)
    local searchPillGlow = shadow(searchPill, Color3.fromRGB(255, 255, 255), 20, 1)

    local searchBox = create("TextBox", {
        Parent = searchPill,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search this page",
        TextColor3 = theme.Text,
        PlaceholderColor3 = theme.Secondary,
        TextTransparency = 1,
        TextSize = 15,
        FontFace = FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 31
    })

    local window = setmetatable({
        screen = screen,
        main = main,
        mainCorner = mainCorner,
        mainStroke = mainStroke,
        scale = scale,
        topbar = topbar,
        dragArea = dragArea,
        actionContainer = actionContainer,
        body = body,
        sidebar = sidebar,
        tabList = tabList,
        pageHost = pageHost,
        profile = profile,
        avatar = avatar,
        title = title,
        subtitle = subtitleLabel,
        searchPill = searchPill,
        searchPillStroke = searchPillStroke,
        searchPillGlow = searchPillGlow,
        searchBox = searchBox,
        searchButton = searchButton,
        minimizeButton = minimizeButton,
        closeButton = closeButton,
        minimizeLine = minimizeLine,
        minimizeVLine = minimizeVLine,
        closeA = closeA,
        closeB = closeB,
        collapsedShell = collapsedShell,
        collapsedShellCorner = collapsedShellCorner,
        collapsedShellStroke = collapsedShellStroke,
        collapsedShellShadow = collapsedShellShadow,
        collapsedFace = collapsedFace,
        collapsedInteract = collapsedInteract,
        collapsedTitle = collapsedTitle,
        collapsedSubtitle = collapsedSubtitle,
        shadow = mainShadow,
        notificationList = notificationList,
        theme = theme,
        size = Vector2.new(width, height),
        tabs = {},
        controls = {},
        Flags = {},
        selectedTab = nil,
        minimized = false,
        hidden = false,
        animating = false,
        destroyed = false,
        _restorePosition = nil,
        _collapsedPosition = nil,
        _openPopup = nil,
        _liveNotifications = {},
        _notificationRecords = {},
        _notificationCount = 0,
        searchOpen = false,
        _connections = {}
    }, Window)

    screen.Destroying:Connect(function()
        window.destroyed = true
        window:_cleanup()
    end)

    local showProfile = option(options, "showProfile", "ShowProfile")
    if showProfile == false then
        profile.Visible = false
        tabList.Size = UDim2.new(1, 0, 1, 0)
    end

    registerConnection(window, closeButton.MouseEnter:Connect(function()
        tween(closeA, Tweens.Hover, {BackgroundColor3 = theme.Danger})
        tween(closeB, Tweens.Hover, {BackgroundColor3 = theme.Danger})
    end))

    registerConnection(window, closeButton.MouseLeave:Connect(function()
        tween(closeA, Tweens.Hover, {BackgroundColor3 = theme.Secondary})
        tween(closeB, Tweens.Hover, {BackgroundColor3 = theme.Secondary})
    end))

    registerConnection(window, minimizeButton.MouseButton1Click:Connect(function()
        window:Minimize()
    end))

    registerConnection(window, closeButton.MouseButton1Click:Connect(function()
        window:Hide()
    end))

    registerConnection(window, searchButton.MouseButton1Click:Connect(function()
        window.searchOpen = not window.searchOpen
        window:_updateDragArea()

        if window.searchOpen then
            searchPill.Visible = true
            searchPill.BackgroundTransparency = 1
            searchPillStroke.Transparency = 1
            searchBox.TextTransparency = 1

            tween(searchPill, Tweens.Hover, {BackgroundTransparency = 0.92})
            tween(searchPillStroke, Tweens.Hover, {Transparency = 0.86})
            tween(searchPillGlow, Tweens.Hover, {Transparency = 0.92})
            tween(searchBox, Tweens.Hover, {TextTransparency = 0.3})

            task.defer(function()
                if searchBox.Parent then
                    searchBox:CaptureFocus()
                end
            end)
        else
            searchBox:ReleaseFocus()
            searchBox.Text = ""
            window:_applySearch("")

            tween(searchPill, Tweens.Fast, {BackgroundTransparency = 1})
            tween(searchPillStroke, Tweens.Fast, {Transparency = 1})
            tween(searchPillGlow, Tweens.Fast, {Transparency = 1})
            tween(searchBox, Tweens.Fast, {TextTransparency = 1})

            task.delay(0.16, function()
                if searchPill.Parent and not window.searchOpen then
                    searchPill.Visible = false
                end
            end)
        end
    end))

    registerConnection(window, searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        window:_applySearch(searchBox.Text)
    end))

    local dragging = false
    local dragStart = Vector2.zero
    local startPos = main.Position

    registerConnection(window, topbar.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local p = input.Position
        local actionPos = actionContainer.AbsolutePosition
        local actionSize = actionContainer.AbsoluteSize

        if p.X >= actionPos.X and p.X <= actionPos.X + actionSize.X
            and p.Y >= actionPos.Y and p.Y <= actionPos.Y + actionSize.Y then
            return
        end

        if searchPill.Visible then
            local searchPos = searchPill.AbsolutePosition
            local searchSize = searchPill.AbsoluteSize

            if p.X >= searchPos.X and p.X <= searchPos.X + searchSize.X
                and p.Y >= searchPos.Y and p.Y <= searchPos.Y + searchSize.Y then
                return
            end
        end

        dragging = true
        dragStart = Vector2.new(p.X, p.Y)
        startPos = main.Position
    end))

    registerConnection(window, UserInputService.InputChanged:Connect(function(input)
        if not dragging or window.destroyed or window.hidden or window.animating then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    registerConnection(window, UserInputService.WindowFocusReleased:Connect(function()
        dragging = false
    end))

    local collapsedDragging = false
    local collapsedMoved = false
    local collapsedDragStart = Vector2.zero
    local collapsedStartPos = collapsedShell.Position

    registerConnection(window, collapsedInteract.InputBegan:Connect(function(input)
        if not window.hidden or window.animating then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        collapsedDragging = true
        collapsedMoved = false
        collapsedDragStart = Vector2.new(input.Position.X, input.Position.Y)
        collapsedStartPos = collapsedShell.Position
    end))

    registerConnection(window, UserInputService.InputChanged:Connect(function(input)
        if not collapsedDragging or not window.hidden or window.animating then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - collapsedDragStart

        if delta.Magnitude >= 5 then
            collapsedMoved = true
        end

        if collapsedMoved then
            local position = UDim2.new(
                collapsedStartPos.X.Scale,
                collapsedStartPos.X.Offset + delta.X,
                collapsedStartPos.Y.Scale,
                collapsedStartPos.Y.Offset + delta.Y
            )

            collapsedShell.Position = position
            collapsedInteract.Position = position
            window._collapsedPosition = position
        end
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if collapsedDragging then
            collapsedDragging = false

            if not collapsedMoved and window.hidden and not window.animating then
                window:Show()
            end
        end
    end))

    registerConnection(window, collapsedInteract.MouseEnter:Connect(function()
        if window.hidden and not window.animating then
            tween(collapsedShellStroke, Tweens.Hover, {Transparency = 0.38})
            tween(collapsedShellShadow, Tweens.Hover, {Transparency = 0.48})
        end
    end))

    registerConnection(window, collapsedInteract.MouseLeave:Connect(function()
        tween(collapsedShellStroke, Tweens.Hover, {Transparency = 0.6})
        tween(collapsedShellShadow, Tweens.Hover, {Transparency = 0.6})
    end))

    registerConnection(window, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if not window._openPopup then
            return
        end

        local popup = window._openPopup.popup
        local field = window._openPopup.field
        local position = Vector2.new(input.Position.X, input.Position.Y)

        local function inside(gui)
            local absolutePosition = gui.AbsolutePosition
            local absoluteSize = gui.AbsoluteSize
            return position.X >= absolutePosition.X
                and position.X <= absolutePosition.X + absoluteSize.X
                and position.Y >= absolutePosition.Y
                and position.Y <= absolutePosition.Y + absoluteSize.Y
        end

        if not inside(popup) and not inside(field) then
            window:_closePopups()
        end
    end))

    if LocalPlayer then
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)

            if ok and avatar.Parent then
                avatar.Image = image
            end
        end)
    end

    local toggleKeybind = option(options, "toggleKeybind", "ToggleKeybind")
    if typeof(toggleKeybind) == "EnumItem" and toggleKeybind.EnumType == Enum.KeyCode then
        registerConnection(window, UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == toggleKeybind then
                window:Toggle()
            end
        end))
    end

    main.Position = UDim2.new(0.5, 0, 0.5, 10)
    tween(main, Tweens.Reveal, {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tween(scale, Tweens.Reveal, {Scale = 1})
    tween(mainShadow, Tweens.Reveal, {Transparency = 0.6})

    return window
end

function Aether:Notify(options)
    if self._lastWindow and not self._lastWindow.destroyed then
        return self._lastWindow:Notify(options)
    end

    warn("Aether: create a window before calling Aether:Notify")
    return nil
end

local originalCreateWindow = Aether.CreateWindow

function Aether:CreateWindow(options)
    local window = originalCreateWindow(self, options)
    self._lastWindow = window
    return window
end

return Aether
