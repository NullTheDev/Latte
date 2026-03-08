local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_v17"

-- Themes
local PINK = Color3.fromRGB(255, 105, 180)
local BLUE = Color3.fromRGB(0, 191, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local GREEN = Color3.fromRGB(0, 255, 0)
local BG = Color3.fromRGB(15, 15, 15)

-- State
local MenuVisible, AimbotActive, EspActive = true, false, false
local AntiKill, FlyActive, InfJump = false, false, false
local ServerPosActive, ServerClone = false, nil
local FlySpeed, Smoothing = 50, 0.08

-- Watermark (Middle Top)
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0, 300, 0, 40)
Watermark.Position = UDim2.new(0.5, -150, 0, 15)
Watermark.BackgroundTransparency = 1
Watermark.Text = "Latte | NullTheDev"
Watermark.Font = Enum.Font.Code
Watermark.TextSize = 22
Watermark.TextColor3 = WHITE

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

-- Draggable Logic
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 150, 1, 0), Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 160, 0, 10), UDim2.new(1, -380, 1, -20), 1

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
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.5, 0.5, 0.5) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

local PlayerTab, CombatTab, VisualsTab, NetworkTab = CreateTab("Player"), CreateTab("Combat"), CreateTab("Visuals"), CreateTab("Network")

-- UI Helpers
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

-- Fly & Movement Logic
local function ToggleFly(s)
    FlyActive = s
    if not s and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        for _, v in pairs(hrp:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end end
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- Server Position Logic
local function ToggleServerPos(s)
    ServerPosActive = s
    if s and LocalPlayer.Character then
        LocalPlayer.Character.Archivable = true
        ServerClone = LocalPlayer.Character:Clone()
        ServerClone.Name = "ServerGhost"
        ServerClone.Parent = workspace
        for _, v in pairs(ServerClone:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.5 v.Color = BLUE v.CanCollide = false
            elseif v:IsA("LocalScript") or v:IsA("Script") then v:Destroy() end
        end
    elseif ServerClone then ServerClone:Destroy() end
end

-- Toggles
AddToggle(PlayerTab, "Anti-Kill", function(s) AntiKill = s end)
AddToggle(PlayerTab, "Dynamic Fly", ToggleFly)
AddToggle(PlayerTab, "Infinite Jump", function(s) InfJump = s end)
AddToggle(CombatTab, "Smoothed Aimbot", function(s) AimbotActive = s end)
AddToggle(VisualsTab, "Gradient ESP", function(s) EspActive = s end)
AddToggle(VisualsTab, "Show Server Position", ToggleServerPos)

-- Script Utilities
local function ScriptUtil(mode)
    for _, v in pairs(game:GetDescendants()) do
        if (v:IsA("LocalScript") or v:IsA("ModuleScript")) and not v:IsDescendantOf(game.CoreGui) and v.Name ~= "Animate" then
            if mode == "Destroy" then v:Destroy() else v.Disabled = true end
        end
    end
end
AddToggle(NetworkTab, "Break Scripts", function() ScriptUtil("Break") end)
AddToggle(NetworkTab, "Destroy Scripts", function() ScriptUtil("Destroy") end)

-- Main Physics & Aimbot Loop
RunService.RenderStepped:Connect(function()
    if FlyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bg = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", hrp)
        local bv = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
        bg.Name, bv.Name = "FlyGyro", "FlyVel"
        bg.maxTorque, bg.P, bg.CFrame = Vector3.new(9e9, 9e9, 9e9), 9e4, Camera.CFrame
        bv.maxForce, bv.P = Vector3.new(9e9, 9e9, 9e9), 9e4
        
        local dir = Vector3.new(0,0.1,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = -Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = -Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = Camera.CFrame.RightVector end
        bv.Velocity = dir * FlySpeed
    end

    if AimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, closest = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if vis and mag < closest then target, closest = p, mag end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), Smoothing)
        end
    end

    if EspActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local char = p.Character
                if not char:FindFirstChild("LatteESP") then
                    local h = Instance.new("Highlight", char)
                    h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, PINK
                    local b = Instance.new("BillboardGui", char.Head)
                    b.Name, b.AlwaysOnTop, b.Size = "LatteName", true, UDim2.new(0,100,0,20)
                    local l = Instance.new("TextLabel", b)
                    l.Size, l.BackgroundTransparency, l.Text, l.TextColor3, l.Font = UDim2.new(1,0,1,0), 1, p.Name, PINK, Enum.Font.Code
                end
            end
        end
    elseif not EspActive then
        for _, p in pairs(Players:GetPlayers()) do if p.Character then 
            if p.Character:FindFirstChild("LatteESP") then p.Character.LatteESP:Destroy() end 
            if p.Character.Head:FindFirstChild("LatteName") then p.Character.Head.LatteName:Destroy() end
        end end
    end
end)

-- Heartbeat Logic
RunService.Heartbeat:Connect(function()
    if AntiKill and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.Health = 2000
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CanTouch = false end
    end
    if ServerPosActive and ServerClone and LocalPlayer.Character then
        ServerClone.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)
UserInputService.JumpRequest:Connect(function() if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
