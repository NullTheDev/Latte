local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Mocher_v14"

local PINK = Color3.fromRGB(255, 105, 180)
local GREEN = Color3.fromRGB(0, 255, 0)
local BG = Color3.fromRGB(20, 20, 20)
local SECONDARY = Color3.fromRGB(15, 15, 15)

-- State
local MenuVisible, AimbotActive, EspActive = true, false, false
local AntiKillActive, FlyActive = false, false
local TargetPlayer = nil
local FlySpeed, Smoothing = 50, 0.12

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 460)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -230)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame)

-- Dragging Logic
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = SECONDARY
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 150, 0, 10)
Container.Size = UDim2.new(1, -370, 1, -20)
Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 35 - 35)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    btn.Font = Enum.Font.Code
    
    local frame = Instance.new("ScrollingFrame", Container)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 2
    frame.CanvasSize = UDim2.new(0, 0, 4, 0)
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 5)
    
    Tabs[name] = {B = btn, F = frame}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible = false t.B.TextColor3 = Color3.new(0.6, 0.6, 0.6) end
        frame.Visible, btn.TextColor3 = true, PINK
    end)
    return frame
end

local PlayerTab = CreateTab("Player")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local NetworkTab = CreateTab("Network")

-- Player List Panel
local ListPanel = Instance.new("Frame", MainFrame)
ListPanel.Size = UDim2.new(0, 200, 1, 0)
ListPanel.Position = UDim2.new(1, -200, 0, 0)
ListPanel.BackgroundColor3 = SECONDARY
ListPanel.Visible = false
Instance.new("UICorner", ListPanel)

local PScroll = Instance.new("ScrollingFrame", ListPanel)
PScroll.Size = UDim2.new(1, -10, 0.65, 0)
PScroll.Position = UDim2.new(0, 5, 0, 5)
PScroll.BackgroundTransparency = 1
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 5)

local OptionPanel = Instance.new("Frame", ListPanel)
OptionPanel.Size = UDim2.new(1, -10, 0.3, 0)
OptionPanel.Position = UDim2.new(0, 5, 0.68, 0)
OptionPanel.BackgroundTransparency = 1
Instance.new("UIListLayout", OptionPanel).Padding = UDim.new(0, 4)

-- Dynamic Teleport Fix
local function GoToTarget()
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local targetHrp = TargetPlayer.Character.HumanoidRootPart
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
    end
end

local function AddAction(text, cb)
    local b = Instance.new("TextButton", OptionPanel)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text
    b.TextColor3 = PINK
    b.Font = Enum.Font.Code
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

AddAction("Go To", GoToTarget)
AddAction("View", function() if TargetPlayer then Camera.CameraSubject = TargetPlayer.Character.Humanoid end end)

-- UI Helpers
local function AddToggle(parent, text, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = "  " .. text
    b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    b.Font = Enum.Font.Code
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = act and PINK or Color3.fromRGB(35, 35, 35)}):Play()
        cb(act)
    end)
end

-- Core Features
AddToggle(PlayerTab, "Toggle Player List", function(s) ListPanel.Visible = s end)
AddToggle(PlayerTab, "Anti-Kill", function(s) AntiKillActive = s end)
AddToggle(PlayerTab, "Dynamic Fly", function(s) FlyActive = s end)
AddToggle(CombatTab, "Aimbot", function(s) AimbotActive = s end)
AddToggle(VisualsTab, "Master ESP", function(s) EspActive = s end)

local HealthIn = Instance.new("TextBox", CombatTab)
HealthIn.Size = UDim2.new(1, -10, 0, 35)
HealthIn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HealthIn.PlaceholderText = "Enter Custom Health"
HealthIn.TextColor3 = Color3.new(1, 1, 1)
HealthIn.Font = Enum.Font.Code
Instance.new("UICorner", HealthIn)
HealthIn.FocusLost:Connect(function(e) if e and tonumber(HealthIn.Text) then LocalPlayer.Character.Humanoid.MaxHealth = tonumber(HealthIn.Text) LocalPlayer.Character.Humanoid.Health = tonumber(HealthIn.Text) end end)

-- Script Utilities
local function KillScripts(destroy)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if not v:IsDescendantOf(game.CoreGui) and not v:IsDescendantOf(LocalPlayer.Character) then
                if destroy then v:Destroy() else v.Disabled = true end
            end
        end
    end
end

AddToggle(NetworkTab, "Break Scripts", function() KillScripts(false) end)
AddToggle(NetworkTab, "Destroy Scripts", function() KillScripts(true) end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    if AntiKillActive and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.Health = 2000
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CanTouch = false end
    end
    
    if FlyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        hrp.Velocity = move * FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end)

-- ESP Logic
RunService.RenderStepped:Connect(function()
    if EspActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if not p.Character:FindFirstChild("MocherESP") then
                    local bg = Instance.new("BillboardGui", p.Character)
                    bg.Name = "MocherESP"
                    bg.AlwaysOnTop = true
                    bg.Size = UDim2.new(0, 100, 0, 50)
                    bg.Adornee = p.Character.Head
                    local l = Instance.new("TextLabel", bg)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundTransparency = 1
                    l.TextColor3 = GREEN
                    l.Text = p.Name
                    l.Font = Enum.Font.Code
                    -- Box ESP simulated with Highlight
                    local h = Instance.new("Highlight", p.Character)
                    h.FillTransparency = 1
                    h.OutlineColor = GREEN
                end
            end
        end
    end
end)

-- Toggle Menu Logic
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- Refresh List
local function Update()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size = UDim2.new(1, 0, 0, 30)
        b.Text = p.DisplayName
        b.BackgroundColor3 = Color3.fromRGB(30,30,30)
        b.TextColor3 = PINK
        b.Font = Enum.Font.Code
        b.MouseButton1Click:Connect(function() TargetPlayer = p end)
    end
end
Update()
Players.PlayerAdded:Connect(Update)
Players.PlayerRemoving:Connect(Update)

Tabs["Player"].F.Visible = true
Tabs["Player"].B.TextColor3 = PINK
