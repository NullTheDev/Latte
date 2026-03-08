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
ScreenGui.Name = "Latte_Deployment_v21"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local LAVENDER, RED = Color3.fromRGB(230, 190, 255), Color3.fromRGB(255, 50, 50)
local BG = Color3.fromRGB(10, 10, 10)

local State = {
    Aimbot = false, Esp = false, AntiKill = false, 
    Fly = false, InfJump = false, ServerPos = false,
    NoClip = false, Spin = false, Target = nil,
    FlySpeed = 70, AimbotSmoothing = 0.05,
    AntiKick = true, AntiBan = true
}

local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size, Watermark.Position = UDim2.new(0, 300, 0, 40), UDim2.new(0.5, -150, 0, 15)
Watermark.BackgroundTransparency, Watermark.Text = 1, "Latte | NullTheDev"
Watermark.Font, Watermark.TextSize, Watermark.TextColor3 = Enum.Font.Code, 22, WHITE
local WGrad = Instance.new("UIGradient", Watermark)
WGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PINK),
    ColorSequenceKeypoint.new(0.5, BLUE),
    ColorSequenceKeypoint.new(1, PINK)
})

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 650, 0, 520) , UDim2.new(0.5, -325, 0.5, -260)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Border = Instance.new("Frame", MainFrame)
Border.Size, Border.Position = UDim2.new(1, 4, 1, 4), UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3, Border.ZIndex = WHITE, -1
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
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 150, 1, 0), Color3.fromRGB(5, 5, 5)
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 160, 0, 10), UDim2.new(1, -420, 1, -20), 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size, b.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
    b.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 40 - 40)
    b.Text, b.Font, b.TextColor3 = "  " .. name, Enum.Font.Code, Color3.new(0.4, 0.4, 0.4)
    b.TextXAlignment = Enum.TextXAlignment.Left
    
    local f = Instance.new("ScrollingFrame", Container)
    f.Size, f.BackgroundTransparency, f.Visible = UDim2.new(1, 0, 1, 0), 1, false
    f.ScrollBarThickness, f.CanvasSize = 0, UDim2.new(0, 0, 5, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 6)
    
    Tabs[name] = {B = b, F = f}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.4, 0.4, 0.4) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

local PlayerTab = CreateTab("Player")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")
local ProtectionsTab = CreateTab("Protections")
local NetworkTab = CreateTab("Network")

local function AddToggle(parent, txt, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3 = UDim2.new(1, -10, 0, 35), Color3.fromRGB(20, 20, 20)
    b.Text, b.Font, b.TextColor3 = "  " .. txt, Enum.Font.Code, Color3.new(0.8, 0.8, 0.8)
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        TweenService:Create(b, TweenInfo.new(0.25), {BackgroundColor3 = State[key] and PINK or Color3.fromRGB(20, 20, 20)}):Play()
        if cb then cb(State[key]) end
    end)
end

local ListPanel = Instance.new("Frame", MainFrame)
ListPanel.Size, ListPanel.Position = UDim2.new(0, 250, 1, 0), UDim2.new(1, -250, 0, 0)
ListPanel.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
Instance.new("UICorner", ListPanel)
local PScroll = Instance.new("ScrollingFrame", ListPanel)
PScroll.Size, PScroll.Position, PScroll.BackgroundTransparency = UDim2.new(1, -10, 0.95, 0), UDim2.new(0, 5, 0, 5), 1
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 5)

local function UpdateList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.Text, b.TextColor3 = UDim2.new(1, 0, 0, 28), p.DisplayName, PINK
        b.BackgroundColor3, b.Font = Color3.fromRGB(15, 15, 15), Enum.Font.Code
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() State.Target = p end)
    end
end

AddToggle(PlayerTab, "Anti-Kill", "AntiKill")
AddToggle(PlayerTab, "Fly", "Fly")
AddToggle(PlayerTab, "Infinite Jump", "InfJump")
AddToggle(PlayerTab, "NoClip", "NoClip")
AddToggle(PlayerTab, "SpinBot", "Spin")
AddToggle(PlayerTab, "Speed Hack", nil, function(s) LocalPlayer.Character.Humanoid.WalkSpeed = s and 100 or 16 end)

AddToggle(CombatTab, "Aimbot (Right-Click)", "Aimbot")
AddToggle(CombatTab, "Auto-Clicker", "AutoClick")
AddToggle(CombatTab, "Trigger Bot", "Trigger")

AddToggle(VisualsTab, "Gradient ESP", "Esp")
AddToggle(VisualsTab, "Show Server Ghost", "ServerPos")
AddToggle(VisualsTab, "Full Bright", nil, function(s) game:GetService("Lighting").Brightness = s and 10 or 2 end)

AddToggle(ProtectionsTab, "Anti-Kick Bypass", "AntiKick")
AddToggle(ProtectionsTab, "Anti-Ban Protection", "AntiBan")
AddToggle(ProtectionsTab, "AC Memory Spoofer", nil)

AddToggle(NetworkTab, "Break Scripts", nil, function() for _,v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") then v.Disabled = true end end end)
AddToggle(NetworkTab, "Destroy Scripts", nil, function() for _,v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") then v:Destroy() end end end)
AddToggle(NetworkTab, "Chat Spammer", "ChatSpam")

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if State.AntiKick and method == "Kick" then return nil end
    return old(self, ...)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    if State.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("LATTE_V") or Instance.new("BodyVelocity", hrp)
        local bg = hrp:FindFirstChild("LATTE_G") or Instance.new("BodyGyro", hrp)
        bv.Name, bg.Name = "LATTE_V", "LATTE_G"
        bv.maxForce, bg.maxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = Camera.CFrame
        local move = Vector3.new(0, 0.1, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        bv.Velocity = move * State.FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end

    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t, d = nil, 1000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local m = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if vis and m < d then t, d = p, m end
            end
        end
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character.Head.Position), State.AimbotSmoothing) end
    end

    if State.Esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character:FindFirstChild("LatteESP") or Instance.new("Highlight", p.Character)
                h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, PINK
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if State.AntiKill then
            if hum.Health < 100 then hum.Health = 100 end
            if hum.Health <= 0 then
                LocalPlayer:LoadCharacter()
                task.wait(0.1)
                Instance.new("ForceField", LocalPlayer.Character).Visible = true
            end
        end
        if State.NoClip then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if State.ChatSpam then game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Latte | NullTheDev On Top", "All") task.wait(3) end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then MainFrame.Visible = not MainFrame.Visible end end)
UserInputService.JumpRequest:Connect(function() if State.InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
