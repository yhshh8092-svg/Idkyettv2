local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- --- 1. SETTINGS ---
local Config = {
    FlyEnabled = false,
    FlySpeed = 70,
    MenuKey = Enum.KeyCode.RightShift,
    UI_Color = Color3.fromRGB(0, 170, 255)
}

-- --- 2. ADVANCED TERMINAL ---
local ConsoleGui = Instance.new("ScreenGui", PlayerGui)
local ConsoleFrame = Instance.new("Frame", ConsoleGui)
ConsoleFrame.Size = UDim2.new(0, 280, 0, 200)
ConsoleFrame.Position = UDim2.new(0, 15, 0, 15)
ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", ConsoleFrame)

local LogScroll = Instance.new("ScrollingFrame", ConsoleFrame)
LogScroll.Size = UDim2.new(1, -10, 1, -10)
LogScroll.Position = UDim2.new(0, 5, 0, 5)
LogScroll.BackgroundTransparency = 1
LogScroll.ScrollBarThickness = 2
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

local function Log(type, msg)
    local colors = {info = Color3.new(0.5,0.7,1), success = Color3.new(0.4,1,0.4), warn = Color3.new(1,0.8,0), err = Color3.new(1,0.3,0)}
    local l = Instance.new("TextLabel", LogScroll)
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.Text = string.format("[%s] %s", type:upper(), msg)
    l.TextColor3 = colors[type] or Color3.new(1, 1, 1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogScroll.UIListLayout.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, 9999)
end

-- --- 3. MAIN HUB STRUCTURE ---
local MainGui = Instance.new("ScreenGui", PlayerGui)
local Main = Instance.new("Frame", MainGui)
Main.Size = UDim2.new(0, 550, 0, 350)
Main.Position = UDim2.new(0.5, -275, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Instance.new("UICorner", Main)
Main.Active = true
Main.Draggable = true

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Instance.new("UIListLayout", Sidebar)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -150, 1, -20)
Container.Position = UDim2.new(0, 145, 0, 10)
Container.BackgroundTransparency = 1

local pages = {}
local function CreateTab(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundTransparency = 1
    b.Text = "  " .. name
    b.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    b.Font = Enum.Font.GothamBold
    b.TextXAlignment = Enum.TextXAlignment.Left
    
    b.MouseButton1Click:Connect(function()
        for _, v in pairs(pages) do v.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.new(0.5, 0.5, 0.5) end end
        p.Visible = true
        b.TextColor3 = Config.UI_Color
    end)
    pages[name] = p
    return p
end

local function AddButton(tab, text, callback)
    local btn = Instance.new("TextButton", tab)
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- --- 4. WASD FLY LOGIC ---
local function FlyLoop()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    local bv = Instance.new("BodyVelocity", root)
    local bg = Instance.new("BodyGyro", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

    RunService:BindToRenderStep("Flight", 1, function()
        if not Config.FlyEnabled then
            bv:Destroy(); bg:Destroy()
            hum.PlatformStand = false
            RunService:UnbindFromRenderStep("Flight")
            return
        end
        hum.PlatformStand = true
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        
        bv.Velocity = dir.Unit * Config.FlySpeed
        if dir == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        bg.CFrame = Camera.CFrame
    end)
end

-- --- 5. TABS & CONTENT ---
local mainTab = CreateTab("LocalPlayer")
local playerTab = CreateTab("Players")
local visTab = CreateTab("Visuals")
local myTab = CreateTab("MyScripts")

-- [[ TELEPORT TO SPAWN ]]
AddButton(mainTab, "Teleport to Spawn", function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local spawnLoc = workspace:FindFirstChildOfClass("SpawnLocation")
        if spawnLoc then
            char.HumanoidRootPart.CFrame = spawnLoc.CFrame + Vector3.new(0, 5, 0)
            Log("success", "Teleported to SpawnLocation")
        else
            char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            Log("warn", "No SpawnLocation found. Tapped to Center.")
        end
    end
end)

-- Flight Control
AddButton(mainTab, "Toggle WASD Flight", function()
    Config.FlyEnabled = not Config.FlyEnabled
    Log(Config.FlyEnabled and "success" or "warn", "Flight: " .. tostring(Config.FlyEnabled))
    if Config.FlyEnabled then FlyLoop() end
end)

AddButton(mainTab, "Speed Boost", function()
    local h = Player.Character:FindFirstChildOfClass("Humanoid")
    h.WalkSpeed = (h.WalkSpeed == 16 and 50 or 16)
    Log("info", "WalkSpeed set to " .. h.WalkSpeed)
end)

-- Player TP Logic
local function RefreshPlayers()
    for _, v in pairs(playerTab:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            AddButton(playerTab, "TP to: " .. p.DisplayName, function()
                if p.Character then 
                    Player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                    Log("success", "Teleported to " .. p.Name)
                end
            end)
        end
    end
end
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)
RefreshPlayers()

-- Visuals
AddButton(visTab, "Full Bright", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    Log("info", "Lighting Adjusted")
end)

-- MyScripts Placeholder
AddButton(myTab, "Log My Name", function()
    Log("info", "User: " .. Player.Name)
end)

-- --- 6. VISIBILITY TOGGLE ---
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Config.MenuKey then
        Main.Visible = not Main.Visible
        ConsoleFrame.Visible = Main.Visible
    end
end)

-- --- INIT ---
pages["LocalPlayer"].Visible = true
Log("success", "Phoenix Hub v9.1 Loaded. Press RightShift to hide.")
