local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Version Destructor: Find any old Latte and kill it
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:match("Latte") or v.Name:match("Mocher")) then
        v:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_v18_Final"

-- Colors & Themes
local PINK = Color3.fromRGB(255, 105, 180)
local BLUE = Color3.fromRGB(0, 191, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local LAVENDER = Color3.fromRGB(230, 190, 255)
local RED = Color3.fromRGB(255, 50, 50)
local BG = Color3.fromRGB(12, 12, 12)

-- Global State
local State = {
    Aimbot = false, Esp = false, AntiKill = false, 
    Fly = false, InfJump = false, ServerPos = false,
    NoClip = false, Speed = 16, JumpPower = 50,
    Spin = false, Target = nil
}

-- Watermark
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0, 300, 0, 40)
Watermark.Position = UDim2.new(0.5, -150, 0, 15)
Watermark.BackgroundTransparency, Watermark.Text = 1, "Latte | NullTheDev"
Watermark.Font, Watermark.TextSize, Watermark.TextColor3 = Enum.Font.Code, 22, WHITE
local WGrad = Instance.new("UIGradient", Watermark)
WGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})

-- Main Frame & Moving Border
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 620, 0, 500), UDim2.new(0.5, -310, 0.5, -250)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Border = Instance.new("Frame", MainFrame)
Border.Size, Border.Position = UDim2.new(1, 4, 1, 4), UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3, Border.ZIndex = WHITE, -1
Instance.new("UICorner", Border)
local BGrad = Instance.new("UIGradient", Border)
BGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, LAVENDER), ColorSequenceKeypoint.new(0.5, RED), ColorSequenceKeypoint.new(1, LAVENDER)})

-- Border Animation
RunService.RenderStepped:Connect(function() BGrad.Rotation = BGrad.Rotation + 2 end)

-- Draggable
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Navigation Setup
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 150, 1, 0), Color3.fromRGB(8, 8, 8)
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
    f.ScrollBarThickness, f.CanvasSize = 2, UDim2.new(0, 0, 3, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    
    Tabs[name] = {B = b, F = f}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.5, 0.5, 0.5) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

local PlayerTab, CombatTab, VisualsTab, NetworkTab = CreateTab("Player"), CreateTab("Combat"), CreateTab("Visuals"), CreateTab("Network")

-- UI Components
local function AddToggle(parent, txt, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3 = UDim2.new(1, -10, 0, 32), Color3.fromRGB(20, 20, 20)
    b.Text, b.Font, b.TextColor3 = "  " .. txt, Enum.Font.Code, Color3.new(0.8, 0.8, 0.8)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = State[key] and PINK or Color3.fromRGB(20, 20, 20)}):Play()
        if cb then cb(State[key]) end
    end)
end

-- Player List Panel
local ListPanel = Instance.new("Frame", MainFrame)
ListPanel.Size, ListPanel.Position = UDim2.new(0, 200, 1, 0), UDim2.new(1, -200, 0, 0)
ListPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", ListPanel)
local PScroll = Instance.new("ScrollingFrame", ListPanel)
PScroll.Size, PScroll.Position, PScroll.BackgroundTransparency = UDim2.new(1, -10, 0.7, 0), UDim2.new(0, 5, 0, 5), 1
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 4)

local function UpdateList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.Text, b.TextColor3 = UDim2.new(1, 0, 0, 25), p.DisplayName, PINK
        b.BackgroundColor3, b.Font = Color3.fromRGB(20, 20, 20), Enum.Font.Code
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() State.Target = p end)
    end
end

-- MODULE POPULATION
-- Player
AddToggle(PlayerTab, "Anti-Kill", "AntiKill")
AddToggle(PlayerTab, "Dynamic Fly", "Fly", function(s) if not s and LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end end end end)
AddToggle(PlayerTab, "No-Clip", "NoClip")
AddToggle(PlayerTab, "Infinite Jump", "InfJump")
AddToggle(PlayerTab, "Spin Bot", "Spin")

-- Combat
AddToggle(CombatTab, "Aimbot (RMB)", "Aimbot")
local HealthBox = Instance.new("TextBox", CombatTab)
HealthBox.Size, HealthBox.BackgroundColor3 = UDim2.new(1, -10, 0, 32), Color3.fromRGB(20, 20, 20)
HealthBox.PlaceholderText, HealthBox.TextColor3, HealthBox.Font = "Set Health (Enter)", WHITE, Enum.Font.Code
HealthBox.FocusLost:Connect(function(e) if e and tonumber(HealthBox.Text) then LocalPlayer.Character.Humanoid.Health = tonumber(HealthBox.Text) end end)

-- Visuals
AddToggle(VisualsTab, "Gradient ESP", "Esp")
AddToggle(VisualsTab, "Show Server Pos", "ServerPos", function(s)
    if s and LocalPlayer.Character then
        LocalPlayer.Character.Archivable = true
        local g = LocalPlayer.Character:Clone()
        g.Name, g.Parent = "Ghost", workspace
        for _,v in pairs(g:GetDescendants()) do if v:IsA("BasePart") then v.Transparency, v.Color, v.CanCollide = 0.5, BLUE, false elseif v:IsA("LocalScript") then v:Destroy() end end
        State.Ghost = g
    elseif State.Ghost then State.Ghost:Destroy() end
end)

-- Network
local function RunScripts(d) for _,v in pairs(game:GetDescendants()) do if (v:IsA("LocalScript") or v:IsA("ModuleScript")) and not v:IsDescendantOf(game.CoreGui) and v.Name ~= "Animate" then if d then v:Destroy() else v.Disabled = true end end end end
AddToggle(NetworkTab, "Break Scripts", "Break", function() RunScripts(false) end)
AddToggle(NetworkTab, "Destroy Scripts", "Destroy", function() RunScripts(true) end)

-- Main Physics Loop
RunService.RenderStepped:Connect(function()
    if State.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("FlyV") or Instance.new("BodyVelocity", hrp)
        local bg = hrp:FindFirstChild("FlyG") or Instance.new("BodyGyro", hrp)
        bv.Name, bg.Name = "FlyV", "FlyG"
        bv.maxForce, bg.maxTorque = Vector3.new(9e9,9e9,9e9), Vector3.new(9e9,9e9,9e9)
        bg.CFrame = Camera.CFrame
        local dir = Vector3.new(0,0.1,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = -Camera.CFrame.LookVector end
        bv.Velocity = dir * 50
    end

    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, close = nil, 500
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if vis and mag < close then target, close = p, mag end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 0.1) end
    end

    if State.Esp then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local char = p.Character
                if not char:FindFirstChild("LatteESP") then
                    local h = Instance.new("Highlight", char)
                    h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, PINK
                    local g = Instance.new("UIGradient", h)
                    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiKill and LocalPlayer.Character then LocalPlayer.Character.Humanoid.Health = 2000 LocalPlayer.Character.HumanoidRootPart.CanTouch = false end
    if State.NoClip and LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if State.ServerPos and State.Ghost then State.Ghost.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)
UserInputService.JumpRequest:Connect(function() if State.InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
