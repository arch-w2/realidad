-- ==========================================
-- MORGAN HUB | Key System (GUI bloqueante)
-- La GUI no se cierra hasta validar una key correcta.
-- La key se guarda en morgan_hub_key.txt para no reescribirla.
-- ==========================================
local KEY_URL = "https://keydash-robux-magic.lovable.app/api/public/validate-key"
local KEY_FILE = "morgan_hub_key.txt"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local HWID = "unknown"
pcall(function()
    HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end)

local function ValidateKey(key)
    if not key or key == "" then
        return false, "Escribe tu key"
    end
    local ok, response = pcall(function()
        return game:HttpGet(KEY_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(HWID))
    end)
    if not ok then
        return false, "Error de conexion. Intenta de nuevo."
    end
    local decoded
    ok, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not ok or type(decoded) ~= "table" then
        return false, "Respuesta invalida del servidor"
    end
    return decoded.success == true, decoded.message or ""
end

-- Auto-validar key guardada: si es valida, no se muestra la GUI
local savedKey = nil
pcall(function()
    if isfile and readfile and isfile(KEY_FILE) then
        savedKey = readfile(KEY_FILE)
    end
end)
if savedKey and savedKey ~= "" then
    savedKey = savedKey:gsub("%s+", "")
    local ok = ValidateKey(savedKey)
    if ok then
        -- Key guardada valida: saltar la GUI
        getgenv().MORGAN_HUB_KEY_VALIDATED = true
    end
end

if not getgenv().MORGAN_HUB_KEY_VALIDATED then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MorganHub_KeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    end)
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = CoreGui end)
    end
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(400, 238)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(48, 48, 54)
    Stroke.Thickness = 1.5

    local Header = Instance.new("Frame")
    Header.Name = "HeaderAccent"
    Header.Size = UDim2.new(1, -24, 0, 3)
    Header.Position = UDim2.new(0, 12, 0, 10)
    Header.BackgroundColor3 = Color3.fromRGB(235, 45, 55)
    Header.BorderSizePixel = 0
    Header.Parent = Frame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 2)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 42)
    Title.BackgroundTransparency = 1
    Title.Text = "MORGAN HUB  |  ACCESS"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Frame

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, -24, 0, 18)
    Sub.Position = UDim2.new(0, 12, 0, 38)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Access panel  •  Block Spin"
    Sub.TextColor3 = Color3.fromRGB(150, 150, 170)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 12
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 0, 34)
    Box.Position = UDim2.new(0, 12, 0, 64)
    Box.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    Box.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
    Box.Font = Enum.Font.Code
    Box.TextSize = 14
    Box.Text = savedKey or ""
    Box.ClearTextOnFocus = false
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Color3.fromRGB(60, 60, 80)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -24, 0, 18)
    Status.Position = UDim2.new(0, 12, 0, 106)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = Color3.fromRGB(175, 175, 185)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -24, 0, 36)
    Button.Position = UDim2.new(0, 12, 0, 132)
    Button.BackgroundColor3 = Color3.fromRGB(210, 35, 45)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = "UNLOCK HUB"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = Frame
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local busy = false
    Button.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        Button.Text = "CHECKING..."
        Status.Text = ""
        local key = Box.Text:gsub("%s+", "")
        task.spawn(function()
            local ok, msg = ValidateKey(key)
            busy = false
            Button.Text = "UNLOCK HUB"
            if ok then
                pcall(function()
                    if writefile then writefile(KEY_FILE, key) end
                end)
                Status.TextColor3 = Color3.fromRGB(90, 255, 140)
                Status.Text = "Key valida. Cargando MORGAN HUB..."
                task.wait(0.6)
                ScreenGui:Destroy()
                getgenv().MORGAN_HUB_KEY_VALIDATED = true
            else
                Status.TextColor3 = Color3.fromRGB(255, 90, 90)
                Status.Text = msg or "Key invalida"
            end
        end)
    end)

    -- Bloquear: el script principal no corre hasta validar
    repeat task.wait(0.2) until getgenv().MORGAN_HUB_KEY_VALIDATED == true
end

-- ==========================================
-- SCRIPT PRINCIPAL MORGAN HUB (solo corre con key valida)
-- ==========================================

-- ==========================================
-- MORGAN HUB | BLOCK SPIN
-- MORGAN HUB
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- ==========================================
-- DROP ITEM ESP
-- ==========================================
local DropESP_Drawings = {}

local function DropESPRarityColor(model)
    local colors = {
        common = Color3.fromRGB(180,180,180),
        comun = Color3.fromRGB(180,180,180),
        ["común"] = Color3.fromRGB(180,180,180),
        uncommon = Color3.fromRGB(99,255,52),
        ["poco comun"] = Color3.fromRGB(99,255,52),
        ["poco común"] = Color3.fromRGB(99,255,52),
        rare = Color3.fromRGB(51,170,255),
        raro = Color3.fromRGB(51,170,255),
        epic = Color3.fromRGB(237,44,255),
        epico = Color3.fromRGB(237,44,255),
        ["épico"] = Color3.fromRGB(237,44,255),
        legendary = Color3.fromRGB(255,150,0),
        legendario = Color3.fromRGB(255,150,0),
        omega = Color3.fromRGB(255,20,51)
    }

    if model.Name == "Money" then
        return Color3.fromRGB(0,255,0)
    end

    local rarity = model:GetAttribute("RarityName") or model:GetAttribute("Rarity")
    local rarityText = tostring(rarity or ""):lower():gsub("%s+", " ")
    rarityText = rarityText:gsub("^%s+", ""):gsub("%s+$", "")
    if colors[rarityText] then
        return colors[rarityText]
    end

    -- Resolve item rarity from game data when available.
    local items = ReplicatedStorage:FindFirstChild("Items")
    if items then
        for _, folder in ipairs(items:GetChildren()) do
            if folder:IsA("Folder") then
                local itemDef = folder:FindFirstChild(model.Name)
                if itemDef then
                    local r = itemDef:GetAttribute("RarityName")
                    if r and colors[tostring(r):lower()] then
                        return colors[tostring(r):lower()]
                    elseif r then
                        local key = tostring(r):lower():gsub("%s+", " ")
                        if colors[key] then return colors[key] end
                    end
                end
            end
        end
    end

    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local n = obj.Name:lower()
            if n == "rarity" or n == "rarityname" then
                local key = tostring(obj.Value):lower():gsub("%s+", " ")
                if colors[key] then return colors[key] end
            end
        end
    end

    local nameText = tostring(model:GetAttribute("DisplayName") or model.Name or ""):lower()
    if nameText:find("draco", 1, true) then
        return colors.epic
    end

    return Color3.fromRGB(255,255,255)
end

local function DropESPRemove(model)
    local drawings = DropESP_Drawings[model]
    if drawings then
        for _, drawing in pairs(drawings) do
            pcall(function() drawing:Remove() end)
        end
        if drawings.highlight then
            pcall(function() drawings.highlight:Destroy() end)
        end
        DropESP_Drawings[model] = nil
    end
end

local function DropESPUpdate()
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then return end

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for model, drawings in pairs(DropESP_Drawings) do
        if not model or not model.Parent then
            DropESPRemove(model)
        else
            drawings.circle.Visible = false
            drawings.inner.Visible = false
            drawings.name.Visible = false
            drawings.amount.Visible = false
            if drawings.highlight then drawings.highlight.Enabled = false end
        end
    end

    local nearby = {}
    for _, model in ipairs(droppedItems:GetChildren()) do
        local zone = model:IsA("Model") and model:FindFirstChild("PickUpZone")
        if model:IsA("Model") and zone and not model:GetAttribute("Locked") then
            local ok, pos = pcall(function() return zone.Position end)
            if ok and pos then
                table.insert(nearby, { item = model, dist = (pos - root.Position).Magnitude })
            end
        end
    end

    table.sort(nearby, function(a, b) return a.dist < b.dist end)

    for index = 1, math.min(20, #nearby) do
        local model = nearby[index].item
        local zone = model:FindFirstChild("PickUpZone")
        local pos, visible = Camera:WorldToViewportPoint(zone.Position)
        if visible and pos.Z > 0 then
            local color = DropESPRarityColor(model)
            local radius = math.clamp(100 / math.max(pos.Z, 0.1), 3, 6)
            local d = DropESP_Drawings[model]

            if not d then
                d = {
                    circle = Drawing.new("Circle"),
                    inner = Drawing.new("Circle"),
                    name = Drawing.new("Text"),
                    amount = Drawing.new("Text"),
                    highlight = nil
                }
                d.circle.Thickness = 2
                d.circle.Transparency = 0.7
                d.circle.Filled = false
                d.inner.Thickness = 2
                d.inner.Transparency = 1
                d.inner.Filled = true
                d.name.Outline = true
                d.name.OutlineColor = Color3.new(0,0,0)
                d.name.Center = true
                d.name.Size = 16
                d.name.Font = 4
                d.amount.Outline = true
                d.amount.OutlineColor = Color3.new(0,0,0)
                d.amount.Center = true
                d.amount.Size = 13
                DropESP_Drawings[model] = d
            end

            if not d.highlight or not d.highlight.Parent then
                local h = Instance.new("Highlight")
                h.Name = "MorganHub_DropESP_Highlight"
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0.1
                h.Adornee = model
                h.Parent = model
                d.highlight = h
            end

            d.highlight.FillColor = color
            d.highlight.OutlineColor = color
            d.highlight.Enabled = true

            d.circle.Position = Vector2.new(pos.X, pos.Y)
            d.circle.Radius = radius + 5
            d.circle.Color = color
            d.circle.Visible = true

            d.inner.Position = Vector2.new(pos.X, pos.Y)
            d.inner.Radius = radius
            d.inner.Color = color
            d.inner.Visible = true

            d.name.Position = Vector2.new(pos.X, pos.Y - radius - 20)
            d.name.Text = model:GetAttribute("DisplayName") or model.Name
            d.name.Color = color
            d.name.Visible = true

            local amount = model:GetAttribute("Amount") or 1
            d.amount.Position = Vector2.new(pos.X, pos.Y + radius + 15)
            d.amount.Text = amount > 1 and "[" .. tostring(amount) .. "]" or ""
            d.amount.Color = Color3.fromRGB(200,200,200)
            d.amount.Visible = amount > 1
        end
    end
end

RunService.RenderStepped:Connect(DropESPUpdate)

local THIN_FONT = Enum.Font.SourceSansLight
local BOLD_FONT = Enum.Font.SourceSansBold

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "MORGAN HUB | Block Spin",
    Icon = "rbxassetid://72957354226500",
    Size = UDim2.fromOffset(900, 600),
    Theme = "Dark",
    Acrylic = false,
    Transparent = false,
    Resizable = true,
    SideBarWidth = 205,
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
    HideSearchBar = false,
    -- WindUI default OpenButton disabled: Morgan Hub uses its own + / − button.
    OpenButton = {
        Enabled = false,
    },
})

