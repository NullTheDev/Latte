local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

for _, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:match("Latte") or v.Name:match("Mocher")) then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_v23_Final"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local LAVENDER, RED = Color3.fromRGB(230, 190, 255), Color3.fromRGB(255, 50, 50)
local BG, SECONDARY = Color3.fromRGB(15, 15, 15), Color3.fromRGB(10, 10, 10)
local INT_LIMIT = 2147483647

local MenuVisible, AimbotActive, EspActive = true, false, false
local AntiKillActive, FlyActive = false, false
local TargetPlayer = nil
local FlySpeed = 60

local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size, Watermark.Position = UDim2.new(0, 400, 0, 40), UDim2.new(0.5, -200, 0, 15)
Watermark.BackgroundTransparency, Watermark.Text = 1, "Latte | NullTheDev"
Watermark.Font, Watermark.TextSize, Watermark.TextColor3 = Enum.Font.Code, 24, WHITE
local WGrad = Instance.new("UIGradient", Watermark)
WGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})

RunService.RenderStepped:Connect(function()
    WGrad.Offset = Vector2.new(math.sin(tick() * 2) * 0.5, 0)
end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 600, 0, 480), UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Border = Instance.new("Frame", MainFrame)
Border.Size, Border.Position, Border.ZIndex = UDim2.new(1, 4, 1, 4), UDim2.new(0, -2, 0, -2), -1
Border.BackgroundColor3 = WHITE
Instance.new("UICorner", Border)
local BGrad = Instance.new("UIGradient", Border)
BGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, LAVENDER), ColorSequenceKeypoint.new(0.5, RED), ColorSequenceKeypoint.new(1, LAVENDER)})
RunService.RenderStepped:Connect(function() BGrad.Rotation = BGrad.Rotation + 3 end)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 140, 1, 0), SECONDARY
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 150, 0, 10), UDim2.new(1, -370, 1, -20), 1

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

local PlayerTab, CombatTab, VisualsTab, NetworkTab = CreateTab("Player"), CreateTab("Combat"), CreateTab("Visuals"), CreateTab("Network")

local function AddToggle(parent, text, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30), "  " .. text
    b.TextColor3, b.Font, b.TextXAlignment = WHITE, Enum.Font.Code, Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and PINK or Color3.fromRGB(30, 30, 30)
        cb(act)
    end)
end

AddToggle(PlayerTab, "Anti-Kill (Max Health)", function(s) AntiKillActive = s end)
AddToggle(PlayerTab, "Stable Fly", function(s) 
    FlyActive = s 
    if not s and LocalPlayer.Character then
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVel") then LocalPlayer.Character.HumanoidRootPart.FlyVel:Destroy() end
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyGyro") then LocalPlayer.Character.HumanoidRootPart.FlyGyro:Destroy() end
    end
end)

AddToggle(CombatTab, "Aimbot (RMB)", function(s) AimbotActive = s end)

AddToggle(VisualsTab, "Gradient ESP (All Teams)", function(s) 
    EspActive = s 
    if not s then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LatteESP") then p.Character.LatteESP:Destroy() end
        end
    end
end)

AddToggle(NetworkTab, "Break Scripts", function() 
    for _, v in pairs(game:GetDescendants()) do 
        if v:IsA("LocalScript") and v.Name ~= "Animate" then v.Disabled = true end 
    end 
end)
AddToggle(NetworkTab, "Destroy Scripts", function() 
    for _, v in pairs(game:GetDescendants()) do 
        if v:IsA("LocalScript") and v.Name ~= "Animate" then v:Destroy() end 
    end 
end)

RunService.Heartbeat:Connect(function()
    if AntiKillActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.MaxHealth = INT_LIMIT
        h.Health = INT_LIMIT
    end
    
    if FlyActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local gyro = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", hrp)
        local vel = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
        gyro.Name, vel.Name = "FlyGyro", "FlyVel"
        gyro.maxTorque, vel.maxForce = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = Camera.CFrame
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        vel.Velocity = move * FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, dist = nil, 1000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if m < dist then target, dist = p, m end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) end
    end

    if EspActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("LatteESP") or Instance.new("Highlight", p.Character)
                highlight.Name, highlight.FillTransparency, highlight.OutlineColor = "LatteESP", 1, WHITE
                local g = highlight:FindFirstChild("G") or Instance.new("UIGradient", highlight)
                g.Name = "G"
                g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
end)

Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
