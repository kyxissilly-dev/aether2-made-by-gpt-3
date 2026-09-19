local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Aether = {}
Aether.__index = Aether
Aether.Version = "0.4.1"

local DEFAULT = {
    Window = Color3.fromRGB(18, 18, 19),
    Window2 = Color3.fromRGB(22, 22, 23),
    Sidebar = Color3.fromRGB(17, 17, 18),

    -- Rayfield Gen2 default element palette.
    Element = Color3.fromRGB(30, 30, 30),
    Element2 = Color3.fromRGB(35, 35, 35),
    ElementHover = Color3.fromRGB(255, 255, 255),
    ElementHoverStroke = Color3.fromRGB(50, 50, 50),
    ElementTransparency = 0,
    ElementStrokeTransparency = 0,
    ElementStrokeHoverTransparency = 0,

    -- Rayfield Gen2 sidebar tab palette.
    Tab = Color3.fromRGB(50, 50, 50),
    TabBottom = Color3.fromRGB(35, 35, 35),
    TabStrokeTop = Color3.fromRGB(95, 95, 95),
    TabStrokeBottom = Color3.fromRGB(50, 50, 50),

    Stroke = Color3.fromRGB(35, 35, 35),
    StrokeSoft = Color3.fromRGB(62, 62, 67),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(178, 178, 178),
    Muted = Color3.fromRGB(112, 112, 119),

    Field = Color3.fromRGB(255, 255, 255),
    FieldHover = Color3.fromRGB(255, 255, 255),

    -- Rayfield Gen2 default toggle styling.
    Accent = Color3.fromRGB(23, 153, 110),
    AccentStroke = Color3.fromRGB(32, 201, 144),
    AccentGlow = 0.4,
    ToggleTrack = Color3.fromRGB(0, 0, 0),
    ToggleTrackTransparency = 0.9,
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    ToggleKnobOn = Color3.fromRGB(23, 153, 110),
    ToggleKnobOffTransparency = 0.8,

    Danger = Color3.fromRGB(215, 115, 120),
    Shadow = Color3.fromRGB(20, 20, 20),
    Glow = Color3.fromRGB(255, 255, 255),
}

local LAYOUT = {
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
    ElementHeight = 41,
    ButtonHeight = 43,
    ElementInset = 10,
    ElementContentInset = 20,
}

local TWEEN = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Hover = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Move = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
    Reveal = TweenInfo.new(0.42, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
}


local function create(className, props)
    local object = Instance.new(className)
    for k, v in pairs(props or {}) do
        object[k] = v
    end
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius),
    })
end

local function cornerMask(parent, radius, topLeft, topRight, bottomLeft, bottomRight)
    local mask = create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, 0),
    })

    local ok = pcall(function()
        mask.TopLeftRadius = UDim.new(0, topLeft and radius or 0)
        mask.TopRightRadius = UDim.new(0, topRight and radius or 0)
        mask.BottomLeftRadius = UDim.new(0, bottomLeft and radius or 0)
        mask.BottomRightRadius = UDim.new(0, bottomRight and radius or 0)
    end)

    if not ok then
        mask.CornerRadius = UDim.new(0, radius)
    end

    return mask
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function glow(parent, color, blurRadius, transparency, offset, spread)
    local ok, result = pcall(function()
        local props = {
            Parent = parent,
            Color = color,
            BlurRadius = UDim.new(0, blurRadius or 20),
            Transparency = transparency == nil and 1 or transparency,
            ZIndex = -1,
        }
        if offset then
            props.Offset = offset
        end
        if spread then
            props.Spread = spread
        end
        return create("UIShadow", props)
    end)
    return ok and result or nil
end

local function tween(object, info, props)
    local t = TweenService:Create(object, info, props)
    t:Play()
    return t
end

local function pick(tbl, ...)
    if type(tbl) ~= "table" then
        return nil
    end
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        local value = tbl[key]
        if value ~= nil then
            return value
        end
    end
    return nil
end

local function mergeTheme(overrides)
    local out = table.clone(DEFAULT)
    if type(overrides) == "table" then
        for k, v in pairs(overrides) do
            if out[k] ~= nil and typeof(v) == typeof(out[k]) then
                out[k] = v
            end
        end
    end
    return out
end

local function baseFont(weight)
    local ok, base = pcall(Font.fromEnum, Enum.Font.BuilderSans)
    if ok and base then
        return Font.new(base.Family, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    end
    local fallback = Font.fromEnum(Enum.Font.Gotham)
    return Font.new(fallback.Family, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end

local FONT_MEDIUM = baseFont(Enum.FontWeight.Medium)
local FONT_SEMIBOLD = baseFont(Enum.FontWeight.SemiBold)
local FONT_REGULAR = baseFont(Enum.FontWeight.Regular)

local function iconImageValue(icon)
    if type(icon) == "number" then
        return "rbxassetid://" .. tostring(icon)
    end
    if type(icon) ~= "string" then
        return nil
    end
    if icon:match("^%d+$") then
        return "rbxassetid://" .. icon
    end
    if icon:match("^rbxassetid://") or icon:match("^rbxthumb://") or icon:match("^rbxasset://") then
        return icon
    end
    return nil
end

local function builtinEye(parent, color, size)
    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    })

    local outline = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.floor(size * 0.9), math.floor(size * 0.56)),
        BackgroundTransparency = 1,
    })
    corner(outline, size)
    stroke(outline, color, 0.12, 1.25)

    local pupil = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.max(4, math.floor(size * 0.23)), math.max(4, math.floor(size * 0.23))),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    corner(pupil, size)

    return holder
end

