local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Aether = {}
Aether.__index = Aether
Aether.Version = "0.2.0"

local DEFAULT = {
    Window = Color3.fromRGB(18, 18, 19),
    Window2 = Color3.fromRGB(22, 22, 23),
    Sidebar = Color3.fromRGB(17, 17, 18),
    Element = Color3.fromRGB(31, 31, 33),
    Element2 = Color3.fromRGB(27, 27, 29),
    ElementHover = Color3.fromRGB(255, 255, 255),
    Tab = Color3.fromRGB(37, 37, 39),
    Stroke = Color3.fromRGB(77, 77, 82),
    StrokeSoft = Color3.fromRGB(62, 62, 67),
    Text = Color3.fromRGB(242, 242, 244),
    Secondary = Color3.fromRGB(157, 157, 164),
    Muted = Color3.fromRGB(112, 112, 119),
    Field = Color3.fromRGB(42, 42, 45),
    FieldHover = Color3.fromRGB(49, 49, 52),
    ToggleOn = Color3.fromRGB(82, 82, 87),
    ToggleKnob = Color3.fromRGB(216, 216, 220),
    ToggleKnobOn = Color3.fromRGB(248, 248, 250),
    Danger = Color3.fromRGB(215, 115, 120),
    Shadow = Color3.fromRGB(20, 20, 20),
    Gloss = Color3.fromRGB(255, 255, 255),
    Glow = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(236, 238, 246),
    AccentStroke = Color3.fromRGB(255, 255, 255),
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

local function glow(parent, color, blurRadius, transparency)
    local ok, result = pcall(function()
        return create("UIShadow", {
            Parent = parent,
            Color = color,
            BlurRadius = UDim.new(0, blurRadius or 16),
            Transparency = transparency or 1,
            ZIndex = -1,
        })
    end)
    return ok and result or nil
end

local function gloss(parent, radius, zIndex, transparency)
    local sheen = create("Frame", {
        Parent = parent,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = transparency or 0.9,
        BorderSizePixel = 0,
        ZIndex = zIndex or 3,
    })
    corner(sheen, radius)
    create("UIGradient", {
        Parent = sheen,
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.34, 0.18),
            NumberSequenceKeypoint.new(0.58, 0.88),
            NumberSequenceKeypoint.new(0.72, 1),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })
    return sheen
end

