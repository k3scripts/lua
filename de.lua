-- Create the ScreenGUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExploitGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

-- Create the Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 510, 0, 300)
mainFrame.Position = UDim2.new(0.5, -255, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Create the Top Bar Frame
local topBarFrame = Instance.new("Frame")
topBarFrame.Name = "TopBarFrame"
topBarFrame.Size = UDim2.new(1, 0, 0, 50)
topBarFrame.Position = UDim2.new(0, 0, 0, 0)
topBarFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
topBarFrame.Parent = mainFrame

-- Add the Title Label to Top Bar
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0, 150, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "NoorHub"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBarFrame

-- Create the Tab Buttons for Sections
local sections = {"Weapon", "Gunmods", "Fun", "Player", "Farming"}
local buttons = {}
local pages = {}  -- Store the pages here

local remainingWidth = 510 - 160
local buttonWidth = math.floor(remainingWidth / #sections)
local usedWidth = buttonWidth * #sections
local extraSpace = remainingWidth - usedWidth

for i, section in ipairs(sections) do
    local button = Instance.new("TextButton")
    button.Name = section .. "Button"
    if i == #sections then
        buttonWidth = buttonWidth + extraSpace
    end
    button.Size = UDim2.new(0, buttonWidth, 1, 0)
    button.Position = UDim2.new(0, 160 + (i - 1) * buttonWidth, 0, 0)
    button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    button.Text = section
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = topBarFrame
    buttons[section] = button

    -- Create a page for each section
    local page = Instance.new("Frame")
    page.Name = section .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false  -- All pages are hidden by default
    page.Parent = mainFrame
    pages[section] = page

    -- Functionality to switch pages
    button.MouseButton1Click:Connect(function()
        -- Hide all pages
        for _, p in pairs(pages) do
            p.Visible = false
        end
        -- Show the selected page
        pages[section].Visible = true
    end)
end

-- Weapon Page Content
local weaponPage = pages["Weapon"]

-- Aimbot Toggle
local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Name = "AimbotToggle"
aimbotToggle.Size = UDim2.new(0, 200, 0, 40)
aimbotToggle.Position = UDim2.new(0, 10, 0, 80)  -- Lowered position
aimbotToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.Font = Enum.Font.Gotham
aimbotToggle.TextSize = 14
aimbotToggle.TextColor3 = Color3.new(1, 1, 1)
aimbotToggle.Parent = weaponPage

-- ESP Toggle
local espToggle = Instance.new("TextButton")
espToggle.Name = "ESPToggle"
espToggle.Size = UDim2.new(0, 200, 0, 40)
espToggle.Position = UDim2.new(0, 10, 0, 140)  -- Lowered position
espToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
espToggle.Text = "ESP: OFF"
espToggle.Font = Enum.Font.Gotham
espToggle.TextSize = 14
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Parent = weaponPage

-- Toggle GUI visibility with Right Shift
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Global variables for cheats
local aimbotEnabled = false
local espEnabled = false

-- Refined Aimbot Functionality
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local aimbotEnabled = false
local isHolding = false

-- Raycasting parameters setup
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

-- Function to check if the target is visible using raycasting
local function isTargetVisible(target)
    raycastParams.FilterDescendantsInstances = {localPlayer.Character, target.Parent}
    local origin = camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    local rayResult = workspace:Raycast(origin, direction, raycastParams)

    return rayResult == nil or rayResult.Instance:IsDescendantOf(target.Parent)
end

-- Function to find the closest visible target's head
local function findClosestVisibleTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)

            if onScreen and isTargetVisible(head) then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = head
                end
            end
        end
    end

    return closestTarget
end

-- Aimbot logic to instantly snap to the target's head
local function aimAt(target)
    if target then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

-- Function to update Aimbot when holding left click
local function updateAimbot()
    if isHolding and aimbotEnabled then
        local target = findClosestVisibleTarget()
        aimAt(target)
    end
end

-- Detect when the left mouse button is pressed and released
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimbotEnabled then
        isHolding = true
        updateAimbot()  -- Perform an initial aim as soon as the button is pressed
        runService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value, updateAimbot)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHolding = false
        runService:UnbindFromRenderStep("Aimbot")
    end
end)

-- Aimbot Toggle Button Functionality
aimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotToggle.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

-- Refined ESP Functionality
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local espEnabled = false

-- Store Highlight objects and nametags
local chams = {}
local nametags = {}

-- Function to create or get a Highlight instance
local function createHighlight(player)
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    chams[player] = highlight

    -- Create a nametag
    local head = player.Character:FindFirstChild("Head")
    if head then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Adornee = head
        nameTag.Size = UDim2.new(0, 80, 0, 30) -- Smaller size
        nameTag.StudsOffset = Vector3.new(0, 2.5, 0) -- Closer to the head
        nameTag.AlwaysOnTop = true
        nameTag.Parent = head

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextScaled = true
        nameLabel.TextStrokeTransparency = 0  -- Black outline
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = nameTag

        nametags[player] = nameTag
    end
end

-- Function to clear all ESP highlights and nametags
local function clearESP()
    for _, highlight in pairs(chams) do
        if highlight.Parent then
            highlight:Destroy()
        end
    end
    chams = {}

    for _, nametag in pairs(nametags) do
        if nametag.Parent then
            nametag:Destroy()
        end
    end
    nametags = {}
end

-- Function to update ESP
local function updateESP()
    clearESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createHighlight(player)
        end
    end
end

-- Ensure ESP stays active even after respawn
local function onCharacterAdded(character)
    if espEnabled then
        updateESP()
    end
end

-- Toggle ESP function
local function toggleESP()
    if espEnabled then
        runService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, updateESP)
    else
        runService:UnbindFromRenderStep("ESPUpdate")
        clearESP()
    end
end

-- ESP Toggle Button Functionality
espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    toggleESP()
end)

-- Listen for respawns to reapply ESP
localPlayer.CharacterAdded:Connect(onCharacterAdded)