local function builtinGlobe(parent, color, size)
    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    })

    local outer = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size - 2, size - 2),
        BackgroundTransparency = 1,
    })
    corner(outer, size)
    stroke(outer, color, 0.16, 1.2)

    local vertical = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.floor(size * 0.36), size - 4),
        BackgroundTransparency = 1,
    })
    corner(vertical, size)
    stroke(vertical, color, 0.3, 1)

    create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size - 5, 1),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    })

    return holder
end

local function builtinSearch(parent, color, size)
    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    })

    local ring = create("Frame", {
        Parent = holder,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(size - 7, size - 7),
        BackgroundTransparency = 1,
    })
    corner(ring, size)
    stroke(ring, color, 0.15, 1.35)

    create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(math.floor(size * 0.38), 1),
        Rotation = 45,
        BackgroundColor3 = color,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    })

    return holder
end

local function builtinInitial(parent, text, color, size)
    return create("TextLabel", {
        Parent = parent,
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Text = string.upper(string.sub(tostring(text or "?"), 1, 1)),
        TextColor3 = color,
        TextTransparency = 0.15,
        TextSize = math.max(12, size - 4),
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
end

local function makeIcon(parent, icon, color, size, fallbackText)
    local image = iconImageValue(icon)
    if image then
        return create("ImageLabel", {
            Parent = parent,
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            Image = image,
            ImageColor3 = color,
            ImageTransparency = 0.08,
            ScaleType = Enum.ScaleType.Fit,
        })
    end

    local name = type(icon) == "string" and string.lower(icon) or nil
    if name == "eye" then
        return builtinEye(parent, color, size)
    elseif name == "globe" then
        return builtinGlobe(parent, color, size)
    elseif name == "search" then
        return builtinSearch(parent, color, size)
    end

    return builtinInitial(parent, fallbackText, color, size)
end

local function makeCloseIcon(parent, color)
    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
    })
    local a = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 1),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    local b = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 1),
        Rotation = -45,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    return holder, a, b
end

local function makeMinusIcon(parent, color)
    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
    })
    local line = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })
    return holder, line
end

local function resolveParent(config)
    local explicit = pick(config, "parent", "Parent")
    if explicit and typeof(explicit) == "Instance" then
        return explicit
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

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Toggle = {}
Toggle.__index = Toggle

local Button = {}
Button.__index = Button

local function registerConnection(window, connection)
    table.insert(window._connections, connection)
    return connection
end

local function setTabVisual(tab, state, instant)
    local states = {
        selected = { background = 0.4, stroke = 0.5, content = 0, shadow = 0.8 },
        hover = { background = 0.7, stroke = 0.8, content = 0.3, shadow = 1 },
        unselected = { background = 1, stroke = 1, content = 0.5, shadow = 1 },
    }

    local visual = states[state] or states.unselected

    local function apply(object, props)
        if not object then
            return
        end
        if instant then
            for k, v in pairs(props) do
                object[k] = v
            end
        else
            tween(object, TWEEN.Hover, props)
        end
    end

    apply(tab.selector, { BackgroundTransparency = visual.background })
    apply(tab.selectorStroke, { Transparency = visual.stroke })
    apply(tab.selectorTitle, { TextTransparency = visual.content })
    apply(tab.selectorShadow, { Transparency = visual.shadow })

    if tab.selectorIcon then
        if tab.selectorIcon:IsA("ImageLabel") then
            apply(tab.selectorIcon, { ImageTransparency = visual.content })
        else
            apply(tab.selectorIcon, { GroupTransparency = visual.content })
        end
    end
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

function Tab:_addElement(handle)
    table.insert(self.elements, handle)
    handle.main.LayoutOrder = #self.elements * 10
    return handle
end