-- ==========================================
-- MORGAN HUB | CUSTOM OPEN / CLOSE BUTTON
-- No se usa el boton OpenButton predeterminado de WindUI.
-- ==========================================
local MorganToggleGui = Instance.new("ScreenGui")
MorganToggleGui.Name = "MorganHub_Toggle"
MorganToggleGui.ResetOnSpawn = false
MorganToggleGui.IgnoreGuiInset = true
MorganToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MorganToggleGui.Parent = CoreGui

local MorganToggle = Instance.new("TextButton")
MorganToggle.Name = "OpenClose"
MorganToggle.Size = UDim2.fromOffset(42, 42)
MorganToggle.Position = UDim2.new(0, 14, 0.5, -21)
MorganToggle.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MorganToggle.TextColor3 = Color3.fromRGB(255, 65, 70)
MorganToggle.Text = "−"
MorganToggle.Font = Enum.Font.GothamBold
MorganToggle.TextSize = 25
MorganToggle.AutoButtonColor = true
MorganToggle.BorderSizePixel = 0
MorganToggle.ZIndex = 100
MorganToggle.Parent = MorganToggleGui

local MorganToggleCorner = Instance.new("UICorner")
MorganToggleCorner.CornerRadius = UDim.new(0, 5)
MorganToggleCorner.Parent = MorganToggle

local MorganToggleStroke = Instance.new("UIStroke")
MorganToggleStroke.Thickness = 1.2
MorganToggleStroke.Color = Color3.fromRGB(220, 40, 48)
MorganToggleStroke.Transparency = 0.1
MorganToggleStroke.Parent = MorganToggle

local morganOpen = true
local function SetMorganWindow(open)
    morganOpen = open
    if open then
        pcall(function() Window:Open() end)
        MorganToggle.Text = "−"
        MorganToggle.TextColor3 = Color3.fromRGB(255, 65, 70)
    else
        pcall(function() Window:Close() end)
        MorganToggle.Text = "+"
        MorganToggle.TextColor3 = Color3.fromRGB(255, 65, 70)
    end
end

MorganToggle.MouseButton1Click:Connect(function()
    SetMorganWindow(not morganOpen)
end)

-- Red game badge + hub badge
pcall(function()
    Window:Tag({
        Title = "BLOCK SPIN",
        Icon = "gamepad-2",
        Color = Color3.fromHex("#e52b36"),
        Border = true,
    })
    Window:Tag({
        Title = "NO SOMOS RATAS",
        Icon = "shield-check",
        Color = Color3.fromHex("#d72638"),
        Border = true,
    })
end)

local TabMain = Window:Tab({ Title = "ACCESSIBILITY", Icon = "accessibility", IconColor = Color3.fromHex("#e5e5ea") })
local TabCombat = Window:Tab({ Title = "COMBAT", Icon = "crosshair", IconColor = Color3.fromHex("#ff5c67") })
local TabMovement = Window:Tab({ Title = "MOVEMENT", Icon = "footprints", IconColor = Color3.fromHex("#68d391") })
local TabPlayer = Window:Tab({ Title = "PLAYER", Icon = "user-round", IconColor = Color3.fromHex("#8ab4ff") })
local TabVisual = Window:Tab({ Title = "VISUALS", Icon = "scan-eye", IconColor = Color3.fromHex("#c084fc") })
local TabUtility = Window:Tab({ Title = "UTILITY", Icon = "sliders-horizontal", IconColor = Color3.fromHex("#9ca3af") })

-- ==========================================
-- MAIN HEADER
-- ==========================================
TabMain:Section({ Title = "MORGAN HUB" })
TabMain:Paragraph({
    Title = "BLOCK SPIN",
    Desc = "Clean control center",
})

TabMain:Section({ Title = "INTERFACE" })
TabMain:Slider({
    Title = "Window Width",
    Step = 10,
    Value = { Min = 680, Max = 1100, Default = 900 },
    Callback = function(value)
        pcall(function() Window:SetSize(UDim2.fromOffset(tonumber(value) or 900, 600)) end)
    end
})
TabMain:Keybind({
    Title = "Open / Close",
    Desc = "Toggle Morgan Hub",
    Value = "RightShift",
    Callback = function(value)
        pcall(function() Window:SetToggleKey(Enum.KeyCode[value]) end)
    end
})

-- ==========================================
-- REMOTE ENGINE HELPER
-- ==========================================
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SendRemote = RemotesFolder and RemotesFolder:FindFirstChild("Send")

local RemoteCounter
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            RemoteCounter = obj
            break
        end
    end
end)

local RawCallCount = 0
local function FireServerHook(...)
    if not SendRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.event) == "number" then
        RemoteCounter.event = RemoteCounter.event + 1
        pcall(function() SendRemote:FireServer(RemoteCounter.event, unpack(args)) end)
    else
        RawCallCount = RawCallCount + 1
        pcall(function() SendRemote:FireServer(RawCallCount, unpack(args)) end)
    end
end

-- ==========================================
-- VISUALS & TARGET LINE SETUP
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MorganHub_Visuals"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = gethui and gethui() or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local TargetLine = Instance.new("Frame")
TargetLine.Name = "TargetLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
TargetLine.BackgroundTransparency = 0.05
TargetLine.BorderSizePixel = 0
TargetLine.Size = UDim2.fromOffset(0, 1.5)
TargetLine.Visible = false
TargetLine.ZIndex = 20
TargetLine.Parent = ScreenGui

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.Size = UDim2.fromOffset(5, 5)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.BackgroundTransparency = 0.18
TargetMarker.BackgroundColor3 = Color3.fromRGB(185, 185, 190)
TargetMarker.BorderSizePixel = 0
TargetMarker.Visible = false
TargetMarker.ZIndex = 30
TargetMarker.Parent = ScreenGui

-- Marcador hueco en forma de diamante: ◇
local DiamondStroke = Instance.new("UIStroke")
DiamondStroke.Thickness = 0.75
DiamondStroke.Color = Color3.fromRGB(125, 125, 130)
DiamondStroke.Transparency = 0.15
DiamondStroke.Parent = TargetMarker
TargetMarker.Rotation = 45

local FOVCircleGui = Instance.new("Frame")
FOVCircleGui.Name = "StaticFOVCircle"
FOVCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleGui.Position = UDim2.fromScale(0.5, 0.5)
FOVCircleGui.BackgroundTransparency = 1
FOVCircleGui.Visible = false
FOVCircleGui.ZIndex = 50
FOVCircleGui.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircleGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 0.8
FOVStroke.Transparency = 0.05
FOVStroke.Color = Color3.fromRGB(255, 35, 45)
FOVStroke.Parent = FOVCircleGui

-- ==========================================
-- 16-LINE RAINBOW FOV CIRCLE & SILENT AIM UTILS
-- ==========================================
local fovLines = {}
local rainbowFovEnabled = false
local staticFovEnabled = false
local fovRadius = 120
local numLines = 16

