--// Servicios
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables de Control
local Settings = {
    ESP = false,
    Tracers = false,
    Aimbot = false,
    Fly = false,
    FOVSize = 100,
    FlySpeed = 50, -- Velocidad inicial
    Visible = true
}

local ESPData = {}

--// Funciones ESP
local function CreateESP(player)
    local data = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    data.Box.Color = Color3.new(1, 0, 0)
    data.Box.Thickness = 1.5
    data.Box.Filled = false
    data.Tracer.Color = Color3.new(1, 1, 1)
    data.Tracer.Thickness = 1
    ESPData[player] = data
end

local function RemoveESP(player)
    if ESPData[player] then
        ESPData[player].Box:Remove()
        ESPData[player].Tracer:Remove()
        ESPData[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--// Interfaz GUI: Enanito_PR
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local UIListLayout = Instance.new("UIListLayout", MainFrame)
local UICorner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel", MainFrame)

MainFrame.Size = UDim2.new(0, 200, 0, 350)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 8)

Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Enanito_PR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(settingKey, textOn, textOff, colorOn)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = textOff
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = Settings[settingKey] and textOn or textOff
        btn.BackgroundColor3 = Settings[settingKey] and colorOn or Color3.fromRGB(45, 45, 45)
    end)
end

-- Botones
CreateButton("ESP", "ESP: ON", "ESP: OFF", Color3.fromRGB(0, 120, 255))
CreateButton("Tracers", "Tracers: ON", "Tracers: OFF", Color3.fromRGB(0, 120, 255))
CreateButton("Aimbot", "Aimbot: ON", "Aimbot: OFF", Color3.fromRGB(255, 0, 0))
CreateButton("Fly", "Vuelo: ON", "Vuelo: OFF", Color3.fromRGB(0, 200, 100))

-- Input para FOV
local FOVInput = Instance.new("TextBox", MainFrame)
FOVInput.Size = UDim2.new(0, 180, 0, 30)
FOVInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FOVInput.PlaceholderText = "FOV Size: " .. Settings.FOVSize
FOVInput.Text = ""
FOVInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVInput)
FOVInput.FocusLost:Connect(function()
    Settings.FOVSize = tonumber(FOVInput.Text) or Settings.FOVSize
    FOVInput.PlaceholderText = "FOV Size: " .. Settings.FOVSize
    FOVInput.Text = ""
end)

-- Input para Fly Speed
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(0, 180, 0, 30)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedInput.PlaceholderText = "Fly Speed: " .. Settings.FlySpeed
SpeedInput.Text = ""
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedInput)
SpeedInput.FocusLost:Connect(function()
    Settings.FlySpeed = tonumber(SpeedInput.Text) or Settings.FlySpeed
    SpeedInput.PlaceholderText = "Fly Speed: " .. Settings.FlySpeed
    SpeedInput.Text = ""
end)

-- Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.5

-- Bucle Principal
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Settings.Aimbot 

    -- Lógica de Vuelo
    if Settings.Fly then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
            
            hrp.Velocity = moveDir * Settings.FlySpeed
            hrp.CFrame = hrp.CFrame -- Mantiene la estabilidad
        end
    end

    -- ESP & Aimbot
    for player, drawings in pairs(ESPData) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                drawings.Box.Visible = Settings.ESP
                if Settings.ESP then
                    local sizeX, sizeY = 2200 / pos.Z, 3200 / pos.Z
                    drawings.Box.Size = Vector2.new(sizeX, sizeY)
                    drawings.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                end
                drawings.Tracer.Visible = Settings.Tracers
                if Settings.Tracers then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                end
            else drawings.Box.Visible, drawings.Tracer.Visible = false, false end
        else drawings.Box.Visible, drawings.Tracer.Visible = false, false end
    end

    if Settings.Aimbot then
        local target = nil
        local shortestDistance = Settings.FOVSize
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                        if mag < shortestDistance then target = player shortestDistance = mag end
                    end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) end
    end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        Settings.Visible = not Settings.Visible
        MainFrame.Visible = Settings.Visible
    end
end)