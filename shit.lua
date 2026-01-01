-- [[ CONFIGURATION ]]
local Config = {
    Title = "Phoenix Hub | Key System",
    VerificationURL = "https://luarmor.org/?verify=1&key=",
    GetKeyURL = "https://luarmor.org/",
    MainScriptURL = "https://raw.githubusercontent.com/egor2078f/Lurkv3/refs/heads/main/main.lua",
    AccentColor = Color3.fromRGB(34, 197, 94), -- Green
    BgColor = Color3.fromRGB(15, 23, 42)
}

-- [[ SERVICES ]]
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- [[ UI CONSTRUCTOR ]]
local function createKeyUI()
    local UI = {}
    
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "ModernKeySystem"
    UI.ScreenGui.Parent = CoreGui
    
    -- Main Window
    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Size = UDim2.new(0, 320, 0, 240)
    UI.MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
    UI.MainFrame.BackgroundColor3 = Config.BgColor
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Parent = UI.ScreenGui
    
    Instance.new("UICorner", UI.MainFrame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", UI.MainFrame)
    Stroke.Color = Color3.fromRGB(30, 41, 59)
    Stroke.Thickness = 2

    -- Title Bar
    UI.Title = Instance.new("TextLabel")
    UI.Title.Size = UDim2.new(1, 0, 0, 40)
    UI.Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    UI.Title.Text = Config.Title
    UI.Title.TextColor3 = Color3.new(1, 1, 1)
    UI.Title.Font = Enum.Font.GothamBold
    UI.Title.TextSize = 16
    UI.Title.Parent = UI.MainFrame
    Instance.new("UICorner", UI.Title).CornerRadius = UDim.new(0, 8)

    -- Input Box
    UI.KeyInput = Instance.new("TextBox")
    UI.KeyInput.Size = UDim2.new(0, 260, 0, 40)
    UI.KeyInput.Position = UDim2.new(0.5, -130, 0.35, 0)
    UI.KeyInput.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    UI.KeyInput.PlaceholderText = "Enter License Key..."
    UI.KeyInput.Text = ""
    UI.KeyInput.TextColor3 = Color3.new(1, 1, 1)
    UI.KeyInput.Font = Enum.Font.Gotham
    UI.KeyInput.Parent = UI.MainFrame
    Instance.new("UICorner", UI.KeyInput).CornerRadius = UDim.new(0, 6)

    -- Buttons Helper
    local function createButton(name, text, pos, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 125, 0, 35)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = UI.MainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    UI.Submit = createButton("Submit", "Submit Key", UDim2.new(0.5, 5, 0.65, 0), Config.AccentColor)
    UI.GetKey = createButton("GetKey", "Get Key", UDim2.new(0.5, -130, 0.65, 0), Color3.fromRGB(51, 65, 85))

    -- Status Label
    UI.Status = Instance.new("TextLabel")
    UI.Status.Size = UDim2.new(1, -40, 0, 20)
    UI.Status.Position = UDim2.new(0, 20, 0.85, 0)
    UI.Status.BackgroundTransparency = 1
    UI.Status.Text = "Awaiting input..."
    UI.Status.TextColor3 = Color3.fromRGB(148, 163, 184)
    UI.Status.Font = Enum.Font.Gotham
    UI.Status.TextSize = 12
    UI.Status.Parent = UI.MainFrame

    return UI
end

-- [[ LOGIC ]]
local function verifyKey(key)
    local success, response = pcall(function()
        return game:HttpGet(Config.VerificationURL .. key)
    end)
    
    if success then
        return response == "valid", response
    end
    return false, "http_error"
end

local function runMainScript()
    local success, err = pcall(function()
        local Games = loadstring(game:HttpGet(Config.MainScriptURL, true))()
        if type(Games) == "table" and Games[game.PlaceId] then
            loadstring(game:HttpGet(Games[game.PlaceId]))()
        end
    end)
    if not success then warn("Main script error: " .. tostring(err)) end
end

local function init()
    local ui = createKeyUI()
    
    ui.GetKey.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(Config.GetKeyURL)
            ui.Status.Text = "Link copied to clipboard!"
            ui.Status.TextColor3 = Color3.fromRGB(59, 130, 246)
        else
            ui.Status.Text = "Please visit: " .. Config.GetKeyURL
        end
    end)
    
    ui.Submit.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text
        if key == "" then
            ui.Status.Text = "Input cannot be empty!"
            ui.Status.TextColor3 = Color3.fromRGB(239, 68, 68)
            return
        end

        ui.Status.Text = "Verifying..."
        ui.Status.TextColor3 = Color3.new(1, 1, 1)

        task.spawn(function()
            local success, status = verifyKey(key)
            if success then
                ui.Status.Text = "Success! Loading..."
                ui.Status.TextColor3 = Color3.fromRGB(34, 197, 94)
                task.wait(1)
                ui.ScreenGui:Destroy()
                runMainScript()
            else
                ui.Status.Text = "Verification failed: " .. (status or "Invalid")
                ui.Status.TextColor3 = Color3.fromRGB(239, 68, 68)
            end
        end)
    end)
end

init()
