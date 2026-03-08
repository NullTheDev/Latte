local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_Final"

-- Themes
local PINK = Color3.fromRGB(255, 105, 180)
local BLUE = Color3.fromRGB(0, 191, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local GREEN = Color3.fromRGB(0, 255, 0)
local BG = Color3.fromRGB(15, 15, 15)

-- State Logic
local MenuVisible, AimbotActive, EspActive = true, false, false
local AntiKill, FlyActive, InfJump = false, false, false
local SpinActive, TargetPlayer = false, nil
local FlySpeed, Smoothing = 50, 0.1

-- Watermark (Middle Top)
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0, 300, 0, 40)
Watermark.Position = UDim2.new(0.5, -150, 0, 15)
Watermark.BackgroundTransparency = 1
Watermark.Text = "Latte | NullTheDev"
Watermark.Font = Enum.Font.Code
Watermark.TextSize = 22
Watermark.TextColor3 = WHITE -- Must be white for gradient to work

local Grad = Instance.new("UIGradient", Watermark)
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PINK),
    ColorSequenceKeypoint.new(0.33, BLUE),
    ColorSequenceKeypoint.new(0.66, WHITE),
    ColorSequenceKeypoint.new(1, PINK)
})

-- Main UI
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 480)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame)

-- Draggable
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 160, 0, 10)
Container.Size = UDim2.new(1, -380, 1, -20)
Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size, b.BackgroundTransparency = UDim2.new(1, 0, 0, 35), 1
    b.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 35 - 35)
    b.Text, b.Font, b.TextColor3 = "  " .. name, Enum.Font.Code, Color3.new(0.5, 0.5, 0.5)
    b.TextXAlignment = Enum.TextXAlignment.Left
    
    local f = Instance.new("ScrollingFrame", Container)
    f.Size, f.BackgroundTransparency, f.Visible = UDim2.new(1, 0, 1, 0), 1, false
    f.ScrollBarThickness, f.CanvasSize = 2, UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    
    Tabs[name] = {B = b, F = f}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible = false t.B.TextColor3 = Color3.new(0.5, 0.5, 0.5) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

-- Integrated Player List (Bottom Logic)
local ListFrame = Instance.new("Frame", MainFrame)
ListFrame.Size, ListFrame.Position = UDim2.new(0, 200, 1, 0), UDim2.new(1, -200, 0, 0)
ListFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", ListFrame)

local PScroll = Instance.new("ScrollingFrame", ListFrame)
PScroll.Size, PScroll.Position, PScroll.BackgroundTransparency = UDim2.new(1, -10, 0.7, 0), UDim2.new(0, 5, 0, 5), 1
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 5)

local ActionArea = Instance.new("Frame", ListFrame)
ActionArea.Size, ActionArea.Position, ActionArea.BackgroundTransparency = UDim2.new(1, -10, 0.28, 0), UDim2.new(0, 5, 0.71, 0), 1
Instance.new("UIListLayout", ActionArea).Padding = UDim.new(0, 4)

local function AddAction(txt, cb)
    local b = Instance.new("TextButton", ActionArea)
    b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, 0, 0, 25), Color3.fromRGB(30, 30, 30), txt
    b.TextColor3, b.Font = PINK, Enum.Font.Code
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

-- Tabs
local PlayerTab = CreateTab("Player")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local NetworkTab = CreateTab("Network")

-- UI Components
local function AddToggle(parent, txt, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3 = UDim2.new(1, -10, 0, 32), Color3.fromRGB(25, 25, 25)
    b.Text, b.Font, b.TextColor3 = "  " .. txt, Enum.Font.Code, Color3.new(0.8, 0.8, 0.8)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = state and PINK or Color3.fromRGB(25, 25, 25)}):Play()
        cb(state)
    end)
end

-- Player Modules
AddToggle(PlayerTab, "Anti-Kill (Rig Shield)", function(s) AntiKill = s end)
AddToggle(PlayerTab, "Dynamic Fly", function(s) FlyActive = s end)
AddToggle(PlayerTab, "Infinite Jump", function(s) InfJump = s end)
AddToggle(PlayerTab, "Spin Bot", function(s) SpinActive = s end)

-- Combat Modules
AddToggle(CombatTab, "Smoothed Aimbot", function(s) AimbotActive = s end)
local HealthBox = Instance.new("TextBox", CombatTab)
HealthBox.Size, HealthBox.BackgroundColor3 = UDim2.new(1, -10, 0, 32), Color3.fromRGB(25, 25, 25)
HealthBox.PlaceholderText, HealthBox.TextColor3, HealthBox.Font = "Set Health (Enter)", WHITE, Enum.Font.Code
Instance.new("UICorner", HealthBox)
HealthBox.FocusLost:Connect(function(e) if e and tonumber(HealthBox.Text) then LocalPlayer.Character.Humanoid.Health = tonumber(HealthBox.Text) end end)

-- Visuals
AddToggle(VisualsTab, "Gradient ESP", function(s) 
    EspActive = s 
    if not s then for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LatteESP") then p.Character.LatteESP:Destroy() end end end
end)

-- Network (The Fixed Break/Destroy)
AddAction("Teleport To", function() if TargetPlayer and TargetPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end end)

local function ScriptUtility(mode)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if not v:IsDescendantOf(game.CoreGui) and not v:IsDescendantOf(LocalPlayer.Character) and v.Name ~= "Animate" then
                if mode == "Destroy" then v:Destroy() else v.Disabled = true end
            end
        end
    end
end

AddToggle(NetworkTab, "Break Scripts", function(s) ScriptUtility("Break") end)
AddToggle(NetworkTab, "Destroy Scripts", function(s) ScriptUtility("Destroy") end)

-- Loops
RunService.Heartbeat:Connect(function()
    if AntiKill and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.Health = 2000
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CanTouch = false end
    end
    if FlyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = (UserInputService:IsKeyDown(Enum.KeyCode.W) and Camera.CFrame.LookVector or Vector3.new(0,0.1,0)) * FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
    if SpinActive and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
    end
end)

UserInputService.JumpRequest:Connect(function() if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

-- Final Polish
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)

local function RefreshList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, 0, 0, 30), Color3.fromRGB(20, 20, 20), p.DisplayName
        b.TextColor3, b.Font = PINK, Enum.Font.Code
        b.MouseButton1Click:Connect(function() TargetPlayer = p end)
    end
end
RefreshList()
Players.PlayerAdded:Connect(RefreshList)
Players.PlayerRemoving:Connect(RefreshList)

Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
