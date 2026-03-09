local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

for _, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:match("Latte") or v.Name:match("Mocher")) then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_v35_Master"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local LAVENDER, RED = Color3.fromRGB(230, 190, 255), Color3.fromRGB(255, 50, 50)
local BG, SECONDARY = Color3.fromRGB(12, 12, 12), Color3.fromRGB(8, 8, 8)
local INT_LIMIT = 2147483647

local State = {
    Visible = true, AntiKill = false, Fly = false, FlySpeed = 2.5,
    Ghost = false, Invisible = false, AntiRubberBand = false,
    Esp = false, Aimbot = false, Tracers = false, Boxes = false, NameTags = false,
    OriginalPos = nil, Target = nil
}

local GlobalGrad = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PINK), 
    ColorSequenceKeypoint.new(0.5, BLUE), 
    ColorSequenceKeypoint.new(1, PINK)
})

local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size, Watermark.Position = UDim2.new(0, 400, 0, 40), UDim2.new(0.5, -200, 0, 15)
Watermark.BackgroundTransparency, Watermark.Text = 1, "Latte | NullTheDev"
Watermark.Font, Watermark.TextSize, Watermark.TextColor3 = Enum.Font.Code, 24, WHITE
local WGrad = Instance.new("UIGradient", Watermark)
WGrad.Color = GlobalGrad
RunService.RenderStepped:Connect(function() WGrad.Offset = Vector2.new(math.sin(tick() * 2) * 0.5, 0) end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 750, 0, 520), UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Border = Instance.new("Frame", MainFrame)
Border.Size, Border.Position, Border.ZIndex = UDim2.new(1, 4, 1, 4), UDim2.new(0, -2, 0, -2), -1
Border.BackgroundColor3 = WHITE
Instance.new("UICorner", Border)
local BGrad = Instance.new("UIGradient", Border)
BGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, LAVENDER), ColorSequenceKeypoint.new(0.5, RED), ColorSequenceKeypoint.new(1, LAVENDER)})
RunService.RenderStepped:Connect(function() BGrad.Rotation = BGrad.Rotation + 3 end)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 140, 1, 0), SECONDARY
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 150, 0, 10), UDim2.new(1, -410, 1, -20), 1

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size, btn.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
    btn.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 40 - 40)
    btn.Text, btn.TextColor3, btn.Font = "  " .. name, Color3.new(0.5, 0.5, 0.5), Enum.Font.Code
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local frame = Instance.new("ScrollingFrame", Container)
    frame.Size, frame.BackgroundTransparency, frame.Visible = UDim2.new(1, 0, 1, 0), 1, false
    frame.ScrollBarThickness, frame.CanvasSize = 0, UDim2.new(0, 0, 4, 0)
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 5)
    Tabs[name] = {B = btn, F = frame}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.5, 0.5, 0.5) end
        frame.Visible, btn.TextColor3 = true, PINK
    end)
    return frame
end

local MainTab = CreateTab("Main")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local TeamsTab = CreateTab("Teams")
local InventoryTab = CreateTab("Inventory")
local NetworkTab = CreateTab("Network")
local ConsoleTab = CreateTab("Console")

local function AddToggle(parent, text, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30), "  " .. text
    b.TextColor3, b.Font, b.TextXAlignment = WHITE, Enum.Font.Code, Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        if key then State[key] = not State[key] end
        b.BackgroundColor3 = (key and State[key]) and PINK or Color3.fromRGB(30, 30, 30)
        if cb then cb(State[key]) end
    end)
end

AddToggle(MainTab, "Anti-Kill", "AntiKill")
AddToggle(MainTab, "Stable Fly", "Fly")
AddToggle(MainTab, "Ghost", "Ghost")
AddToggle(MainTab, "Invisible", "Invisible")
AddToggle(MainTab, "No Cooldown", nil, function()
    for _, v in pairs(LocalPlayer.Backpack:GetDescendants()) do
        if v.Name:lower():match("cooldown") or v.Name:lower():match("wait") then v.Value = 0 end
    end
end)

AddToggle(CombatTab, "Aimbot", "Aimbot")

AddToggle(VisualsTab, "ESP", "Esp")
AddToggle(VisualsTab, "2D Box ESP", "Boxes")
AddToggle(VisualsTab, "Tracers", "Tracers")
AddToggle(VisualsTab, "Name Tags", "NameTags")

local function GetClosest()
    local target, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if d < dist then target, dist = p, d end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            local h = char:FindFirstChild("LatteESP")
            if State.Esp then
                if not h then
                    h = Instance.new("Highlight", char)
                    h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, WHITE
                    local g = Instance.new("UIGradient", h) g.Color = GlobalGrad
                end
            elseif h then h:Destroy() end

            local b = char:FindFirstChild("LatteBox")
            if State.Boxes and onScreen then
                if not b then
                    b = Instance.new("BillboardGui", char)
                    b.Name, b.Size, b.AlwaysOnTop = "LatteBox", UDim2.new(4.5, 0, 6, 0), true
                    local frame = Instance.new("Frame", b)
                    frame.Size, frame.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
                    local uiStroke = Instance.new("UIStroke", frame)
                    uiStroke.Thickness, uiStroke.Color = 2, WHITE
                    local g = Instance.new("UIGradient", uiStroke) g.Color = GlobalGrad
                end
            elseif b then b:Destroy() end

            local n = char:FindFirstChild("LatteName")
            if State.NameTags then
                if not n then
                    n = Instance.new("BillboardGui", char)
                    n.Name, n.Size, n.AlwaysOnTop, n.ExtentsOffset = "LatteName", UDim2.new(0, 200, 0, 50), true, Vector3.new(0, 3, 0)
                    local label = Instance.new("TextLabel", n)
                    label.Size, label.BackgroundTransparency, label.Text = UDim2.new(1, 0, 1, 0), 1, p.DisplayName
                    label.TextColor3, label.Font, label.TextSize = WHITE, Enum.Font.Code, 14
                    local g = Instance.new("UIGradient", label) g.Color = GlobalGrad
                end
            elseif n then n:Destroy() end

            local t = char:FindFirstChild("LatteTracer")
            if State.Tracers and onScreen then
                if not t then
                    t = Instance.new("Frame", ScreenGui)
                    t.Name, t.BorderSizePixel, t.AnchorPoint = "LatteTracer", 0, Vector2.new(0.5, 0.5)
                    local g = Instance.new("UIGradient", t) g.Color = GlobalGrad
                end
                local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local dest = Vector2.new(screenPos.X, screenPos.Y)
                local mag = (dest - origin).Magnitude
                t.Size = UDim2.new(0, mag, 0, 2)
                t.Position = UDim2.new(0, (origin.X + dest.X) / 2, 0, (origin.Y + dest.Y) / 2)
                t.Rotation = math.deg(math.atan2(dest.Y - origin.Y, dest.X - origin.X))
            elseif t then t:Destroy() end
        end
    end

    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)

Tabs["Main"].F.Visible, Tabs["Main"].B.TextColor3 = true, PINK