local function strokeGradient(target, topColor, middleColor, bottomColor)
    return create("UIGradient", {
        Parent = target,
        Rotation = 55,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, topColor),
            ColorSequenceKeypoint.new(0.48, middleColor),
            ColorSequenceKeypoint.new(1, bottomColor),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.08),
            NumberSequenceKeypoint.new(0.45, 0.26),
            NumberSequenceKeypoint.new(1, 0.62),
        }),
    })
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
            if out[k] ~= nil and typeof(v) == "Color3" then
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
    local background
    local strokeTransparency
    local contentTransparency
    local glowTransparency

    if state == "selected" then
        background = 0.4
        strokeTransparency = 0.5
        contentTransparency = 0
        glowTransparency = 0.86
    elseif state == "hover" then
        background = 0.7
        strokeTransparency = 0.8
        contentTransparency = 0.3
        glowTransparency = 0.94
    else
        background = 1
        strokeTransparency = 1
        contentTransparency = 0.5
        glowTransparency = 1
    end

    local function apply(object, props)
        if instant then
            for k, v in pairs(props) do
                object[k] = v
            end
        else
            tween(object, TWEEN.Hover, props)
        end
    end

    apply(tab.selector, { BackgroundTransparency = background })
    apply(tab.selectorStroke, { Transparency = strokeTransparency })
    apply(tab.selectorTitle, { TextTransparency = contentTransparency })
    if tab.selectorGlow then
        apply(tab.selectorGlow, { Transparency = glowTransparency })
    end
    if tab.selectorIcon then
        if tab.selectorIcon:IsA("ImageLabel") then
            apply(tab.selectorIcon, { ImageTransparency = contentTransparency })
        else
            tab.selectorIcon.GroupTransparency = contentTransparency
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
        BackgroundColor3 = window.theme.Element,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    })
    corner(main, 12)

    create("UIGradient", {
        Parent = main,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, window.theme.Element:Lerp(window.theme.Gloss, 0.10)),
            ColorSequenceKeypoint.new(0.42, window.theme.Element),
            ColorSequenceKeypoint.new(1, window.theme.Element2),
        }),
    })

    local bodyStroke = stroke(main, window.theme.Stroke, 0.72, 1)
    strokeGradient(
        bodyStroke,
        window.theme.Stroke:Lerp(window.theme.Gloss, 0.35),
        window.theme.Stroke,
        window.theme.StrokeSoft
    )
    local elementGlow = glow(main, window.theme.Glow, 12, 0.965)
    local elementGloss = gloss(main, 12, 3, 0.91)

    local hover = create("Frame", {
        Parent = main,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = window.theme.ElementHover,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
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

    local list = create("UIListLayout", {
        Parent = content,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

    local iconObject
    if icon ~= nil and icon ~= 0 and icon ~= "" then
        iconObject = makeIcon(content, icon, window.theme.Text, 16, name)
        iconObject.LayoutOrder = 0
    end

    local title = create("TextLabel", {
        Parent = content,
        Size = UDim2.fromOffset(210, 18),
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
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 10,
    })

    registerConnection(window, main.MouseEnter:Connect(function()
        tween(hover, TWEEN.Hover, { BackgroundTransparency = 0.972 })
        tween(bodyStroke, TWEEN.Hover, { Transparency = 0.52 })
        tween(elementGloss, TWEEN.Hover, { BackgroundTransparency = 0.855 })
        if elementGlow then
            tween(elementGlow, TWEEN.Hover, { Transparency = 0.90 })
        end
    end))

    registerConnection(window, main.MouseLeave:Connect(function()
        tween(hover, TWEEN.Hover, { BackgroundTransparency = 1 })
        tween(bodyStroke, TWEEN.Hover, { Transparency = 0.72 })
        tween(elementGloss, TWEEN.Hover, { BackgroundTransparency = 0.91 })
        if elementGlow then
            tween(elementGlow, TWEEN.Hover, { Transparency = 0.965 })
        end
    end))

    return {
        main = main,
        stroke = bodyStroke,
        hover = hover,
        glow = elementGlow,
        gloss = elementGloss,
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

    local pill = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(40, 22),
        BackgroundColor3 = window.theme.Field,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    corner(pill, 99)
    local pillStroke = stroke(pill, window.theme.Stroke, 0.62, 1)
    strokeGradient(
        pillStroke,
        window.theme.Stroke:Lerp(window.theme.Gloss, 0.42),
        window.theme.Stroke,
        window.theme.StrokeSoft
    )
    local pillGlow = glow(pill, window.theme.Glow, 14, 0.985)
    local pillGloss = gloss(pill, 99, 6, 0.93)

    local knob = create("Frame", {
        Parent = pill,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = window.theme.ToggleKnob,
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    corner(knob, 99)
    local knobGlow = glow(knob, window.theme.Glow, 18, 0.98)
    local knobGloss = gloss(knob, 99, 9, 0.68)

    local handle = setmetatable({
        window = window,
        tab = self,
        main = base.main,
        title = base.title,
        interact = base.interact,
        pill = pill,
        pillStroke = pillStroke,
        pillGlow = pillGlow,
        pillGloss = pillGloss,
        knob = knob,
        knobGlow = knobGlow,
        knobGloss = knobGloss,
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
        tween(base.stroke, TWEEN.Fast, { Transparency = 1 })
        handle:Set(not handle.value)
        task.delay(0.11, function()
            if base.stroke and base.stroke.Parent then
                tween(base.stroke, TWEEN.Hover, { Transparency = 0.78 })
            end
        end)
    end))

    return self:_addElement(handle)
end

function Toggle:_render(instant)
    local on = self.value
    local pillColor = on and self.window.theme.ToggleOn or self.window.theme.Field
    local knobColor = on and self.window.theme.ToggleKnobOn or self.window.theme.ToggleKnob
    local knobPosition = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    local propsPill = { BackgroundColor3 = pillColor }
    local propsKnob = { Position = knobPosition, BackgroundColor3 = knobColor }
    local propsStroke = {
        Transparency = on and 0.34 or 0.62,
        Color = on and self.window.theme.AccentStroke or self.window.theme.Stroke,
    }
    local pillGlowTransparency = on and 0.91 or 0.985
    local knobGlowTransparency = on and 0.76 or 0.98
    local pillGlossTransparency = on and 0.875 or 0.93
    local knobGlossTransparency = on and 0.56 or 0.68

    if instant then
        for k, v in pairs(propsPill) do self.pill[k] = v end
        for k, v in pairs(propsKnob) do self.knob[k] = v end
        for k, v in pairs(propsStroke) do self.pillStroke[k] = v end
        if self.pillGlow then self.pillGlow.Transparency = pillGlowTransparency end
        if self.knobGlow then self.knobGlow.Transparency = knobGlowTransparency end
        if self.pillGloss then self.pillGloss.BackgroundTransparency = pillGlossTransparency end
        if self.knobGloss then self.knobGloss.BackgroundTransparency = knobGlossTransparency end
    else
        tween(self.pill, TWEEN.Hover, propsPill)
        tween(self.knob, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), propsKnob)
        tween(self.pillStroke, TWEEN.Hover, propsStroke)
        if self.pillGlow then tween(self.pillGlow, TWEEN.Hover, { Transparency = pillGlowTransparency }) end
        if self.knobGlow then tween(self.knobGlow, TWEEN.Hover, { Transparency = knobGlowTransparency }) end
        if self.pillGloss then tween(self.pillGloss, TWEEN.Hover, { BackgroundTransparency = pillGlossTransparency }) end
        if self.knobGloss then tween(self.knobGloss, TWEEN.Hover, { BackgroundTransparency = knobGlossTransparency }) end
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

    local arrowHolder = create("Frame", {
        Parent = base.main,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -17, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })

    local arrowA = create("Frame", {
        Parent = arrowHolder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -1, 0.5, -3),
        Size = UDim2.fromOffset(7, 1),
        Rotation = 45,
        BackgroundColor3 = self.window.theme.Secondary,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    })
    local arrowB = create("Frame", {
        Parent = arrowHolder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -1, 0.5, 3),
        Size = UDim2.fromOffset(7, 1),
        Rotation = -45,
        BackgroundColor3 = self.window.theme.Secondary,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    })

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
        tween(base.stroke, TWEEN.Fast, { Transparency = 1 })
        tween(arrowA, TWEEN.Fast, { BackgroundTransparency = 0 })
        tween(arrowB, TWEEN.Fast, { BackgroundTransparency = 0 })
        task.spawn(function()
            local ok, err = pcall(callback)
            if not ok then
                warn("Aether button callback error: " .. tostring(err))
            end
        end)
        task.delay(0.11, function()
            if base.stroke.Parent then
                tween(base.stroke, TWEEN.Hover, { Transparency = 0.78 })
                tween(arrowA, TWEEN.Hover, { BackgroundTransparency = 0.25 })
                tween(arrowB, TWEEN.Hover, { BackgroundTransparency = 0.25 })
            end
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
        BackgroundColor3 = self.theme.Tab,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    corner(selector, LAYOUT.RowCorner)
    create("UIGradient", {
        Parent = selector,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.theme.Tab:Lerp(self.theme.Gloss, 0.18)),
            ColorSequenceKeypoint.new(1, self.theme.Tab:Lerp(Color3.new(0, 0, 0), 0.08)),
        }),
    })
    local selectorStroke = stroke(selector, self.theme.StrokeSoft, 1, 1)
    strokeGradient(
        selectorStroke,
        self.theme.Stroke:Lerp(self.theme.Gloss, 0.45),
        self.theme.Stroke,
        self.theme.StrokeSoft
    )
    local selectorGlow = glow(selector, self.theme.Glow, 14, 1)

    local selectorContent = create("Frame", {
        Parent = selector,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, LAYOUT.RowPadding, 0.5, 0),
        Size = UDim2.new(1, -LAYOUT.RowPadding * 2, 0, LAYOUT.RowIconSize),
        BackgroundTransparency = 1,
    })

    local selectorLayout = create("UIListLayout", {
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
        Size = UDim2.fromOffset(120, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.theme.Text,
        TextTransparency = 0.5,
        TextSize = 15,
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
        selectorGlow = selectorGlow,
        selectorIcon = selectorIcon,
        selectorTitle = selectorTitle,
        page = page,
        elements = {},
    }, Tab)

    table.insert(self.tabs, tab)
    selector.LayoutOrder = #self.tabs * 10

    registerConnection(self, selector.MouseEnter:Connect(function()
        if self.selectedTab ~= tab then
            setTabVisual(tab, "hover", false)
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
    if self.minimized == state or self.animating then
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
    if self.destroyed then return end
    self.screen.Enabled = true
    self.main.Visible = true
    self.main.GroupTransparency = 1
    self.scale.Scale = 0.96
    tween(self.main, TWEEN.Reveal, { GroupTransparency = 0 })
    tween(self.scale, TWEEN.Reveal, { Scale = 1 })
end

function Window:Hide()
    if self.destroyed then return end
    tween(self.main, TWEEN.Fast, { GroupTransparency = 1 })
    tween(self.scale, TWEEN.Fast, { Scale = 0.97 })
    task.delay(0.16, function()
        if self.main.Parent and not self.destroyed then
            self.main.Visible = false
        end
    end)
end

function Window:Toggle()
    if self.main.Visible then
        self:Hide()
    else
        self:Show()
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
    corner(main, 18)
    stroke(main, theme.Stroke, 0.6, 1)

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
    corner(clip, 18)

    local scale = create("UIScale", {
        Parent = main,
        Scale = 0.94,
    })

    local topbar = create("Frame", {
        Parent = clip,
        Size = UDim2.new(1, 0, 0, LAYOUT.TopbarHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
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

    local actionGlows = {}

    local function actionButton(order)
        local button = create("TextButton", {
            Parent = actionContainer,
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = theme.Element,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            ZIndex = 25,
        })
        corner(button, 9)
        create("UIGradient", {
            Parent = button,
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Element:Lerp(theme.Gloss, 0.14)),
                ColorSequenceKeypoint.new(1, theme.Element2),
            }),
        })
        actionGlows[button] = glow(button, theme.Glow, 12, 1)
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
    local avatarGlow = glow(avatar, theme.Glow, 12, 0.94)
    local avatarGloss = gloss(avatar, 99, 9, 0.78)

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
    create("UIGradient", {
        Parent = searchPill,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Element:Lerp(theme.Gloss, 0.12)),
            ColorSequenceKeypoint.new(1, theme.Element2),
        }),
    })
    local searchPillStroke = stroke(searchPill, theme.StrokeSoft, 1, 1)
    strokeGradient(searchPillStroke, theme.Stroke, theme.StrokeSoft, theme.Element2)
    local searchPillGlow = glow(searchPill, theme.Glow, 16, 1)
    local searchPillGloss = gloss(searchPill, 12, 30, 0.90)

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
        scale = scale,
        topbar = topbar,
        body = body,
        sidebar = sidebar,
        tabList = tabList,
        pageHost = pageHost,
        profile = profile,
        avatar = avatar,
        avatarGlow = avatarGlow,
        avatarGloss = avatarGloss,
        title = title,
        subtitle = subtitleLabel,
        searchPill = searchPill,
        searchPillStroke = searchPillStroke,
        searchPillGlow = searchPillGlow,
        searchPillGloss = searchPillGloss,
        searchBox = searchBox,
        searchButton = searchButton,
        minimizeButton = minimizeButton,
        closeButton = closeButton,
        minimizeLine = minimizeLine,
        closeA = closeA,
        closeB = closeB,
        shadow = shadow,
        theme = theme,
        size = Vector2.new(width, height),
        tabs = {},
        controls = {},
        Flags = {},
        selectedTab = nil,
        minimized = false,
        animating = false,
        destroyed = false,
        searchOpen = false,
        _connections = {},
    }, Window)

    local showProfile = pick(config, "showProfile", "ShowProfile")
    if showProfile == false then
        profile.Visible = false
        tabList.Size = UDim2.new(1, 0, 1, 0)
    end

    local function hoverAction(button, enter)
        tween(button, TWEEN.Hover, { BackgroundTransparency = enter and 0.18 or 1 })
        local actionGlow = actionGlows[button]
        if actionGlow then
            tween(actionGlow, TWEEN.Hover, { Transparency = enter and 0.86 or 1 })
        end
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
        window:Destroy()
    end))

    registerConnection(window, searchButton.MouseButton1Click:Connect(function()
        window.searchOpen = not window.searchOpen
        if window.searchOpen then
            searchPill.Visible = true
            searchPill.BackgroundTransparency = 1
            searchPillStroke.Transparency = 1
            searchBox.TextTransparency = 1
            tween(searchPill, TWEEN.Hover, { BackgroundTransparency = 0.1 })
            tween(searchPillStroke, TWEEN.Hover, { Transparency = 0.48 })
            if searchPillGlow then tween(searchPillGlow, TWEEN.Hover, { Transparency = 0.84 }) end
            tween(searchPillGloss, TWEEN.Hover, { BackgroundTransparency = 0.84 })
            tween(searchBox, TWEEN.Hover, { TextTransparency = 0 })
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
            tween(searchPillGloss, TWEEN.Fast, { BackgroundTransparency = 1 })
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