function Tab:CreateSection(config)
    local name
    if type(config) == "string" then
        name = config
    else
        name = pick(config, "name", "Name") or "Section"
    end

    local topPad = #self.elements > 0 and 13 or 0
    local frame = create("Frame", {
        Parent = self.page,
        Size = UDim2.new(1, -40, 0, 20 + topPad),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    local label = create("TextLabel", {
        Parent = frame,
        Position = UDim2.fromOffset(0, topPad),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.window.theme.Text,
        TextTransparency = 0.42,
        TextSize = 15,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    local handle = {
        main = frame,
        label = label,
        name = name,
        isSection = true,
        searchName = "",
    }

    function handle:Set(text)
        self.name = tostring(text)
        self.label.Text = self.name
    end

    return self:_addElement(handle)
end

local function buildElementBase(tab, height, config)
    local window = tab.window
    local name = pick(config, "name", "Name") or "Element"
    local icon = pick(config, "icon", "Icon")

    local main = create("Frame", {
        Parent = tab.page,
        Size = UDim2.new(1, -20, 0, height),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = window.theme.ElementTransparency,
        BorderSizePixel = 0,
    })
    corner(main, 12)

    -- Gen2 StyleElementBody: a simple vertical element gradient + clean stroke.
    local elementGradient = create("UIGradient", {
        Parent = main,
        Rotation = 270,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, window.theme.Element),
            ColorSequenceKeypoint.new(0.9999, window.theme.Element2),
            ColorSequenceKeypoint.new(1, window.theme.Element2),
        }),
    })

    local bodyStroke = stroke(main, window.theme.Stroke, window.theme.ElementStrokeTransparency, 1)

    -- Gen2 CreateHoverOverlay: almost invisible white wash on hover.
    local hover = create("Frame", {
        Parent = main,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    corner(hover, 12)

    local content = create("Frame", {
        Parent = main,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, LAYOUT.ElementContentInset, 0.5, 0),
        Size = UDim2.new(0, 250, 0, 18),
        BackgroundTransparency = 1,
        ZIndex = 4,
    })

    create("UIListLayout", {
        Parent = content,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
    })

    local iconObject
    if icon ~= nil and icon ~= 0 and icon ~= "" then
        iconObject = makeIcon(content, icon, window.theme.Text, 16, name)
        iconObject.LayoutOrder = 0
    end

    local title = create("TextLabel", {
        Parent = content,
        Size = UDim2.fromOffset(250, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = window.theme.Text,
        TextTransparency = 0,
        TextSize = 16,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 1,
        ZIndex = 4,
    })

    local interact = create("TextButton", {
        Parent = main,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 10,
    })

    registerConnection(window, main.MouseEnter:Connect(function()
        tween(bodyStroke, TWEEN.Hover, {
            Transparency = window.theme.ElementStrokeHoverTransparency,
            Color = window.theme.ElementHoverStroke,
        })
        tween(title, TWEEN.Hover, { TextColor3 = window.theme.Text })
        tween(hover, TWEEN.Hover, { BackgroundTransparency = 0.97 })
    end))

    registerConnection(window, main.MouseLeave:Connect(function()
        tween(bodyStroke, TWEEN.Hover, {
            Transparency = window.theme.ElementStrokeTransparency,
            Color = window.theme.Stroke,
        })
        tween(title, TWEEN.Hover, { TextColor3 = window.theme.Text })
        tween(hover, TWEEN.Hover, { BackgroundTransparency = 1 })
    end))

    return {
        main = main,
        stroke = bodyStroke,
        gradient = elementGradient,
        hover = hover,
        content = content,
        title = title,
        interact = interact,
        icon = iconObject,
        name = name,
        searchName = string.lower(name),
    }
end

function Tab:CreateToggle(config)
    config = type(config) == "table" and config or {}
    local base = buildElementBase(self, LAYOUT.ElementHeight, config)
    local window = self.window

    local callback = pick(config, "callback", "Callback") or function() end
    local flag = pick(config, "flag", "Flag") or string.lower((base.name:gsub("%s+", "_")))
    local value = pick(config, "value", "Value", "currentValue", "CurrentValue")
    if value == nil then
        value = false
    end
    value = value == true

    -- Exact Gen2 full toggle track dimensions.
    local pill = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0, 20),
        Size = UDim2.fromOffset(50, 21),
        BackgroundColor3 = window.theme.ToggleTrack,
        BackgroundTransparency = window.theme.ToggleTrackTransparency,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    corner(pill, 15)
    local pillStroke = stroke(pill, Color3.fromRGB(255, 255, 255), 0.85, 1)

    -- Gen2's subtle dark lower-half track overlay.
    local trackOverlay = create("Frame", {
        Parent = pill,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    corner(trackOverlay, 15)
    create("UIGradient", {
        Parent = trackOverlay,
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(30, 30, 30)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.35),
        }),
    })

    local knob = create("Frame", {
        Parent = pill,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = value and UDim2.new(1, -28, 0.5, 0) or UDim2.new(1, -47, 0.5, 0),
        Size = UDim2.fromOffset(25, 17),
        BackgroundColor3 = value and window.theme.Accent or window.theme.ToggleKnob,
        BackgroundTransparency = value and 0 or window.theme.ToggleKnobOffTransparency,
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    corner(knob, 99)

    local knobStroke = stroke(
        knob,
        value and window.theme.AccentStroke or Color3.fromRGB(255, 255, 255),
        value and 0 or 0.7,
        1
    )

    -- This is the actual Gen2 radial glow: UIShadow on the indicator itself.
    local knobGlow = glow(knob, window.theme.Accent, 20, value and window.theme.AccentGlow or 1)

    local handle = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        interact = base.interact,
        baseStroke = base.stroke,
        pill = pill,
        pillStroke = pillStroke,
        trackOverlay = trackOverlay,
        knob = knob,
        knobStroke = knobStroke,
        knobGlow = knobGlow,
        name = base.name,
        searchName = base.searchName,
        flag = flag,
        callback = callback,
        value = value,
    }, Toggle)

    window.controls[flag] = handle
    window.Flags[flag] = value

    handle:_render(true)

    registerConnection(window, base.interact.MouseButton1Click:Connect(function()
        tween(base.stroke, TWEEN.Hover, { Transparency = 1 })
        tween(base.main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -26, 0, LAYOUT.ElementHeight),
        })

        handle:Set(not handle.value)

        task.delay(0.11, function()
            if not base.main.Parent then
                return
            end
            tween(base.main, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 0, LAYOUT.ElementHeight),
            })
            tween(base.stroke, TWEEN.Hover, {
                Transparency = window.theme.ElementStrokeTransparency,
            })
        end)
    end))

    return self:_addElement(handle)
end

function Toggle:_render(instant)
    local on = self.value
    local propsKnob = {
        Position = on and UDim2.new(1, -28, 0.5, 0) or UDim2.new(1, -47, 0.5, 0),
        BackgroundColor3 = on and self.window.theme.Accent or self.window.theme.ToggleKnob,
        BackgroundTransparency = on and 0 or self.window.theme.ToggleKnobOffTransparency,
    }
    local propsStroke = {
        Color = on and self.window.theme.AccentStroke or Color3.fromRGB(255, 255, 255),
        Transparency = on and 0 or 0.7,
    }
    local glowTransparency = on and self.window.theme.AccentGlow or 1

    if instant then
        for k, v in pairs(propsKnob) do
            self.knob[k] = v
        end
        for k, v in pairs(propsStroke) do
            self.knobStroke[k] = v
        end
        if self.knobGlow then
            self.knobGlow.Color = self.window.theme.Accent
            self.knobGlow.Transparency = glowTransparency
        end
        self.pill.BackgroundColor3 = self.window.theme.ToggleTrack
        self.pill.BackgroundTransparency = self.window.theme.ToggleTrackTransparency
        return
    end

    local info = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    tween(self.knob, info, propsKnob)
    tween(self.knobStroke, info, propsStroke)
    tween(self.pill, info, {
        BackgroundColor3 = self.window.theme.ToggleTrack,
        BackgroundTransparency = self.window.theme.ToggleTrackTransparency,
    })
    if self.knobGlow then
        self.knobGlow.Color = self.window.theme.Accent
        tween(self.knobGlow, info, { Transparency = glowTransparency })
    end