local SilentAimEnabled = false
local TargetHitPart = "Head" -- First shot per locked target: Chest; following shots: Head
local CurrentLockedTarget = nil
local targetLineEnabled = false
local LastShotTarget = nil
local crosshairGui
local showShotTracer
local showShotEffect
local ShotCountForTarget = 0
local AutoAttackEnabled = false
local AutoAttackKnifeEnabled = false
local AutoAttackTargetPart = "Head"
local AutoAttackDelay = 0.10
local AutoAttackBusy = false

-- ==========================================
-- VISUALES DE DISPARO
-- Tracers rojo/azul eliminados a petición.
-- ==========================================

pcall(function()
    if Drawing and Drawing.new then
        for i = 1, numLines do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 2
            table.insert(fovLines, line)
        end
    end
end)

local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function isInCarOrVehicle(char, targetPart)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return true end
    local parent = char.Parent
    while parent and parent ~= workspace do
        local pName = parent.Name:lower()
        if pName:find("vehicle") or pName:find("car") or pName:find("auto") or pName:find("moto") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

local function isTargetVisibleOrInCar(targetPart)
    local char = LocalPlayer.Character
    local targetChar = targetPart and targetPart.Parent
    local head = char and char:FindFirstChild("Head")
    if not head or not targetPart or not targetChar then return false end

    if isInCarOrVehicle(targetChar, targetPart) then
        return true
    end

    local origin = head.Position
    local targetPos = targetPart.Position
    local direction = targetPos - origin

    RaycastParamsCache.FilterDescendantsInstances = {char, targetChar}
    local result = workspace:Raycast(origin, direction, RaycastParamsCache)

    if not result then
        return true
    else
        local hitPart = result.Instance
        if hitPart then
            local mat = hitPart.Material
            local name = hitPart.Name:lower()
            if mat == Enum.Material.Glass or name:find("glass") or name:find("window") or name:find("cristal") or name:find("vidrio") then
                RaycastParamsCache.FilterDescendantsInstances = {char, targetChar, hitPart}
                local secondResult = workspace:Raycast(result.Position + (direction.Unit * 0.5), targetPos - (result.Position + (direction.Unit * 0.5)), RaycastParamsCache)
                if not secondResult then return true end
            end
        end
        return false
    end
end

local VelocityCache = {}
RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            local hum = pl.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                VelocityCache[pl] = VelocityCache[pl] or {}
                table.insert(VelocityCache[pl], {time = os.clock(), pos = root.Position})
                if #VelocityCache[pl] > 8 then table.remove(VelocityCache[pl], 1) end
            else
                VelocityCache[pl] = nil
            end
        end
    end
end)

local function getCalculatedVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end
    local data = VelocityCache[pl]
    if not data or #data < 2 then return Vector3.zero end
    local vel = Vector3.zero
    local count = 0
    for i = 2, #data do
        local dt = data[i].time - data[i - 1].time
        if dt > 0 then
            vel = vel + (data[i].pos - data[i - 1].pos) / dt
            count = count + 1
        end
    end
    return count > 0 and (vel / count) or Vector3.zero
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("NetworkStats") and pGui.NetworkStats:FindFirstChild("PingLabel") then
        local ms = tonumber(pGui.NetworkStats.PingLabel.Text:match("%d+"))
        if ms then return math.clamp(ms / 1000, 0.04, 1.2) end
    end
    return 0.08
end

local function getSilentAimTargetPart(character)
    if not character then return nil end

    if TargetHitPart == "Head" then
        return character:FindFirstChild("Head")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    end

    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Head")
end

local function predictTargetPos(targetPart)
    if not targetPart then return Vector3.zero end
    local char = targetPart.Parent
    local pl = char and Players:GetPlayerFromCharacter(char)
    if not pl then return targetPart.Position end
    local vel = getCalculatedVelocity(pl, char:FindFirstChild("HumanoidRootPart"))
    local ping = getPing()
    return targetPart.Position + (vel * (ping + 0.15) * 1.5)
end

local function getClosestPlayerInFOV()
    local bestTarget = nil
    local shortestDist = 999999
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local char = pl.Character
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                if isTargetVisibleOrInCar(head) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius and screenDist < shortestDist then
                            shortestDist = screenDist
                            bestTarget = pl
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function updateTargetLineVisual()
    if not targetLineEnabled or not CurrentLockedTarget then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local targetChar = CurrentLockedTarget.Character
    local targetPart = targetChar and getSilentAimTargetPart(targetChar)

    if not targetPart then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local targetPos, targetVisible = Camera:WorldToViewportPoint(targetPart.Position)

    if not targetVisible or targetPos.Z <= 0 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    -- Zen-style visual: line starts exactly at the FOV/crosshair center.
    local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local to = Vector2.new(targetPos.X, targetPos.Y)
    local diff = to - from
    local length = diff.Magnitude

    if length < 2 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    TargetLine.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
    TargetLine.Size = UDim2.fromOffset(length, 2)
    TargetLine.Rotation = math.deg(math.atan2(diff.Y, diff.X))
    TargetLine.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
    TargetLine.Visible = true

    TargetMarker.Position = UDim2.fromOffset(to.X, to.Y)
    TargetMarker.Visible = true
end

-- Hook para Silent Aim con wallbang inteligente y alcance lejano
if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        
        if args[2] == "shoot_gun" then
            if showShotTracer then task.spawn(showShotTracer) end
            if showShotEffect then task.spawn(showShotEffect) end
            local autoPart = getgenv().AstraTargetPart
            local hitPart = nil
            local activeTarget = nil

            if AutoAttackEnabled and autoPart and autoPart.Parent then
                hitPart = autoPart
                activeTarget = Players:GetPlayerFromCharacter(autoPart.Parent)
            elseif SilentAimEnabled and CurrentLockedTarget then
                activeTarget = CurrentLockedTarget
                local targetChar = activeTarget.Character
                if activeTarget ~= LastShotTarget then
                    LastShotTarget = activeTarget
                    ShotCountForTarget = 0
                end
                ShotCountForTarget += 1
                local aimPart = TargetHitPart
                hitPart = targetChar and (aimPart == "Head" and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart")) or (targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")))
            end

            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if hitPart and activeTarget and myHead and isTargetVisibleOrInCar(hitPart) then
                local predPos = predictTargetPos(hitPart)
                local startOrigin = myHead.Position
                args[4] = CFrame.new(startOrigin, predPos)
                args[5] = {
                    [1] = {
                        [1] = {
                            Instance = hitPart,
                            Normal = Vector3.new(0, 1, 0),
                            Position = predPos
                        }
                    }
                }
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Rainbow FOV
    if rainbowFovEnabled and #fovLines > 0 then
        pcall(function()
            local timeVal = tick() * 0.6
            for i, line in ipairs(fovLines) do
                local angle1 = math.rad((i - 1) * (360 / numLines))
                local angle2 = math.rad(i * (360 / numLines))
                
                local p1 = center + Vector2.new(math.cos(angle1), math.sin(angle1)) * fovRadius
                local p2 = center + Vector2.new(math.cos(angle2), math.sin(angle2)) * fovRadius
                
                line.From = p1
                line.To = p2
                
                local hue = (timeVal + (i / numLines)) % 1
                line.Color = Color3.fromHSV(hue, 1, 1)
                line.Visible = true
            end
        end)
    else
        for _, line in ipairs(fovLines) do
            line.Visible = false
        end
    end

    -- Static FOV Circle
    if staticFovEnabled then
        FOVCircleGui.Visible = true
        FOVCircleGui.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
    else
        FOVCircleGui.Visible = false
    end

    CurrentLockedTarget = (SilentAimEnabled or targetLineEnabled) and getClosestPlayerInFOV() or nil
    updateTargetLineVisual()
end)

TabCombat:Section({ Title = "TARGETING" })
TabCombat:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(state)
        SilentAimEnabled = state
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Silent Aim ENABLED" or "Silent Aim DISABLED", Duration = 1.5 })
    end
})
TabCombat:Dropdown({
    Title = "Silent Aim Target (default Head)",
    Values = {"Chest", "Head"},
    Value = "Head",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then
            value = value[1]
        end
        if value == "Head" or value == "Chest" then
            TargetHitPart = value
            WindUI:Notify({
                Title = "MORGAN HUB",
                Content = "Objetivo: " .. TargetHitPart,
                Duration = 1.2
            })
        end
    end
})

-- FOV controls grouped under VISUALS.
TabVisual:Section({ Title = "FOV" })
TabVisual:Toggle({
    Title = "FOV Básico",
    Default = false,
    Callback = function(state)
        staticFovEnabled = state
    end
})
TabVisual:Toggle({
    Title = "FOV iOS",
    Default = false,
    Callback = function(state)
        staticFovEnabled = state
    end
})
TabVisual:Toggle({
    Title = "Rainbow FOV",
    Default = false,
    Callback = function(state)
        rainbowFovEnabled = state
    end
})
TabVisual:Slider({
    Title = "FOV Size",
    Step = 5,
    Value = { Min = 30, Max = 400, Default = 120 },
    Callback = function(value)
        fovRadius = tonumber(value) or 120
    end
})

