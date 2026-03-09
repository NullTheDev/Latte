local TweenService = game:GetService("TweenService")
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
ScreenGui.Name = "Latte_v27_Master"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local LAVENDER, RED = Color3.fromRGB(230, 190, 255), Color3.fromRGB(255, 50, 50)
local BG, SECONDARY = Color3.fromRGB(12, 12, 12), Color3.fromRGB(8, 8, 8)
local INT_LIMIT = 2147483647

local State = {
    Visible = true, Aimbot = false, Esp = false, AntiKill = false, 
    Fly = false, FlySpeed = 65, Target = nil, Bubble = false
}

-- Colors:3
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

-- I fucking hate robloxs scripting language
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

local PlayerTab = CreateTab("Main")
local VisualsTab = CreateTab("Visuals")
local TeamsTab = CreateTab("Teams")
local InventoryTab = CreateTab("Inventory")
local NetworkTab = CreateTab("Network")

-- Da Inventory
local function RefreshInventory(p)
    for _, v in pairs(Tabs["Inventory"].F:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if p and p:FindFirstChild("Backpack") then
        for _, tool in pairs(p.Backpack:GetChildren()) do
            local b = Instance.new("TextButton", Tabs["Inventory"].F)
            b.Size, b.BackgroundColor3 = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30)
            b.Text, b.TextColor3, b.Font = tool.Name, WHITE, Enum.Font.Code
            Instance.new("UICorner", b)
            
            local iGrad = Instance.new("UIGradient", b)
            iGrad.Color = GlobalGrad
            RunService.RenderStepped:Connect(function() iGrad.Offset = Vector2.new(math.sin(tick() * 3) * 0.5, 0) end)

            b.MouseButton1Click:Connect(function()
                local c = tool:Clone()
                c.Parent = LocalPlayer.Backpack
                for _, s in pairs(c:GetDescendants()) do if s:IsA("LocalScript") then s.Disabled = false end end
            end)
        end
    end
end

-- Stupid Player List
local ListPanel = Instance.new("Frame", MainFrame)
ListPanel.Size, ListPanel.Position = UDim2.new(0, 250, 1, 0), UDim2.new(1, -250, 0, 0)
ListPanel.BackgroundColor3 = SECONDARY
Instance.new("UICorner", ListPanel)

local PScroll = Instance.new("ScrollingFrame", ListPanel)
PScroll.Size, PScroll.Position, PScroll.BackgroundTransparency = UDim2.new(1, -10, 0.95, 0), UDim2.new(0, 5, 0, 5), 1
PScroll.ScrollBarThickness = 0
Instance.new("UIListLayout", PScroll).Padding = UDim.new(0, 5)

local function UpdateList()
    for _, v in pairs(PScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PScroll)
        b.Size, b.BackgroundColor3, b.TextColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(25, 25, 25), PINK
        b.Text, b.Font = p.DisplayName, Enum.Font.Code
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() State.Target = p RefreshInventory(p) end)
    end
end

local function UpdateTeams()
    for _, v in pairs(TeamsTab:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, t in pairs(Teams:GetTeams()) do
        local b = Instance.new("TextButton", TeamsTab)
        b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30), "Join " .. t.Name
        b.TextColor3, b.Font = t.TeamColor.Color, Enum.Font.Code
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() LocalPlayer.Team = t end)
    end
end

local function AddToggle(parent, text, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3, b.Text = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30), "  " .. text
    b.TextColor3, b.Font, b.TextXAlignment = WHITE, Enum.Font.Code, Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        if key then State[key] = not State[key] end
        b.BackgroundColor3 = (key and State[key]) and PINK or Color3.fromRGB(30, 30, 30)
        if cb then cb(State[key] or true) end
    end)
end

-- The Fucking Buttons
AddToggle(PlayerTab, "Anti-Kill", "AntiKill")
AddToggle(PlayerTab, "Dynamic Fly", "Fly", function(s)
    if not s and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)
AddToggle(PlayerTab, "Respawn Bubble", "Bubble")
AddToggle(PlayerTab, "Clear Inventory", nil, function()
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do v:Destroy() end
    if LocalPlayer.Character:FindFirstChildOfClass("Tool") then LocalPlayer.Character:FindFirstChildOfClass("Tool"):Destroy() end
end)

AddToggle(VisualsTab, "Gradient ESP", "Esp")

AddToggle(NetworkTab, "Break Scripts", nil, function()
    for _, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v.Disabled = true end end
end)
AddToggle(NetworkTab, "Destroy Scripts", nil, function()
    for _, v in pairs(game:GetDescendants()) do if v:IsA("LocalScript") and v.Name ~= "Animate" then v:Destroy() end end
end)
AddToggle(NetworkTab, "Delete LocalPlayer", nil, function()
    LocalPlayer:Destroy()
end)

-- REAHHHHH
RunService.Heartbeat:Connect(function()
    if State.AntiKill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.MaxHealth, h.Health = INT_LIMIT, INT_LIMIT
        if h.Health < 100 then LocalPlayer:LoadCharacter() end
    end
    
    if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local gyro = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", hrp)
        local vel = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
        gyro.maxTorque, vel.maxForce = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = Camera.CFrame
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        vel.Velocity = move * State.FlySpeed
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end

    if State.Bubble and LocalPlayer.Character then
        if not LocalPlayer.Character:FindFirstChild("ForceField") then Instance.new("ForceField", LocalPlayer.Character) end
    elseif not State.Bubble and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ForceField") then
        LocalPlayer.Character.ForceField:Destroy()
    end
end)

RunService.RenderStepped:Connect(function()
    if State.Esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("LatteESP") or Instance.new("Highlight", p.Character)
                highlight.Name, highlight.FillTransparency, highlight.OutlineColor = "LatteESP", 1, WHITE
                local g = highlight:FindFirstChild("G") or Instance.new("UIGradient", highlight)
                g.Color = GlobalGrad
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Delete then
        State.Visible = not State.Visible
        MainFrame.Visible = State.Visible
    end
end)

UpdateList()
UpdateTeams()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
Teams.ChildAdded:Connect(UpdateTeams)
Tabs["Main"].F.Visible, Tabs["Main"].B.TextColor3 = true, PINK