end

function Toggle:Set(value, silent)
    self.value = value == true
    self.window.Flags[self.flag] = self.value
    self:_render(false)
    if not silent then
        task.spawn(function()
            local ok, err = pcall(self.callback, self.value)
            if not ok then
                warn("Aether toggle callback error: " .. tostring(err))
            end
        end)
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

function Tab:CreateButton(config)
    config = type(config) == "table" and config or {}
    local base = buildElementBase(self, LAYOUT.ButtonHeight, config)
    local callback = pick(config, "callback", "Callback") or function() end

    local handle = setmetatable({
        window = self.window,
        tab = self,
        main = base.main,
        title = base.title,
        name = base.name,
        searchName = base.searchName,
        callback = callback,
    }, Button)

    registerConnection(self.window, base.interact.MouseButton1Click:Connect(function()
        tween(base.stroke, TWEEN.Hover, { Transparency = 1 })
        tween(base.main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -26, 0, LAYOUT.ButtonHeight),
        })

        task.spawn(function()
            local ok, err = pcall(callback)
            if not ok then
                warn("Aether button callback error: " .. tostring(err))
            end
        end)

        task.delay(0.11, function()
            if not base.main.Parent then
                return
            end
            tween(base.main, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 0, LAYOUT.ButtonHeight),
            })
            tween(base.stroke, TWEEN.Hover, {
                Transparency = self.window.theme.ElementStrokeTransparency,
            })
        end)
    end))

    return self:_addElement(handle)
end

function Button:Fire()
    local ok, err = pcall(self.callback)
    if not ok then
        warn("Aether button callback error: " .. tostring(err))
    end
end

function Button:SetName(name)
    self.name = tostring(name)
    self.searchName = string.lower(self.name)
    self.title.Text = self.name
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