-- ==========================================
-- AUTO ATTACK | integrado desde el script de referencia
-- ==========================================
local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Throw", true) or tool:FindFirstChild("KnifeClient", true) or tool:FindFirstChild("KnifeServer", true) then
        return false
    end
    local name = string.lower(tool.Name)
    local ignored = {"combat", "fist", "wallet", "phone", "punch", "boombox", "radio", "knife", "blade", "cuchillo", "dagger", "kunai", "sword", "toy", "juguete", "pizza", "burger", "teddy", "balloon", "drink", "food"}
    for _, word in ipairs(ignored) do
        if string.find(name, word, 1, true) then return false end
    end
    return true
end

local function getAutoAttackPart(character)
    if not character then return nil end
    if AutoAttackTargetPart == "Head" then
        return character:FindFirstChild("Head")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Head")
end

local function findAutoAttackTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myRoot then return nil end

    local origin = myHead and myHead.Position or myRoot.Position
    local bestPart, bestDist, bestChar = nil, math.huge, nil
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = getAutoAttackPart(plr.Character)
            if hum and hum.Health > 0 and part then
                params.FilterDescendantsInstances = {myChar, plr.Character}
                local direction = part.Position - origin
                local visible = not workspace:Raycast(origin, direction, params)
                if visible then
                    local dist = direction.Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = part
                        bestChar = plr.Character
                    end
                end
            end
        end
    end
    return bestPart, bestChar
end

TabCombat:Section({ Title = "Auto Attack" })
TabCombat:Toggle({
    Title = "Auto Attack",
    Default = false,
    Callback = function(state)
        AutoAttackEnabled = state
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = state and "Auto Attack ENABLED" or "Auto Attack DISABLED",
            Duration = 1.5
        })
    end
})

TabCombat:Toggle({
    Title = "Auto Attack Knife",
    Default = false,
    Callback = function(state)
        AutoAttackKnifeEnabled = state
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = state and "Auto Attack Knife ENABLED" or "Auto Attack Knife DISABLED",
            Duration = 1.5
        })
    end
})

TabCombat:Dropdown({
    Title = "Auto Attack Target",
    Values = {"Head", "Chest"},
    Value = "Head",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then value = value[1] end
        if value == "Head" or value == "Chest" then
            AutoAttackTargetPart = value
        end
    end
})

TabCombat:Slider({
    Title = "Auto Attack Delay",
    Step = 0.01,
    Value = { Min = 0.03, Max = 0.50, Default = 0.10 },
    Callback = function(value)
        AutoAttackDelay = tonumber(value) or 0.10
    end
})

task.spawn(function()
    while task.wait(0.03) do
        if (AutoAttackEnabled or AutoAttackKnifeEnabled) and not AutoAttackBusy then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local tool = char and char:FindFirstChildOfClass("Tool")
            if hum and hum.Health > 0 and tool and tool:FindFirstChild("Handle") then
                local gun = isGunTool(tool)
                local allowed = (gun and AutoAttackEnabled) or ((not gun) and AutoAttackKnifeEnabled)
                if allowed then
                    local targetPart = findAutoAttackTarget()
                    if targetPart then
                        AutoAttackBusy = true
                        getgenv().AstraTargetPart = targetPart
                        pcall(function()
                            tool:Activate()
                            task.delay(0.02, function()
                                if tool and tool.Parent == char then
                                    pcall(function() tool:Deactivate() end)
                                end
                            end)
                        end)
                        task.delay(AutoAttackDelay, function()
                            AutoAttackBusy = false
                        end)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- WEAPON TUNING
-- ==========================================
-- Local tuning controls.

local GunFireRate = 1000
local GunAccuracy = 1
local GunRecoil = 0

TabCombat:Section({ Title = "WEAPON TUNING" })

TabCombat:Slider({
    Title = "Fire Rate",
    Step = 1,
    Value = { Min = 100, Max = 3000, Default = 1000 },
    Callback = function(value)
        GunFireRate = tonumber(value) or 1000
    end
})

TabCombat:Slider({
    Title = "Accuracy",
    Step = 0.01,
    Value = { Min = 0, Max = 1, Default = 1 },
    Callback = function(value)
        GunAccuracy = tonumber(value) or 1
    end
})

TabCombat:Slider({
    Title = "Recoil",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 0 },
    Callback = function(value)
        GunRecoil = tonumber(value) or 0
    end
})

-- ==========================================
-- MAIN SECTION: OPTIMIZATION & CRATE SKIP
-- ==========================================
TabUtility:Section({ Title = "Performance & Crates" })

TabUtility:Toggle({
    Title = "Auto Player Optimization",
    Default = false,
    Callback = function(state)
        pcall(function()
            local lighting = game:GetService("Lighting")
            if state then
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    end
                end
            else
                lighting.GlobalShadows = true
            end
        end)
    end
})

local enabledSkip = false
TabUtility:Toggle({
    Title = "Crate Skip",
    Default = false,
    Callback = function(state)
        enabledSkip = state
    end
})

task.spawn(function()
    while true do
        if enabledSkip then
            pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                local crateMod = modules and modules:FindFirstChild("Game") and modules.Game:FindFirstChild("CrateSystem") and modules.Game.CrateSystem:FindFirstChild("Crate")
                if crateMod then
                    local CrateController = require(crateMod)
                    if CrateController and CrateController.class and CrateController.class.objects then
                        for _, crate in pairs(CrateController.class.objects) do
                            if crate.states and crate.states.open then crate.states.open.set(true) end
                            if CrateController.skipping and CrateController.skipping.set then CrateController.skipping.set(true) end
                        end
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- ==========================================
-- BUTTON ZNAP | UNDER-GROUND MOVEMENT (V3)
-- Mantiene el comportamiento del Znap anterior, corrigiendo:
--  * restauración incorrecta de CanCollide
--  * referencias a un personaje viejo después de respawn
--  * activaciones dobles muy rápidas
--  * estados incompletos si PivotTo falla
-- No añade ninguna lógica de evasión de anti-cheat.

local SnapEnabled = false
local SnapDown = false
local SnapDepth = 0
local ButtonZnapEnabled = false

local SnapSavedPivot = nil
local SnapSavedCharacter = nil
local SnapOriginalCollision = {}
local SnapBusy = false

local ZnapButton = Instance.new("TextButton")
ZnapButton.Name = "ZnapButton"
ZnapButton.Size = UDim2.new(0, 90, 0, 32)
ZnapButton.Position = UDim2.new(0, 12, 0, 12)
ZnapButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ZnapButton.BorderSizePixel = 0
ZnapButton.TextColor3 = Color3.fromRGB(235, 235, 240)
ZnapButton.TextSize = 14
ZnapButton.Font = Enum.Font.GothamBold
ZnapButton.Text = "Znap"
ZnapButton.Visible = false
ZnapButton.Active = true
ZnapButton.Draggable = true
ZnapButton.Parent = ScreenGui

local ZnapCorner = Instance.new("UICorner")
ZnapCorner.CornerRadius = UDim.new(0, 8)
ZnapCorner.Parent = ZnapButton

local function getCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then
        return nil
    end

    return char, humanoid, root
end

local function clearCollisionCache()
    SnapOriginalCollision = {}
end

local function setCharacterCollision(enabled)
    local char = LocalPlayer.Character
    if not char then
        clearCollisionCache()
        return
    end

    if not enabled then
        clearCollisionCache()

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                SnapOriginalCollision[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    else
        for part, oldValue in pairs(SnapOriginalCollision) do
            if part and part.Parent then
                pcall(function()
                    part.CanCollide = oldValue
                end)
            end
        end

        clearCollisionCache()
    end
end

local function resetZnapButton()
    if not ZnapButton then return end

    ZnapButton.Text = "Znap"
    ZnapButton.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
end

local function restoreSnap()
    if SnapBusy then return end
    SnapBusy = true

    local char, humanoid, root = getCharacter()

    -- Solo devolvemos la posición si seguimos usando el mismo personaje
    -- con el que se activó el Znap.
    if char and SnapSavedCharacter == char and SnapSavedPivot then
        pcall(function()
            char:PivotTo(SnapSavedPivot)
        end)
    end

    if humanoid and root and SnapSavedCharacter == char then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
        end)
    end

    if SnapSavedCharacter == char then
        setCharacterCollision(true)
    else
        clearCollisionCache()
    end

    SnapSavedPivot = nil
    SnapSavedCharacter = nil
    SnapDown = false
    resetZnapButton()

    SnapBusy = false
end

local function activateSnap()
    if SnapBusy then return end

    if SnapDepth <= 0 then
        WindUI:Notify({
            Title = "Znap",
            Content = "Configura una profundidad mayor que 0.",
            Duration = 2
        })
        return
    end

    if not SnapEnabled then
        WindUI:Notify({
            Title = "Znap",
            Content = "Activa el toggle Znap primero.",
            Duration = 2
        })
        return
    end

    local char, humanoid, root = getCharacter()
    if not char then
        return
    end

    if SnapDown then
        restoreSnap()
        return
    end

    SnapBusy = true

    local savedPivot = char:GetPivot()
    local undergroundPivot = savedPivot * CFrame.new(0, -SnapDepth, 0)

    local ok = pcall(function()
        char:PivotTo(undergroundPivot)
    end)

    if not ok then
        SnapBusy = false
        WindUI:Notify({
            Title = "Znap",
            Content = "No se pudo mover el personaje.",
            Duration = 2
        })
        return
    end

    SnapSavedPivot = savedPivot
    SnapSavedCharacter = char
    SnapDown = true

    setCharacterCollision(false)

    ZnapButton.Text = "Znap • DOWN"
    ZnapButton.BackgroundColor3 = Color3.fromRGB(55, 70, 92)

    SnapBusy = false
end

ZnapButton.MouseButton1Click:Connect(function()
    if not ButtonZnapEnabled then return end
    activateSnap()
end)

TabMovement:Toggle({
    Title = "Button Znap",
    Default = false,
    Callback = function(state)
        ButtonZnapEnabled = state
        ZnapButton.Visible = state

        if not state and SnapDown then
            restoreSnap()
        elseif state then
            resetZnapButton()
        end
    end
})

TabMovement:Toggle({
    Title = "Znap",
    Default = false,
    Callback = function(state)
        SnapEnabled = state

        if not state and SnapDown then
            restoreSnap()
        end
    end
})

TabMovement:Slider({
    Title = "Znap Depth (Studs)",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 10 },
    Callback = function(value)
        SnapDepth = math.max(0, tonumber(value) or 0)
    end
})

