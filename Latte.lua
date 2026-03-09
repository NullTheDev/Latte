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
ScreenGui.Name = "Latte_v36_Fixed"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
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

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 750, 0, 520), UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 140, 1, 0), SECONDARY
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 150, 0, 10), UDim2.new(0, 340, 1, -20), 1

local ListPanel = Instance.new("Frame", MainFrame)
ListPanel.Size, ListPanel.Position = UDim2.new(0, 250, 1, 0), UDim2.new(1, -250, 0, 0)
ListPanel.BackgroundColor3 = SECONDARY
Instance.new("UICorner", ListPanel)

local PScroll = Instance.new("ScrollingFrame", ListPanel)
PScroll.Size, PScroll.Position, PScroll.BackgroundTransparency = UDim2.new(1, -10, 0.95, 0), UDim2.new(0, 5, 0, 5), 1
PScroll.ScrollBarThickness, PScroll.CanvasSize = 0, UDim2.new(0, 0, 5, 0)
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 5)

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size, btn.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
    btn.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 40 - 40)
    btn.Text, btn.TextColor3, btn.Font = "  " .. name, Color3.new(0.5, 0.5, 0.5), Enum.Font.Code
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local frame = Instance.new("ScrollingFrame", Container)
    frame.Size, frame.BackgroundTransparency, frame.Visible = UDim2.new(1, 0, 1, 0), 1, false
    frame.ScrollBarThickness, frame.CanvasSize = 0, UDim2.new(0, 0, 2, 0)
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
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            if v.Name:lower():find("cooldown") or v.Name:lower():find("wait") then v.Value = 0 end
        end
    end
end)

AddToggle(CombatTab, "Aimbot", "Aimbot")
AddToggle(VisualsTab, "ESP", "Esp")
AddToggle(VisualsTab, "2D Box ESP", "Boxes")
AddToggle(VisualsTab, "Tracers", "Tracers")
AddToggle(VisualsTab, "Name Tags", "NameTags")

local function UpdateList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.BackgroundColor3, b.TextColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(25, 25, 25), PINK
        b.Text, b.Font = p.DisplayName, Enum.Font.Code
        Instance.new("UICorner", b)
    end
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            local t = p.Character:FindFirstChild("LatteTracer")
            if State.Tracers and onScreen then
                if not t then
                    t = Instance.new("Frame", ScreenGui)
                    t.Name, t.BorderSizePixel, t.ZIndex = "LatteTracer", 0, 0
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
        local t, d = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < d then t, d = p, mag end
                end
            end
        end
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end
end)

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
Tabs["Main"].F.Visible, Tabs["Main"].B.TextColor3 = true, PINK
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end end)
