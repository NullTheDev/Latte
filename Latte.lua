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
ScreenGui.Name = "Latte_v40_AimbotFix"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local BG, SECONDARY = Color3.fromRGB(12, 12, 12), Color3.fromRGB(8, 8, 8)
local GlobalGrad = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 750, 0, 520), UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3, MainFrame.Active, MainFrame.Draggable = BG, true, true
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

local State = {Visible = true, AntiKill = false, Fly = false, Esp = false, Aimbot = false, Tracers = false, Boxes = false, NameTags = false, Target = nil}
local Tabs = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size, btn.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
    btn.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 40 - 40)
    btn.Text, btn.TextColor3, btn.Font = "  " .. name, Color3.new(0.5, 0.5, 0.5), Enum.Font.Code
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local frame = Instance.new("ScrollingFrame", Container)
    frame.Size, frame.BackgroundTransparency, frame.Visible = UDim2.new(1, 0, 1, 0), 1, false
    frame.ScrollBarThickness, frame.CanvasSize = 0, UDim2.new(0, 0, 3, 0)
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 5)
    Tabs[name] = {B = btn, F = frame}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.5, 0.5, 0.5) end
        frame.Visible, btn.TextColor3 = true, PINK
    end)
    return frame
end

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

local MainTab = CreateTab("Main")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local TeamsTab = CreateTab("Teams")
local InventoryTab = CreateTab("Inventory")
local NetworkTab = CreateTab("Network")
local ConsoleTab = CreateTab("Console")

AddToggle(MainTab, "Stable Fly", "Fly")
AddToggle(MainTab, "No Cooldown", nil, function()
    for _, v in pairs(LocalPlayer.Backpack:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 0 end
    end
end)

AddToggle(CombatTab, "Aimbot", "Aimbot")
AddToggle(VisualsTab, "ESP", "Esp")
AddToggle(VisualsTab, "2D Box ESP", "Boxes")
AddToggle(VisualsTab, "3D Tracers", "Tracers")
AddToggle(VisualsTab, "Name Tags", "NameTags")

AddToggle(NetworkTab, "Break Scripts", nil, function()
    for _, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v.Disabled = true end end
end)
AddToggle(NetworkTab, "Destroy Scripts", nil, function()
    for _, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v:Destroy() end end
end)

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

local TracerFolder = Instance.new("Folder", workspace)
TracerFolder.Name = "LatteTracers"

RunService.RenderStepped:Connect(function()
    TracerFolder:ClearAllChildren()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if State.Tracers then
                local a0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
                local a1 = Instance.new("Attachment", p.Character.HumanoidRootPart)
                local b = Instance.new("Beam", TracerFolder)
                b.Attachment0, b.Attachment1, b.Width0, b.Width1 = a0, a1, 0.05, 0.05
                b.Color, b.FaceCamera = GlobalGrad, true
            end
        end
    end

    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
end)

local function UpdateList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.BackgroundColor3, b.TextColor3, b.Text = UDim2.new(1, 0, 0, 30), Color3.fromRGB(25, 25, 25), PINK, p.DisplayName
        b.Font = Enum.Font.Code
        Instance.new("UICorner", b)
    end
end

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
Tabs["Main"].F.Visible, Tabs["Main"].B.TextColor3 = true, PINK
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end end)