LocalPlayer.CharacterRemoving:Connect(function(char)
    if SnapSavedCharacter == char then
        SnapSavedPivot = nil
        SnapSavedCharacter = nil
        SnapDown = false
        clearCollisionCache()
        resetZnapButton()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    SnapSavedPivot = nil
    SnapSavedCharacter = nil
    SnapDown = false
    clearCollisionCache()
    resetZnapButton()
end)

-- PLAYER SECTION (AUTO PICK, STAMINA, SPEED, ANTI KILL, JUMP, HIDE NAME)
-- ==========================================
TabPlayer:Section({ Title = "PLAYER" })

-- Auto Pickup Items
local AutoPickupEnabled = false
task.spawn(function()
    while true do
        if AutoPickupEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
                if root then
                    local droppedFolder = Workspace:FindFirstChild("DroppedItems")
                    if droppedFolder then
                        for _, item in ipairs(droppedFolder:GetChildren()) do
                            local targetPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                            if targetPart then
                                local prompt = item:FindFirstChildOfClass("ProximityPrompt") or targetPart:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then fireproximityprompt(prompt) end
                                local touchPart = item:FindFirstChild("PickUpZone") or targetPart
                                if touchPart then
                                    firetouchinterest(root, touchPart, 0)
                                    firetouchinterest(root, touchPart, 1)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.2)
        else
            task.wait(1)
        end
    end
end)

TabPlayer:Toggle({
    Title = "Auto Pickup Items",
    Default = false,
    Callback = function(state)
        AutoPickupEnabled = state
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Auto Pick ENABLED" or "Auto Pick DISABLED", Duration = 1.5 })
    end
})

-- Infinite Stamina (100% Funcional - Dual Module + Remote Sync)
local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
local AutoSprintLoop = nil

local function toggleInfStamina(enable)
    InfStaminaEnabled = enable
    pcall(function()
        local success, sprintModule = pcall(function()
            return require(ReplicatedStorage.Modules.Game.Sprint)
        end)
        if success and sprintModule then
            local consumeFunc = sprintModule.consume_stamina
            local upvalues = getupvalues(consumeFunc)
            local sprintBar
            for _, uv in ipairs(upvalues) do
                if type(uv) == "table" and rawget(uv, "sprint_bar") then
                    sprintBar = uv.sprint_bar
                    break
                end
            end
            
            if sprintBar then
                if enable then
                    local originalUpdate = sprintBar.update
                    sprintBar.update = function(...)
                        return originalUpdate(function() return 1 end)
                    end
                    OriginalSprintUpdate = originalUpdate
                    
                    if AutoSprintLoop then task.cancel(AutoSprintLoop) end
                    AutoSprintLoop = task.spawn(function()
                        while InfStaminaEnabled do
                            pcall(function()
                                FireServerHook("set_sprinting_1", true)
                                task.wait(0.5)
                                FireServerHook("set_sprinting_1", false)
                            end)
                            task.wait(0.1)
                        end
                        pcall(function() FireServerHook("set_sprinting_1", false) end)
                    end)
                else
                    if AutoSprintLoop then
                        task.cancel(AutoSprintLoop)
                        AutoSprintLoop = nil
                    end
                    pcall(function() FireServerHook("set_sprinting_1", false) end)
                    if OriginalSprintUpdate and sprintBar then
                        sprintBar.update = OriginalSprintUpdate
                        OriginalSprintUpdate = nil
                    end
                end
            end
        end
    end)
end

TabMovement:Section({ Title = "MOVEMENT" })

TabMovement:Toggle({
    Title = "Infinite Stamina",
    Default = false,
    Callback = function(state)
        toggleInfStamina(state)
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Inf Stamina ENABLED" or "Inf Stamina DISABLED", Duration = 1.5 })
    end
})

-- Speed Hack
local SpeedHackEnabled = false
local SpeedValue = 4
TabMovement:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(state)
        SpeedHackEnabled = state
    end
})
TabMovement:Slider({
    Title = "Speed Level",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = 4 },
    Callback = function(value)
        SpeedValue = value
    end
})

RunService.RenderStepped:Connect(function(dt)
    if SpeedHackEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local factor = (SpeedValue / 20) * 1.8
            local moveVec = hum.MoveDirection.Unit * (factor * 14 * dt)
            root.CFrame = root.CFrame + Vector3.new(moveVec.X, 0, moveVec.Z)
        end
    end
end)

-- Anti Kill Engine (reemplazado por el sistema Auto-Safe) 
local antiKillEnabled = false
local AutoSafeActive = false
local AutoSafeDepth = 25
local SavedAutoSafeY = nil
local TargetAutoSafeY = nil
local FrozenCameraCFrame = nil

local function resetAntiKill()
    AutoSafeActive = false
    TargetAutoSafeY = nil
    SavedAutoSafeY = nil
    FrozenCameraCFrame = nil
end

RunService.RenderStepped:Connect(function()
    if not antiKillEnabled or not LocalPlayer.Character then return end

    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if hum.Health > 0 then
        if hum.Health <= 30 and not AutoSafeActive then
            AutoSafeActive = true
            SavedAutoSafeY = root.Position.Y
            TargetAutoSafeY = SavedAutoSafeY - AutoSafeDepth
            FrozenCameraCFrame = Camera.CFrame
        end

        if AutoSafeActive then
            if TargetAutoSafeY then
                local offsetX = math.sin(os.clock() * 35) * 3.5
                local offsetZ = math.cos(os.clock() * 35) * 3.5
                root.CFrame = CFrame.new(
                    root.Position.X + offsetX,
                    TargetAutoSafeY,
                    root.Position.Z + offsetZ
                )
                root.AssemblyLinearVelocity = Vector3.zero
            end

            if FrozenCameraCFrame then
                Camera.CFrame = FrozenCameraCFrame
            end

            if hum.Health >= 40 then
                AutoSafeActive = false
                if SavedAutoSafeY then
                    root.CFrame = CFrame.new(
                        root.Position.X,
                        SavedAutoSafeY + 1.5,
                        root.Position.Z
                    )
                end
                TargetAutoSafeY = nil
                SavedAutoSafeY = nil
                FrozenCameraCFrame = nil
            end
        end
    else
        resetAntiKill()
    end
end)

LocalPlayer.CharacterAdded:Connect(resetAntiKill)

TabPlayer:Toggle({
    Title = "Anti Kill",
    Default = false,
    Callback = function(state)
        antiKillEnabled = state
        if not state then
            resetAntiKill()
        end
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = state and "Anti Kill ENABLED" or "Anti Kill DISABLED",
            Duration = 1.5
        })
    end
})

-- Jump Power & Infinite Jump
local InfiniteJumpEnabled = false
local JumpPowerBypassValue = 50

TabMovement:Section({ Title = "JUMP" })

TabMovement:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Infinite Jump ENABLED" or "Infinite Jump DISABLED", Duration = 1.5 })
    end
})