function Window:CreateTab(config)
    config = type(config) == "table" and config or {}
    local name = pick(config, "name", "Name") or "Tab"
    local icon = pick(config, "icon", "Icon")

    local selector = create("TextButton", {
        Parent = self.tabList,
        Size = UDim2.new(1, -LAYOUT.RowInset * 2, 0, LAYOUT.RowHeight),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
    })
    corner(selector, LAYOUT.RowCorner)

    -- Exact Gen2 sidebar tab surface and border gradients.
    local selectorGradient = create("UIGradient", {
        Parent = selector,
        Rotation = 90,
        Color = ColorSequence.new(self.theme.Tab, self.theme.TabBottom),
    })

    local selectorStroke = stroke(selector, Color3.fromRGB(255, 255, 255), 1, 1)
    local selectorStrokeGradient = create("UIGradient", {
        Parent = selectorStroke,
        Rotation = 90,
        Color = ColorSequence.new(self.theme.TabStrokeTop, self.theme.TabStrokeBottom),
    })

    -- Exact Gen2 sidebar selector shadow geometry. This is intentionally directional/radial.
    local selectorShadow = glow(
        selector,
        Color3.fromRGB(255, 255, 255),
        20,
        1,
        UDim2.new(0, 0, 0, -15),
        UDim2.new(0, 10, 0, -30)
    )

    local selectorContent = create("Frame", {
        Parent = selector,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, LAYOUT.RowPadding, 0.5, 0),
        Size = UDim2.new(1, -LAYOUT.RowPadding, 0, 24),
        BackgroundTransparency = 1,
    })

    create("UIListLayout", {
        Parent = selectorContent,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, LAYOUT.RowContentSpacing),
    })

    local selectorIcon
    if icon ~= nil and icon ~= 0 and icon ~= "" then
        local raw = makeIcon(selectorContent, icon, self.theme.Text, LAYOUT.RowIconSize, name)
        if raw:IsA("GuiObject") and not raw:IsA("CanvasGroup") then
            local group = create("CanvasGroup", {
                Parent = selectorContent,
                Size = UDim2.fromOffset(LAYOUT.RowIconSize, LAYOUT.RowIconSize),
                BackgroundTransparency = 1,
            })
            raw.Parent = group
            raw.Position = UDim2.fromOffset(0, 0)
            raw.AnchorPoint = Vector2.zero
            selectorIcon = group
            group.LayoutOrder = 0
        else
            selectorIcon = raw
        end
    else
        selectorIcon = create("CanvasGroup", {
            Parent = selectorContent,
            Size = UDim2.fromOffset(LAYOUT.RowIconSize, LAYOUT.RowIconSize),
            BackgroundTransparency = 1,
            GroupTransparency = 0.5,
            LayoutOrder = 0,
        })
        builtinInitial(selectorIcon, name, self.theme.Text, LAYOUT.RowIconSize)
    end

    local selectorTitle = create("TextLabel", {
        Parent = selectorContent,
        Size = UDim2.fromOffset(120, 16),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.theme.Text,
        TextTransparency = 0.5,
        TextSize = 16,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 1,
    })

    local page = create("ScrollingFrame", {
        Parent = self.pageHost,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    })

    create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 17),
        PaddingBottom = UDim.new(0, 17),
    })

    create("UIListLayout", {
        Parent = page,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
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
        selectorIcon = selectorIcon,
        selectorTitle = selectorTitle,
        page = page,
        elements = {},
    }, Tab)

    table.insert(self.tabs, tab)
    selector.LayoutOrder = #self.tabs * 10

    local function spinGradients()
        local info = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        for _, gradient in ipairs({ selectorGradient, selectorStrokeGradient }) do
            gradient.Rotation = -270
            tween(gradient, info, { Rotation = 90 })
        end
    end

    registerConnection(self, selector.MouseEnter:Connect(function()
        if self.selectedTab ~= tab then
            setTabVisual(tab, "hover", false)
            spinGradients()
        end
    end))

    registerConnection(self, selector.MouseLeave:Connect(function()
        if self.selectedTab ~= tab then
            setTabVisual(tab, "unselected", false)
        end
    end))

    registerConnection(self, selector.MouseButton1Click:Connect(function()
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

function Window:Minimize(state)
    if state == nil then
        state = not self.minimized
    end
    state = state == true
    if self.minimized == state or self.animating or self.hidden then
        return
    end

    self.minimized = state
    self.animating = true

    if state then
        tween(self.body, TWEEN.Fast, { GroupTransparency = 1 })
        task.delay(0.12, function()
            if self.main.Parent and self.minimized then
                self.body.Visible = false
            end
        end)
        tween(self.main, TWEEN.Move, { Size = UDim2.fromOffset(self.size.X, LAYOUT.TopbarHeight) })
        tween(self.minimizeLine, TWEEN.Hover, { Rotation = 90 })
    else
        self.body.Visible = true
        self.body.GroupTransparency = 1
        tween(self.main, TWEEN.Move, { Size = UDim2.fromOffset(self.size.X, self.size.Y) })
        tween(self.minimizeLine, TWEEN.Hover, { Rotation = 0 })
        task.delay(0.09, function()
            if self.main.Parent and not self.minimized then
                tween(self.body, TWEEN.Reveal, { GroupTransparency = 0 })
            end
        end)
    end

    task.delay(0.38, function()
        self.animating = false
    end)
end

function Window:Show()
    if self.destroyed or not self.hidden or self.animating then return end

    self.animating = true
    self.hidden = false
    self.screen.Enabled = true
    self.main.Visible = true
    self.main.GroupTransparency = 0
    self.scale.Scale = 1

    local restorePosition = self._restorePosition or UDim2.new(0.5, 0, 0.5, 0)
    local moveInfo = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
    local chromeInfo = TweenInfo.new(0.28, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local collapsedFade = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    self.collapsedFace.Visible = true
    tween(self.collapsedFace, collapsedFade, { GroupTransparency = 1 })
    self.collapsedInteract.Active = false

    task.delay(0.15, function()
        if self.collapsedFace and self.collapsedFace.Parent and not self.hidden then
            self.collapsedFace.Visible = false
        end
    end)

    tween(self.main, moveInfo, {
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        Position = restorePosition,
    })
    tween(self.mainCorner, moveInfo, { CornerRadius = UDim.new(0, 18) })
    tween(self.clipCorner, moveInfo, { CornerRadius = UDim.new(0, 18) })

    task.delay(0.22, function()
        if self.hidden or self.destroyed then return end

        self.topbar.Visible = true
        self.body.Visible = true
        self.topbar.GroupTransparency = 1
        self.body.GroupTransparency = 1

        tween(self.shadow, chromeInfo, { Transparency = 0.6 })
        tween(self.mainStroke, chromeInfo, { Transparency = 0.6 })
        tween(self.topbar, chromeInfo, { GroupTransparency = 0 })
        tween(self.body, chromeInfo, { GroupTransparency = 0 })
    end)

    task.delay(0.6, function()
        if not self.destroyed and not self.hidden then
            self.animating = false
        end
    end)
end

function Window:Hide()
    if self.destroyed or self.hidden or self.animating then return end

    self.animating = true
    self.hidden = true
    self._restorePosition = self.main.Position

    -- The collapsed pill is the same main window, so keep the outer window fully
    -- visible while its normal contents fade away and the frame morphs upward.
    self.screen.Enabled = true
    self.main.Visible = true
    self.main.GroupTransparency = 0
    self.scale.Scale = 1

    if self.minimized then
        self.minimized = false
        self.minimizeLine.Rotation = 0
    end

    if self.searchOpen then
        self.searchOpen = false
        self.searchBox:ReleaseFocus()
        self.searchBox.Text = ""
        self:_applySearch("")
        self.searchPill.Visible = false
    end

    local collapsedSize = UDim2.fromOffset(185, 50)
    local collapsedPosition = self._collapsedPosition or UDim2.new(0.5, 0, 0, 45)
    local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local moveInfo = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
    local revealInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(self.topbar, fadeInfo, { GroupTransparency = 1 })
    tween(self.body, fadeInfo, { GroupTransparency = 1 })
    tween(self.shadow, fadeInfo, { Transparency = 1 })
    tween(self.mainStroke, fadeInfo, { Transparency = 1 })

    self.collapsedFace.Visible = true
    self.collapsedFace.GroupTransparency = 1
    self.collapsedFace.ZIndex = 100
    self.collapsedInteract.Visible = true
    self.collapsedInteract.Active = false

    local movement = tween(self.main, moveInfo, {
        Size = collapsedSize,
        Position = collapsedPosition,
    })
    tween(self.mainCorner, moveInfo, { CornerRadius = UDim.new(1, 0) })
    tween(self.clipCorner, moveInfo, { CornerRadius = UDim.new(1, 0) })

    task.delay(0.18, function()
        if not self.hidden or self.destroyed then return end
        self.topbar.Visible = false
        self.body.Visible = false
        tween(self.collapsedFace, revealInfo, { GroupTransparency = 0 })
    end)

    movement.Completed:Connect(function()
        if self.destroyed or not self.hidden then return end
        self.collapsedInteract.Active = true
        self.animating = false
    end)
end

function Window:Toggle()
    if self.hidden then
        self:Show()
    else
        self:Hide()
    end
end

function Window:Destroy()
    if self.destroyed then return end
    self.destroyed = true

    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self._connections)

    tween(self.main, TWEEN.Fast, { GroupTransparency = 1 })
    tween(self.scale, TWEEN.Fast, { Scale = 0.96 })
    tween(self.shadow, TWEEN.Fast, { Transparency = 1 })

    task.delay(0.17, function()
        if self.screen then
            self.screen:Destroy()
        end
    end)
end

function Aether:CreateWindow(config)
    config = type(config) == "table" and config or {}

    local name = pick(config, "name", "Name") or "Aether"
    local subtitle = pick(config, "subtitle", "Subtitle") or ""
    local icon = pick(config, "icon", "Icon")
    if icon == nil then icon = "globe" end

    local sizeValue = pick(config, "size", "Size")
    local width, height = LAYOUT.Width, LAYOUT.Height
    if typeof(sizeValue) == "Vector2" then
        width = math.max(560, math.floor(sizeValue.X))
        height = math.max(350, math.floor(sizeValue.Y))
    elseif typeof(sizeValue) == "UDim2" then
        if sizeValue.X.Offset > 0 then width = math.max(560, sizeValue.X.Offset) end
        if sizeValue.Y.Offset > 0 then height = math.max(350, sizeValue.Y.Offset) end
    end

    local theme = mergeTheme(pick(config, "theme", "Theme"))
    local parent = resolveParent(config)

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
        DisplayOrder = 1000,
    })

    local main = create("CanvasGroup", {
        Parent = screen,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = theme.Window,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 1,
    })
    local mainCorner = corner(main, 18)
    local mainStroke = stroke(main, theme.Stroke, 0.6, 1)

    local shadow = create("UIShadow", {
        Parent = main,
        Color = theme.Shadow,
        BlurRadius = UDim.new(0, 20),
        Transparency = 1,
        ZIndex = -1,
    })

    create("UIGradient", {
        Parent = main,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Window2),
            ColorSequenceKeypoint.new(0.23, theme.Window),
            ColorSequenceKeypoint.new(1, theme.Window),
        }),
    })

    -- Dedicated clipping wrapper so the sidebar cannot escape the rounded silhouette.
    -- This frame is a plain Frame with ClipsDescendants and a matching UICorner,
    -- which reliably clips children even when they are CanvasGroups.
    local clip = create("Frame", {
        Parent = main,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    local clipCorner = corner(clip, 18)

    local scale = create("UIScale", {
        Parent = main,
        Scale = 0.94,
    })

    local topbar = create("CanvasGroup", {
        Parent = clip,
        Size = UDim2.new(1, 0, 0, LAYOUT.TopbarHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        ZIndex = 20,
    })

    local brandIconHolder = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ZIndex = 22,
    })
    local brandIcon = makeIcon(brandIconHolder, icon, theme.Secondary, 24, name)
    brandIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    brandIcon.Position = UDim2.fromScale(0.5, 0.5)

    local title = create("TextLabel", {
        Parent = topbar,
        Position = UDim2.fromOffset(58, subtitle ~= "" and 11 or 21),
        Size = UDim2.new(1, -190, 0, 21),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.Text,
        TextSize = 18,
        FontFace = FONT_SEMIBOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 22,
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
        FontFace = FONT_REGULAR,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = subtitle ~= "",
        ZIndex = 22,
    })

    create("Frame", {
        Parent = clip,
        Position = UDim2.fromOffset(0, LAYOUT.TopbarHeight - 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.StrokeSoft,
        BackgroundTransparency = 0.68,
        BorderSizePixel = 0,
        ZIndex = 19,
    })

    local actionContainer = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(98, 30),
        BackgroundTransparency = 1,
        ZIndex = 24,
    })

    create("UIListLayout", {
        Parent = actionContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
    })

    local function actionButton(order)
        local button = create("TextButton", {
            Parent = actionContainer,
            Size = UDim2.fromOffset(28, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            TextTransparency = 1,
            AutoButtonColor = false,
            LayoutOrder = order,
            ZIndex = 25,
        })
        return button
    end

    local searchButton = actionButton(1)
    local searchIconHolder = create("Frame", {
        Parent = searchButton,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
    })
    builtinSearch(searchIconHolder, theme.Secondary, 16)

    local minimizeButton = actionButton(2)
    local minusHolder, minimizeLine = makeMinusIcon(minimizeButton, theme.Secondary)
    minusHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    minusHolder.Position = UDim2.fromScale(0.5, 0.5)

    local closeButton = actionButton(3)
    local closeHolder, closeA, closeB = makeCloseIcon(closeButton, theme.Secondary)
    closeHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    closeHolder.Position = UDim2.fromScale(0.5, 0.5)

    -- Gen2-style collapsed restore pill. The actual window morphs into this
    -- shape instead of disappearing, then expands back to its restore position.
    local collapsedFace = create("CanvasGroup", {
        -- Gen2 keeps the collapsed restore face directly on the window itself.
        -- Keeping it outside the clipping/content wrapper prevents it from being
        -- hidden when the normal topbar/body are faded and disabled.
        Parent = main,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 100,
    })

    local collapsedIconHolder = create("Frame", {
        Parent = collapsedFace,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        ZIndex = 101,
    })
    local collapsedIcon = makeIcon(collapsedIconHolder, icon, theme.Text, 24, name)
    collapsedIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    collapsedIcon.Position = UDim2.fromScale(0.5, 0.5)

    local collapsedText = create("Frame", {
        Parent = collapsedFace,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 50, 0.5, 0),
        Size = UDim2.new(1, -60, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 101,
    })

    create("UIListLayout", {
        Parent = collapsedText,
        Padding = UDim.new(0, 1),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local collapsedTitle = create("TextLabel", {
        Parent = collapsedText,
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.Text,
        TextSize = 16,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 1,
        ZIndex = 102,
    })

    local collapsedSubtitle = create("TextLabel", {
        Parent = collapsedText,
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = "Tap to show",
        TextColor3 = theme.Text,
        TextTransparency = 0.5,
        TextSize = 14,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 2,
        ZIndex = 102,
    })

    local collapsedInteract = create("TextButton", {
        Parent = collapsedFace,
        Name = "CollapsedInteract",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 110,
    })

    local body = create("CanvasGroup", {
        Parent = clip,
        Position = UDim2.fromOffset(0, LAYOUT.TopbarHeight),
        Size = UDim2.new(1, 0, 1, -LAYOUT.TopbarHeight),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        ZIndex = 3,
    })

    local sidebar = create("Frame", {
        Parent = body,
        Size = UDim2.new(0, LAYOUT.RailWidth, 1, 0),
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ZIndex = 3,
    })

    cornerMask(sidebar, 18, false, false, true, false)

    create("Frame", {
        Parent = body,
        Position = UDim2.fromOffset(LAYOUT.RailWidth - 1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = theme.StrokeSoft,
        BackgroundTransparency = 0.68,
        BorderSizePixel = 0,
        ZIndex = 4,
    })

    local tabList = create("ScrollingFrame", {
        Parent = sidebar,
        Active = true,
        Size = UDim2.new(1, 0, 1, -LAYOUT.FooterHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 5,
    })

    create("UIPadding", {
        Parent = tabList,
        PaddingTop = UDim.new(0, LAYOUT.RailPadding),
        PaddingBottom = UDim.new(0, LAYOUT.RailPadding),
    })

    create("UIListLayout", {
        Parent = tabList,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, LAYOUT.RowSpacing),
    })

    local profile = create("Frame", {
        Parent = sidebar,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.new(1, 0, 0, LAYOUT.FooterHeight),
        BackgroundTransparency = 1,
        ZIndex = 6,
    })

    local profileContainer = create("Frame", {
        Parent = profile,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, LAYOUT.RowInset, 0.5, 0),
        Size = UDim2.new(1, -LAYOUT.RowInset * 2, 0, LAYOUT.AvatarSize),
        BackgroundTransparency = 1,
        ZIndex = 7,
    })

    local avatar = create("ImageLabel", {
        Parent = profileContainer,
        Size = UDim2.fromOffset(LAYOUT.AvatarSize, LAYOUT.AvatarSize),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 8,
    })
    corner(avatar, 99)

    local profileName = create("TextLabel", {
        Parent = profileContainer,
        Position = UDim2.fromOffset(LAYOUT.AvatarSize + 10, 0),
        Size = UDim2.new(1, -(LAYOUT.AvatarSize + 10), 1, 0),
        BackgroundTransparency = 1,
        Text = LocalPlayer and LocalPlayer.DisplayName or "Player",
        TextColor3 = theme.Text,
        TextTransparency = 0.04,
        TextSize = 16,
        FontFace = FONT_MEDIUM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8,
    })

    local pageHost = create("Frame", {
        Parent = body,
        Position = UDim2.fromOffset(LAYOUT.RailWidth, 0),
        Size = UDim2.new(1, -LAYOUT.RailWidth, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    local searchPill = create("Frame", {
        Parent = topbar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -118, 0.5, 0),
        Size = UDim2.fromOffset(220, 32),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 30,
    })
    corner(searchPill, 12)
    local searchPillStroke = stroke(searchPill, Color3.fromRGB(255, 255, 255), 1, 1)
    local searchPillGlow = glow(searchPill, Color3.fromRGB(255, 255, 255), 20, 1)

    local searchBox = create("TextBox", {
        Parent = searchPill,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Search this page",
        TextColor3 = theme.Text,
        PlaceholderColor3 = theme.Secondary,
        TextTransparency = 1,
        TextSize = 15,
        FontFace = FONT_REGULAR,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 31,
    })

    local window = setmetatable({
        screen = screen,
        main = main,
        mainCorner = mainCorner,
        mainStroke = mainStroke,
        clipCorner = clipCorner,
        scale = scale,
        topbar = topbar,
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
        closeA = closeA,
        closeB = closeB,
        collapsedFace = collapsedFace,
        collapsedInteract = collapsedInteract,
        collapsedTitle = collapsedTitle,
        collapsedSubtitle = collapsedSubtitle,
        shadow = shadow,
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
        searchOpen = false,
        _connections = {},
    }, Window)

    local showProfile = pick(config, "showProfile", "ShowProfile")
    if showProfile == false then
        profile.Visible = false
        tabList.Size = UDim2.new(1, 0, 1, 0)
    end

    local function hoverAction(button, enter)
        -- Gen2 action buttons do not light up a card; only their icon/content brightens.
        button.BackgroundTransparency = 1
    end

    registerConnection(window, searchButton.MouseEnter:Connect(function() hoverAction(searchButton, true) end))
    registerConnection(window, searchButton.MouseLeave:Connect(function() hoverAction(searchButton, false) end))
    registerConnection(window, minimizeButton.MouseEnter:Connect(function() hoverAction(minimizeButton, true) end))
    registerConnection(window, minimizeButton.MouseLeave:Connect(function() hoverAction(minimizeButton, false) end))

    registerConnection(window, closeButton.MouseEnter:Connect(function()
        hoverAction(closeButton, true)
        tween(closeA, TWEEN.Hover, { BackgroundColor3 = theme.Danger })
        tween(closeB, TWEEN.Hover, { BackgroundColor3 = theme.Danger })
    end))
    registerConnection(window, closeButton.MouseLeave:Connect(function()
        hoverAction(closeButton, false)
        tween(closeA, TWEEN.Hover, { BackgroundColor3 = theme.Secondary })
        tween(closeB, TWEEN.Hover, { BackgroundColor3 = theme.Secondary })
    end))

    registerConnection(window, minimizeButton.MouseButton1Click:Connect(function()
        window:Minimize()
    end))

    registerConnection(window, closeButton.MouseButton1Click:Connect(function()
        window:Hide()
    end))

    registerConnection(window, searchButton.MouseButton1Click:Connect(function()
        window.searchOpen = not window.searchOpen
        if window.searchOpen then
            searchPill.Visible = true
            searchPill.BackgroundTransparency = 1
            searchPillStroke.Transparency = 1
            searchBox.TextTransparency = 1
            tween(searchPill, TWEEN.Hover, { BackgroundTransparency = 0.92 })
            tween(searchPillStroke, TWEEN.Hover, { Transparency = 0.86 })
            if searchPillGlow then tween(searchPillGlow, TWEEN.Hover, { Transparency = 0.92 }) end
            tween(searchBox, TWEEN.Hover, { TextTransparency = 0.3 })
            task.defer(function()
                if searchBox.Parent then searchBox:CaptureFocus() end
            end)
        else
            searchBox:ReleaseFocus()
            searchBox.Text = ""
            window:_applySearch("")
            tween(searchPill, TWEEN.Fast, { BackgroundTransparency = 1 })
            tween(searchPillStroke, TWEEN.Fast, { Transparency = 1 })
            if searchPillGlow then tween(searchPillGlow, TWEEN.Fast, { Transparency = 1 }) end
            tween(searchBox, TWEEN.Fast, { TextTransparency = 1 })
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

    local collapsedDragging = false
    local collapsedMoved = false
    local collapsedStart = Vector2.zero
    local collapsedOffset = Vector2.zero

    registerConnection(window, collapsedInteract.InputBegan:Connect(function(input, processed)
        if processed or window.animating or not window.hidden then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local point = Vector2.new(input.Position.X, input.Position.Y)
        local center = main.AbsolutePosition + main.AbsoluteSize * main.AnchorPoint
        collapsedStart = point
        collapsedOffset = center - point
        collapsedDragging = true
        collapsedMoved = false
    end))

    -- Fallback for a plain click/tap. The drag path below still wins when the
    -- pointer actually moves, but a normal press reliably restores the window.
    registerConnection(window, collapsedInteract.MouseButton1Click:Connect(function()
        if window.hidden and not window.animating and not collapsedMoved then
            window:Show()
        end
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if not collapsedDragging then return end

        collapsedDragging = false
        if collapsedMoved then
            window._collapsedPosition = main.Position
        elseif window.hidden and not window.animating then
            window:Show()
        end
    end))

    registerConnection(window, UserInputService.WindowFocusReleased:Connect(function()
        collapsedDragging = false
    end))

    registerConnection(window, RunService.RenderStepped:Connect(function()
        if not collapsedDragging or not window.hidden or window.animating or window.destroyed then return end

        local mouse = UserInputService:GetMouseLocation()
        if not collapsedMoved and (mouse - collapsedStart).Magnitude < 5 then
            return
        end

        collapsedMoved = true
        local target = mouse + collapsedOffset
        main.Position = UDim2.fromOffset(math.round(target.X), math.round(target.Y))
    end))

    local dragging = false
    local dragOffset = Vector2.zero

    registerConnection(window, topbar.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local p = input.Position
        local actionPos = actionContainer.AbsolutePosition
        local actionSize = actionContainer.AbsoluteSize
        if p.X >= actionPos.X and p.X <= actionPos.X + actionSize.X and p.Y >= actionPos.Y and p.Y <= actionPos.Y + actionSize.Y then
            return
        end

        local center = main.AbsolutePosition + main.AbsoluteSize * main.AnchorPoint
        dragOffset = center - Vector2.new(p.X, p.Y)
        dragging = true
    end))

    registerConnection(window, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    registerConnection(window, UserInputService.WindowFocusReleased:Connect(function()
        dragging = false
    end))

    registerConnection(window, RunService.RenderStepped:Connect(function()
        if not dragging or window.destroyed then return end
        local mouse = UserInputService:GetMouseLocation()
        local target = mouse + dragOffset
        main.Position = UDim2.fromOffset(math.round(target.X), math.round(target.Y))
    end))

    if LocalPlayer then
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and avatar.Parent then
                avatar.Image = image
            end
        end)
    end

    local keybind = pick(config, "toggleKeybind", "ToggleKeybind")
    if typeof(keybind) == "EnumItem" and keybind.EnumType == Enum.KeyCode then
        registerConnection(window, UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == keybind then
                window:Toggle()
            end
        end))
    end

    main.Position = UDim2.new(0.5, 0, 0.5, 10)

    tween(main, TWEEN.Reveal, {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    tween(scale, TWEEN.Reveal, { Scale = 1 })
    tween(shadow, TWEEN.Reveal, { Transparency = 0.6 })

    return window
end

return Aether
