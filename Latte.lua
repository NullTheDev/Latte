local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Old Version Purge
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:match("Latte") or v.Name:match("Mocher")) then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Latte_v19_Final"

-- Colors
local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local LAVENDER, RED = Color3.fromRGB(230, 190, 255), Color3.fromRGB(255, 50, 50)
local BG = Color3.fromRGB(12, 12, 12)

-- Global State
local State = {
    Aimbot = false, Esp = false, AntiKill = false, 
    Fly = false, InfJump = false, ServerPos = false,
    NoClip = false, Spin = false, Target = nil,
    GodMode = false, AutoRevive = false,
    FlySpeed = 50, WalkSpeed = 16
}

-- Watermark (Middle Top)
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size, Watermark.Position = UDim2.new(0, 300, 0, 40), UDim2.new(0.5, -150, 0, 15)
Watermark.BackgroundTransparency, Watermark.Text = 1, "Latte | NullTheDev"
Watermark.Font, Watermark.TextSize, Watermark.TextColor3 = Enum.Font.Code, 22, WHITE
local WGrad = Instance.new("UIGradient", Watermark)
WGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})

-- Main Frame & Animated Border
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
RunService.RenderStepped:Connect(function() BGrad.Rotation = BGrad.Rotation + 2 end)

-- Smooth Dragging
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Sidebar
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
    f.ScrollBarThickness, f.CanvasSize = 2, UDim2.new(0, 0, 4, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    
    Tabs[name] = {B = b, F = f}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.5, 0.5, 0.5) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

local PlayerTab, CombatTab, VisualsTab, NetworkTab = CreateTab("Movement"), CreateTab("Combat"), CreateTab("Visuals"), CreateTab("Utilities")

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

-- MOVEMENT
AddToggle(PlayerTab, "Omni-Directional Flight", "Fly")
AddToggle(PlayerTab, "Zero-Gravity Jump", "InfJump")
AddToggle(PlayerTab, "Phase Shift (NoClip)", "NoClip")
AddToggle(PlayerTab, "Centrifuge (Spin Bot)", "Spin")
AddToggle(PlayerTab, "Instant Momentum", nil, function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)

-- COMBAT
AddToggle(CombatTab, "Predictive Aimbot", "Aimbot")
AddToggle(CombatTab, "Fortress Defense (God)", "GodMode")
AddToggle(CombatTab, "Instant Resuscitation", "AutoRevive")
local HealthBox = Instance.new("TextBox", CombatTab)
HealthBox.Size, HealthBox.BackgroundColor3 = UDim2.new(1, -10, 0, 32), Color3.fromRGB(20, 20, 20)
HealthBox.PlaceholderText, HealthBox.TextColor3, HealthBox.Font = "Inject Vitality (Health Int)", WHITE, Enum.Font.Code
HealthBox.FocusLost:Connect(function(e) if e and tonumber(HealthBox.Text) then LocalPlayer.Character.Humanoid.Health = tonumber(HealthBox.Text) end end)

-- VISUALS
AddToggle(VisualsTab, "Spectrum ESP", "Esp")
AddToggle(VisualsTab, "Network Ghost (Server Pos)", "ServerPos")
AddToggle(VisualsTab, "Full Brightness", nil, function(s) game:GetService("Lighting").Brightness = s and 10 or 2 end)

-- UTILITIES
AddToggle(NetworkTab, "Logic Fracture (Break)", "Break", function() for _,v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v.Disabled = true end end end)
AddToggle(NetworkTab, "Total Deletion (Destroy)", "Destroy", function() for _,v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v:Destroy() end end end)
AddToggle(NetworkTab, "Clear Character Bloat", nil, function() for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end)

-- Core Loops
RunService.RenderStepped:Connect(function()
    -- Fly Engine Fix
    if State.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("LatteV") or Instance.new("BodyVelocity", hrp)
        local bg = hrp:FindFirstChild("LatteG") or Instance.new("BodyGyro", hrp)
        bv.Name, bg.Name, bv.maxForce, bg.maxTorque = "LatteV", "LatteG", Vector3.new(9e9,9e9,9e9), Vector3.new(9e9,9e9,9e9)
        bg.CFrame = Camera.CFrame
        
        local move = Vector3.new(0, 0.1, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        
        bv.Velocity = move * State.FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    elseif LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("LatteV") then
        LocalPlayer.Character.HumanoidRootPart.LatteV:Destroy()
        LocalPlayer.Character.HumanoidRootPart.LatteG:Destroy()
    end

    -- Aimbot & ESP (Synced Gradient)
    if State.Esp then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character:FindFirstChild("LatteESP") or Instance.new("Highlight", p.Character)
                h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, PINK
                if not h:FindFirstChild("UIGradient") then
                    local g = Instance.new("UIGradient", h)
                    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, PINK), ColorSequenceKeypoint.new(0.5, BLUE), ColorSequenceKeypoint.new(1, PINK)})
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        
        -- Anti-Kill & Auto-Revive
        if State.GodMode then hum.Health = hum.MaxHealth end
        if State.AutoRevive and hum.Health <= 0 then
            LocalPlayer:LoadCharacter() -- Instant Respawn
            task.wait(0.1)
            Instance.new("ForceField", LocalPlayer.Character).Visible = true -- Protection Bubble
        end
        
        if State.NoClip then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)
UserInputService.JumpRequest:Connect(function() if State.InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

Tabs["Movement"].F.Visible, Tabs["Movement"].B.TextColor3 = true, PINK