TabMovement:Slider({
    Title = "Jump Power",
    Step = 5,
    Value = { Min = 40, Max = 150, Default = 50 },
    Callback = function(value)
        JumpPowerBypassValue = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, JumpPowerBypassValue, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

-- Hide Name (Quitar Nombre)
local HideNameEnabled = false
local function updateNameVisibility(hidden)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local bb = root and root:FindFirstChild("CharacterBillboardGui")
        if bb and bb:FindFirstChild("PlayerName") then
            bb.PlayerName.Visible = not hidden
        end
    end)
end

TabPlayer:Toggle({
    Title = "Hide Name",
    Default = false,
    Callback = function(state)
        HideNameEnabled = state
        updateNameVisibility(state)
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Hide Name ENABLED" or "Hide Name DISABLED", Duration = 1.5 })
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if HideNameEnabled then
        task.wait(1)
        updateNameVisibility(true)
    end
end)

-- ==========================================
-- VISUAL SECTION (NAMES, INVENTORY ESP, ESP ARMAS)
-- ==========================================
TabVisual:Section({ Title = "PLAYER ESP" })

local namesESPEnabled = false
local healthBarESPEnabled = false
local inventoryESPEnabled = false
local weaponESPEnabled = false

-- Health Bar 2D (Drawing) - basada en la barra proporcionada.
local HealthBarDrawings = {}

local WeaponRegistry = {}
local PlayerBillboards = {}
local WeaponBillboards = {}
local WeaponCacheTokens = {}

local RarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Uncommon = Color3.fromRGB(0, 255, 0),
    Rare = Color3.fromRGB(0, 112, 221),
    Epic = Color3.fromRGB(163, 53, 238),
    Legendary = Color3.fromRGB(255, 128, 0)
}

local function registerItems(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle      = tool:FindFirstChild("Handle")
            local displayName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity      = tool:GetAttribute("RarityName") or "Common"
            local imageId     = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
            end
            if not key then
                key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
            end
            WeaponRegistry[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }
        end
    end
end

local function getItemKey(tool)
    local handle      = tool:FindFirstChild("Handle")
    local displayName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity      = tool:GetAttribute("RarityName") or "Common"
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity end
        if handle:IsA("MeshPart") and handle.MeshId ~= "" then return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if itemId and itemId ~= "" and itemId ~= tool.Name then return "ITEMID_" .. itemId .. "_RARITY_" .. rarity end
    return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function getWeaponInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    return WeaponRegistry[getItemKey(tool)]
end

local function createBillboardForPlayer(player)
    if not namesESPEnabled and not inventoryESPEnabled then return end
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
    
    local gui = Instance.new("BillboardGui")
    gui.Name        = "MorganHub_ESP"
    gui.Adornee     = head
    gui.Size        = UDim2.new(0, 160, 0, 88)
    gui.StudsOffset = Vector3.new(0, 2.8, 0)
    gui.AlwaysOnTop = true
    gui.Parent      = char
    
    local layout = Instance.new("UIListLayout", gui)
    layout.FillDirection       = Enum.FillDirection.Vertical
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Padding             = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    if namesESPEnabled then
        local nameLbl = Instance.new("TextLabel", gui)
        nameLbl.Size = UDim2.new(1, 0, 0, 16)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = player.Name
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.LayoutOrder = 1
    end
    
    if false and healthBarESPEnabled then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Health Bar PRO: cápsula redondeada, borde fino, brillo y porcentaje.
            local healthRow = Instance.new("Frame", gui)
            healthRow.Name = "HealthRow"
            healthRow.Size = UDim2.new(0, 148, 0, 24)
            healthRow.BackgroundTransparency = 1
            healthRow.LayoutOrder = 2

            local healthBg = Instance.new("Frame", healthRow)
            healthBg.Name = "HealthBar"
            healthBg.Size = UDim2.new(0, 118, 0, 12)
            healthBg.Position = UDim2.new(0, 0, 0.5, -6)
            healthBg.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            healthBg.BorderSizePixel = 0
            Instance.new("UICorner", healthBg).CornerRadius = UDim.new(1, 0)
            local bgStroke = Instance.new("UIStroke", healthBg)
            bgStroke.Color = Color3.fromRGB(115, 115, 125)
            bgStroke.Thickness = 1
            bgStroke.Transparency = 0.15

            local healthFill = Instance.new("Frame", healthBg)
            healthFill.Name = "HealthFill"
            healthFill.Size = UDim2.new(math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1), 0, 1, 0)
            healthFill.BackgroundColor3 = Color3.fromRGB(75, 235, 115)
            healthFill.BorderSizePixel = 0
            Instance.new("UICorner", healthFill).CornerRadius = UDim.new(1, 0)
            local fillGradient = Instance.new("UIGradient", healthFill)
            fillGradient.Rotation = 0
            fillGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 255, 125)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 185, 85))
            })

            local healthText = Instance.new("TextLabel", healthRow)
            healthText.Name = "HealthText"
            healthText.Size = UDim2.new(0, 30, 1, 0)
            healthText.Position = UDim2.new(0, 120, 0, 0)
            healthText.BackgroundTransparency = 1
            healthText.Text = tostring(math.floor(humanoid.Health)) .. "%"
            healthText.TextColor3 = Color3.fromRGB(235, 235, 240)
            healthText.TextStrokeTransparency = 0.55
            healthText.Font = Enum.Font.GothamBold
            healthText.TextSize = 11
            healthText.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    if inventoryESPEnabled then
        local toolsContainer = Instance.new("Frame", gui)
        toolsContainer.Name = "InventoryIcons"
        toolsContainer.Size = UDim2.new(1, -8, 0, 44)
        toolsContainer.BackgroundTransparency = 1
        toolsContainer.LayoutOrder = 3

        -- Inventory ESP: 2 filas, hasta 5 iconos por fila.
        local grid = Instance.new("UIGridLayout", toolsContainer)
        grid.CellSize = UDim2.fromOffset(22, 22)
        grid.CellPadding = UDim2.fromOffset(4, 2)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.FillDirectionMaxCells = 5
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.VerticalAlignment = Enum.VerticalAlignment.Center

        local tools = {}
        for _, bag in ipairs({ "Backpack", "StarterGear", "StarterPack" }) do
            local b = player:FindFirstChild(bag)
            if b then
                for _, t in ipairs(b:GetChildren()) do
                    if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
                end
            end
        end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
        end
        for _, tool in ipairs(tools) do
            local info = getWeaponInfo(tool)
            if info then
                local img = Instance.new("ImageLabel", toolsContainer)
                img.Size                   = UDim2.fromOffset(22, 22)
                img.BackgroundTransparency = 0.1
                img.Image                  = info.ImageId
                img.BackgroundColor3       = Color3.fromRGB(240, 248, 255)
                Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
                local stroke = Instance.new("UIStroke", img)
                stroke.Color    = RarityColors[info.Rarity] or Color3.new(1, 1, 1)
                stroke.Thickness = 2
            end
        end
    end
    
    PlayerBillboards[player] = gui
end

task.spawn(function()
    while true do
        task.wait(0.1)

        if healthBarESPEnabled then
            for player, gui in pairs(PlayerBillboards) do
                local char = player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local healthRow = gui and gui:FindFirstChild("HealthRow")
                local healthBg = healthRow and healthRow:FindFirstChild("HealthBar")
                local healthFill = healthBg and healthBg:FindFirstChild("HealthFill")
                local healthText = healthRow and healthRow:FindFirstChild("HealthText")
                if humanoid and healthFill then
                    local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                    healthFill.Size = UDim2.new(ratio, 0, 1, 0)
                    if healthText then healthText.Text = tostring(math.floor(ratio * 100)) .. "%" end

                    -- Verde -> amarillo -> rojo según la vida restante.
                    if ratio > 0.5 then
                        local t = (ratio - 0.5) * 2
                        healthFill.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 - (210 * t)),
                            220,
                            70
                        )
                    else
                        local t = ratio * 2
                        healthFill.BackgroundColor3 = Color3.fromRGB(
                            255,
                            math.floor(55 + (165 * t)),
                            55
                        )
                    end
                end
            end
        end

        if weaponESPEnabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local char = pl.Character
                    local root = char.HumanoidRootPart
                    local tools = {}
                    local token = ""
                    local bp = pl:FindFirstChild("Backpack")
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do 
                            if t:IsA("Tool") and t.Name ~= "Fists" then 
                                table.insert(tools, t) 
                                token = token .. t.Name .. "_"
                            end 
                        end
                    end
                    for _, t in ipairs(char:GetChildren()) do 
                        if t:IsA("Tool") and t.Name ~= "Fists" then 
                            table.insert(tools, t) 
                            token = token .. t.Name .. "_E_"
                        end 
                    end
                    
                    local bg = WeaponBillboards[pl]
                    if not bg or not bg.Parent or bg.Adornee ~= root then
                        if bg then pcall(function() bg:Destroy() end) end
                        bg = Instance.new("BillboardGui")
                        bg.Name = "WeaponESP_" .. pl.Name
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 140, 0, 24)
                        bg.StudsOffset = Vector3.new(0, -3.8, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = CoreGui
                        
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        WeaponBillboards[pl] = bg
                        WeaponCacheTokens[pl] = nil
                    end

                    if WeaponCacheTokens[pl] ~= token then
                        WeaponCacheTokens[pl] = token
                        bg:ClearAllChildren()
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        for _, t in ipairs(tools) do
                            local info = getWeaponInfo(t)
                            if info then
                                local icon = Instance.new("ImageLabel", bg)
                                icon.Size = UDim2.new(0, 22, 0, 22)
                                icon.BackgroundTransparency = 0.2
                                icon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                                icon.Image = info.ImageId
                                Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
                                local stroke = Instance.new("UIStroke", icon)
                                stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                stroke.Thickness = 1.5
                            end
                        end
                    end
                end
            end
        else
            for _, bg in pairs(WeaponBillboards) do bg:Destroy() end
            WeaponBillboards = {}
            WeaponCacheTokens = {}
        end
    end
end)

