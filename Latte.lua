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
ScreenGui.Name = "Latte_Stable_v22"

local PINK, BLUE, WHITE = Color3.fromRGB(255, 105, 180), Color3.fromRGB(0, 191, 255), Color3.fromRGB(255, 255, 255)
local BG = Color3.fromRGB(15, 15, 15)

local State = {
    Aimbot = false, Esp = false, AntiKill = false, Fly = false, InfJump = false,
    NoClip = false, AntiKick = false, Spin = false, Target = nil, FlySpeed = 70
}

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 600, 0, 400), UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel = BG, 0
Instance.new("UICorner", MainFrame)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 140, 1, 0), Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", MainFrame)
Container.Position, Container.Size, Container.BackgroundTransparency = UDim2.new(0, 150, 0, 10), UDim2.new(1, -160, 1, -20), 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size, b.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
    b.Position = UDim2.new(0, 0, 0, #Sidebar:GetChildren() * 40 - 40)
    b.Text, b.Font, b.TextColor3 = "  " .. name, Enum.Font.Code, Color3.new(0.6, 0.6, 0.6)
    b.TextXAlignment = Enum.TextXAlignment.Left
    
    local f = Instance.new("ScrollingFrame", Container)
    f.Size, f.BackgroundTransparency, f.Visible = UDim2.new(1, 0, 1, 0), 1, false
    f.ScrollBarThickness, f.CanvasSize = 0, UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    
    Tabs[name] = {B = b, F = f}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.F.Visible, t.B.TextColor3 = false, Color3.new(0.6, 0.6, 0.6) end
        f.Visible, b.TextColor3 = true, PINK
    end)
    return f
end

local PlayerTab = CreateTab("Player")
local CombatTab = CreateTab("Combat")
local VisualsTab = CreateTab("Visuals")

local function AddToggle(parent, txt, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size, b.BackgroundColor3 = UDim2.new(1, -10, 0, 35), Color3.fromRGB(30, 30, 30)
    b.Text, b.Font, b.TextColor3 = "  " .. txt, Enum.Font.Code, WHITE
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        b.BackgroundColor3 = State[key] and PINK or Color3.fromRGB(30, 30, 30)
        if cb then cb(State[key]) end
    end)
end

AddToggle(PlayerTab, "Anti-Kill", "AntiKill")
AddToggle(PlayerTab, "Fly", "Fly")
AddToggle(PlayerTab, "NoClip", "NoClip")
AddToggle(CombatTab, "Aimbot", "Aimbot")
AddToggle(VisualsTab, "ESP", "Esp")

RunService.RenderStepped:Connect(function()
    if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("L_Vel") or Instance.new("BodyVelocity", hrp)
        local bg = hrp:FindFirstChild("L_Gyr") or Instance.new("BodyGyro", hrp)
        bv.Name, bg.Name = "L_Vel", "L_Gyr"
        bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = Camera.CFrame
        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        bv.Velocity = move * State.FlySpeed
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("L_Vel") then LocalPlayer.Character.HumanoidRootPart.L_Vel:Destroy() end
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("L_Gyr") then LocalPlayer.Character.HumanoidRootPart.L_Gyr:Destroy() end
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
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character.Head.Position), 0.1) end
    end

    if State.Esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character:FindFirstChild("LatteESP") or Instance.new("Highlight", p.Character)
                h.Name, h.FillTransparency, h.OutlineColor = "LatteESP", 1, PINK
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LatteESP") then p.Character.LatteESP:Destroy() end end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiKill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        if h.Health < 100 then h.Health = 100 end
    end
    if State.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

UserInputService.InputBegan:Connect(function(i) 
    if i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end 
end)

Tabs["Player"].F.Visible, Tabs["Player"].B.TextColor3 = true, PINK