-- ==========================================
-- HEALTH BAR 2D | DRAWING
-- ==========================================
local function destroyHealthBar(player)
    local d = HealthBarDrawings[player]
    if not d then return end

    for _, obj in pairs(d) do
        if typeof(obj) == "userdata" or typeof(obj) == "table" then
            pcall(function()
                if obj.Destroy then obj:Destroy() end
            end)
        end
    end

    HealthBarDrawings[player] = nil
end

local function createHealthBar(player)
    if not healthBarESPEnabled or player == LocalPlayer then return end

    destroyHealthBar(player)

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return end

    local fondo = Drawing.new("Square")
    fondo.Visible = false
    fondo.Color = Color3.fromRGB(35, 35, 35)
    fondo.Filled = true
    fondo.Thickness = 0

    local barra = Drawing.new("Square")
    barra.Visible = false
    barra.Filled = true
    barra.Thickness = 0

    local borde = Drawing.new("Square")
    borde.Visible = false
    borde.Color = Color3.fromRGB(80, 80, 80)
    borde.Filled = false
    borde.Thickness = 1

    HealthBarDrawings[player] = {
        fondo = fondo,
        barra = barra,
        borde = borde,
        character = character,
        humanoid = humanoid,
        head = head
    }
end

local function hideHealthBar(d)
    if not d then return end
    d.fondo.Visible = false
    d.barra.Visible = false
    d.borde.Visible = false
end

local function updateHealthBars()
    if not healthBarESPEnabled then return end

    Camera = Workspace.CurrentCamera or Camera

    for player, d in pairs(HealthBarDrawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")

        if not character or not humanoid or not head or humanoid.Health <= 0 then
            hideHealthBar(d)
            continue
        end

        -- Si el jugador reapareció, reconstruir las referencias/drawings.
        if d.character ~= character or d.humanoid ~= humanoid or d.head ~= head then
            createHealthBar(player)
            d = HealthBarDrawings[player]
            if not d then continue end
            character, humanoid, head = d.character, d.humanoid, d.head
        end

        -- Posición debajo de la cabeza, siguiendo el código proporcionado.
        local posMundo = head.Position - Vector3.new(0, 2.5, 0)
        local posPantalla, enPantalla = Camera:WorldToViewportPoint(posMundo)

        if not enPantalla or posPantalla.Z < 0 then
            hideHealthBar(d)
            continue
        end

        local ancho = 50
        local alto = 6
        local maxHealth = math.max(tonumber(humanoid.MaxHealth) or 1, 1)
        local porcentaje = math.clamp(humanoid.Health / maxHealth, 0, 1)

        local x = posPantalla.X - ancho / 2
        local y = posPantalla.Y + 12

        if porcentaje > 0.6 then
            d.barra.Color = Color3.fromRGB(0, 255, 85)
        elseif porcentaje > 0.3 then
            d.barra.Color = Color3.fromRGB(255, 190, 0)
        else
            d.barra.Color = Color3.fromRGB(255, 45, 45)
        end

        d.fondo.Position = Vector2.new(x, y)
        d.fondo.Size = Vector2.new(ancho, alto)

        d.barra.Position = Vector2.new(x, y)
        d.barra.Size = Vector2.new(ancho * porcentaje, alto)

        d.borde.Position = Vector2.new(x - 1, y - 1)
        d.borde.Size = Vector2.new(ancho + 2, alto + 2)

        d.fondo.Visible = true
        d.barra.Visible = true
        d.borde.Visible = true
    end
end

RunService.RenderStepped:Connect(updateHealthBars)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if namesESPEnabled or inventoryESPEnabled then
            task.wait(0.2)
            createBillboardForPlayer(player)
        end
        if healthBarESPEnabled then
            task.wait(0.2)
            createHealthBar(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    destroyHealthBar(player)
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
    if WeaponBillboards[player] then
        WeaponBillboards[player]:Destroy()
        WeaponBillboards[player] = nil
    end
    WeaponCacheTokens[player] = nil
end)

task.spawn(function()
    local Items = ReplicatedStorage:WaitForChild("Items", 15)
    if Items then
        for _, folderName in ipairs({ "gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish" }) do
            local folder = Items:FindFirstChild(folderName)
            if folder then
                registerItems(folder)
            end
        end
    end
end)

local function refreshAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if namesESPEnabled or inventoryESPEnabled then
            createBillboardForPlayer(p)
        else
            if PlayerBillboards[p] then
                PlayerBillboards[p]:Destroy()
                PlayerBillboards[p] = nil
            end
        end

        if healthBarESPEnabled then
            createHealthBar(p)
        else
            destroyHealthBar(p)
        end
    end
end

TabVisual:Toggle({
    Title = "Player Names",
    Default = false,
    Callback = function(state)
        namesESPEnabled = state
        refreshAll()
    end
})

TabVisual:Toggle({
    Title = "Health Bar",
    Default = false,
    Callback = function(state)
        healthBarESPEnabled = state
        refreshAll()
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = state and "Health Bar ENABLED" or "Health Bar DISABLED",
            Duration = 1.2
        })
    end
})

TabVisual:Section({ Title = "Item & Weapon ESP" })

TabVisual:Toggle({
    Title = "Inventory ESP",
    Default = false,
    Callback = function(state)
        inventoryESPEnabled = state
        refreshAll()
    end
})

TabVisual:Toggle({
    Title = "ESP Armas",
    Default = false,
    Callback = function(state)
        weaponESPEnabled = state
        if not state then
            for _, bg in pairs(WeaponBillboards) do bg:Destroy() end
            WeaponBillboards = {}
            WeaponCacheTokens = {}
        end
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "ESP Armas ENABLED" or "ESP Armas DISABLED", Duration = 1.5 })
    end
})

TabVisual:Section({ Title = "LINE LOCK" })
TabVisual:Toggle({
    Title = "Line Lock",
    Default = false,
    Callback = function(state)
        targetLineEnabled = state
        if not state then
            TargetLine.Visible = false
            TargetMarker.Visible = false
            CurrentLockedTarget = SilentAimEnabled and getClosestPlayerInFOV() or nil
        end
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = state and "Line Lock ENABLED" or "Line Lock DISABLED",
            Duration = 1.5
        })
    end
})

TabVisual:Toggle({
    Title = "Shot Effect",
    Default = false,
    Callback = function(state)
        shotEffectEnabled = state
        if not state then
            for _, part in ipairs(shotEffectParts) do
                pcall(function() part:Destroy() end)
            end
            shotEffectParts = {}
        end
    end
})

-- ==========================================
-- LINE LOCK + SHOT EFFECT
-- ==========================================
local shotEffectEnabled = false
local shotEffectBusy = false
local shotEffectParts = {}
local shotTracerParts = {}

-- Línea roja de disparo: visual independiente, sin comprobar si impactó.
showShotTracer = function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local endPos = center + Vector2.new(0, -90)

    if CurrentLockedTarget and CurrentLockedTarget.Character then
        local targetChar = CurrentLockedTarget.Character
        local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local pos, visible = Camera:WorldToViewportPoint(targetPart.Position)
            if visible and pos.Z > 0 then
                endPos = Vector2.new(pos.X, pos.Y)
            end
        end
    end

    local diff = endPos - center
    local length = diff.Magnitude
    if length < 3 then return end

    local line = Instance.new("Frame")
    line.Name = "Morgan_RedShotLine"
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 35, 45)
    line.BackgroundTransparency = 0.05
    line.Size = UDim2.fromOffset(length, 2)
    line.Position = UDim2.fromOffset(center.X, center.Y)
    line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
    line.ZIndex = 1000
    line.Parent = ScreenGui
    table.insert(shotTracerParts, line)

    task.delay(0.12, function()
        if line then pcall(function() line:Destroy() end) end
    end)
end

showShotEffect = function()
    if not shotEffectEnabled or shotEffectBusy then return end
    shotEffectBusy = true

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for i = 1, 8 do
        local part = Instance.new("Frame")
        part.Name = "ShotFX"
        part.BorderSizePixel = 0
        part.AnchorPoint = Vector2.new(0, 0.5)
        part.Size = UDim2.fromOffset(26, 2)
        part.Position = UDim2.fromOffset(center.X, center.Y)
        part.Rotation = (i - 1) * 45
        part.BackgroundColor3 = Color3.fromRGB(255, 35, 45)
        part.ZIndex = 100
        part.Parent = crosshairGui
        table.insert(shotEffectParts, part)

        task.delay(0.09, function()
            if part then pcall(function() part:Destroy() end) end
        end)
    end

    task.delay(0.06, function()
        shotEffectBusy = false
    end)
end

local function hookShotTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    if tool:GetAttribute("Morgan_ShotFX_Hooked") then return end
    tool:SetAttribute("Morgan_ShotFX_Hooked", true)
    tool.Activated:Connect(function()
        if tool.Parent == LocalPlayer.Character then
            showShotEffect()
        end
    end)
end

local function hookCharacterTools()
    local char = LocalPlayer.Character
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then hookShotTool(obj) end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.25)
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then hookShotTool(obj) end
    end
    char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then hookShotTool(obj) end
    end)
end)

hookCharacterTools()

-- ==========================================
-- CROSSHAIR + TARGET HIGHLIGHT
-- ==========================================
TabVisual:Section({ Title = "Combat Visuals" })

local crosshairEnabled = false
local crosshairSize = 8
local crosshairGap = 4
local crosshairParts = {}
local targetHighlightEnabled = false
local targetHighlight = nil

local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "MorganHub_Crosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.DisplayOrder = 9999
crosshairGui.Parent = CoreGui

local function makeCrossPart(name)
    local f = Instance.new("Frame")
    f.Name = name
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Parent = crosshairGui
    return f
end

crosshairParts.Top = makeCrossPart("Top")
crosshairParts.Bottom = makeCrossPart("Bottom")
crosshairParts.Left = makeCrossPart("Left")
crosshairParts.Right = makeCrossPart("Right")

local function updateCrosshair()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local s = crosshairSize
    local g = crosshairGap
    local t = 2
    crosshairParts.Top.Size = UDim2.fromOffset(t, s)
    crosshairParts.Bottom.Size = UDim2.fromOffset(t, s)
    crosshairParts.Left.Size = UDim2.fromOffset(s, t)
    crosshairParts.Right.Size = UDim2.fromOffset(s, t)
    crosshairParts.Top.Position = UDim2.fromOffset(center.X, center.Y - g - s/2)
    crosshairParts.Bottom.Position = UDim2.fromOffset(center.X, center.Y + g + s/2)
    crosshairParts.Left.Position = UDim2.fromOffset(center.X - g - s/2, center.Y)
    crosshairParts.Right.Position = UDim2.fromOffset(center.X + g + s/2, center.Y)
    for _, part in pairs(crosshairParts) do part.Visible = crosshairEnabled end
end

TabVisual:Toggle({
    Title = "Custom Crosshair",
    Default = false,
    Callback = function(state)
        crosshairEnabled = state
        updateCrosshair()
    end
})

TabVisual:Slider({
    Title = "Crosshair Size",
    Step = 1,
    Value = { Min = 3, Max = 18, Default = 8 },
    Callback = function(value)
        crosshairSize = tonumber(value) or 8
        updateCrosshair()
    end
})

TabVisual:Slider({
    Title = "Crosshair Gap",
    Step = 1,
    Value = { Min = 0, Max = 15, Default = 4 },
    Callback = function(value)
        crosshairGap = tonumber(value) or 4
        updateCrosshair()
    end
})

TabVisual:Toggle({
    Title = "Target Highlight",
    Default = false,
    Callback = function(state)
        targetHighlightEnabled = state
        if not state and targetHighlight then
            pcall(function() targetHighlight:Destroy() end)
            targetHighlight = nil
        end
    end
})

RunService.RenderStepped:Connect(function()
    if crosshairEnabled then updateCrosshair() end
    if targetHighlightEnabled and SilentAimEnabled and CurrentLockedTarget and CurrentLockedTarget.Character then
        local char = CurrentLockedTarget.Character
        if not targetHighlight or targetHighlight.Adornee ~= char then
            if targetHighlight then pcall(function() targetHighlight:Destroy() end) end
            targetHighlight = Instance.new("Highlight")
            targetHighlight.Name = "Morgan_TargetHighlight"
            targetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            targetHighlight.FillTransparency = 0.72
            targetHighlight.OutlineTransparency = 0.05
            targetHighlight.FillColor = Color3.fromRGB(255, 210, 80)
            targetHighlight.OutlineColor = Color3.fromRGB(255, 240, 150)
            targetHighlight.Adornee = char
            targetHighlight.Parent = Workspace
        end
    elseif targetHighlight then
        pcall(function() targetHighlight:Destroy() end)
        targetHighlight = nil
    end
end)

-- Anti-AFK: evita que Roblox marque al jugador como inactivo.
local antiAFKEnabled = false
TabUtility:Section({ Title = "Quality of Life" })
TabUtility:Toggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(state)
        antiAFKEnabled = state
        WindUI:Notify({ Title = "MORGAN HUB", Content = state and "Anti AFK ENABLED" or "Anti AFK DISABLED", Duration = 1.5 })
    end
})

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if antiAFKEnabled then
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- ==========================================
-- CONFIGURACIONES (solo ajustes visuales)
-- ==========================================
local ConfigFolder = "MORGAN_HUB"
local ConfigName = "Default"
local SelectedConfig = "Default"

local function configPath(name)
    name = tostring(name or "Default"):gsub("[^%w_%-]", "_")
    if name == "" then name = "Default" end
    return ConfigFolder .. "/" .. name .. ".json"
end

local function ensureConfigFolder()
    pcall(function()
        if makefolder and not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end)
end

local function getVisualConfig()
    return {
        NamesESP = namesESPEnabled == true,
        HealthBarESP = healthBarESPEnabled == true,
        InventoryESP = inventoryESPEnabled == true,
        WeaponESP = weaponESPEnabled == true,
        LineLock = targetLineEnabled == true,
        ShotEffect = shotEffectEnabled == true,
    }
end

local function applyVisualConfig(cfg)
    if type(cfg) ~= "table" then return false end

    namesESPEnabled = cfg.NamesESP == true
    healthBarESPEnabled = cfg.HealthBarESP == true
    inventoryESPEnabled = cfg.InventoryESP == true
    weaponESPEnabled = cfg.WeaponESP == true
    targetLineEnabled = cfg.LineLock == true
    shotEffectEnabled = cfg.ShotEffect == true

    refreshAll()

    if not weaponESPEnabled then
        for _, bg in pairs(WeaponBillboards) do
            pcall(function() bg:Destroy() end)
        end
        WeaponBillboards = {}
        WeaponCacheTokens = {}
    end

    return true
end

local function saveConfig(name)
    ensureConfigFolder()
    name = tostring(name or ConfigName or "Default")
    if name == "" then name = "Default" end
    ConfigName = name
    SelectedConfig = name

    if not writefile or not HttpService then
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = "Tu executor no permite guardar configuraciones.",
            Duration = 2.5
        })
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONEncode(getVisualConfig())
    end)

    if ok then
        local wrote = pcall(function()
            writefile(configPath(name), data)
        end)

        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = wrote and ("Configuración guardada: " .. name) or "No se pudo guardar la configuración.",
            Duration = 2
        })
    end
end

local function loadConfig(name)
    ensureConfigFolder()
    name = tostring(name or SelectedConfig or "Default")
    if name == "" then name = "Default" end
    SelectedConfig = name
    ConfigName = name

    if not isfile or not readfile or not HttpService or not isfile(configPath(name)) then
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = "No existe la configuración: " .. name,
            Duration = 2
        })
        return
    end

    local ok, cfg = pcall(function()
        return HttpService:JSONDecode(readfile(configPath(name)))
    end)

    if ok and applyVisualConfig(cfg) then
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = "Configuración cargada: " .. name,
            Duration = 2
        })
    else
        WindUI:Notify({
            Title = "MORGAN HUB",
            Content = "La configuración está dañada o no es válida.",
            Duration = 2
        })
    end
end

local function getConfigNames()
    local names = {"Default"}
    if listfiles then
        pcall(function()
            for _, path in ipairs(listfiles(ConfigFolder)) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name and name ~= "" then
                    local exists = false
                    for _, current in ipairs(names) do
                        if current == name then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        table.insert(names, name)
                    end
                end
            end
        end)
    end
    table.sort(names)
    return names
end

TabUtility:Section({ Title = "Configurations (Visual)" })

TabUtility:Input({
    Title = "Nombre de configuración",
    Desc = "Escribe el nombre para guardar.",
    Placeholder = "Ej: MiESP",
    Value = "Default",
    Callback = function(value)
        ConfigName = tostring(value or "Default")
        if ConfigName == "" then ConfigName = "Default" end
    end
})

TabUtility:Dropdown({
    Title = "Seleccionar configuración",
    Values = getConfigNames(),
    Value = "Default",
    AllowNone = false,
    Callback = function(value)
        if type(value) == "table" then
            value = value[1]
        end
        SelectedConfig = tostring(value or "Default")
        ConfigName = SelectedConfig
    end
})

TabUtility:Button({
    Title = "Guardar configuración",
    Callback = function()
        saveConfig(ConfigName)
    end
})

TabUtility:Button({
    Title = "Cargar configuración",
    Callback = function()
        loadConfig(SelectedConfig)
    end
})

-- ==========================================

-- Startup Notification with Creator Credit
WindUI:Notify({
    Title = "MORGAN HUB",
    Content = "Menu loaded successfully",
    Duration = 4
})
