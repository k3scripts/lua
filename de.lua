-- Enhanced script to soft unlock all weapons with a loading screen

-- Function to show a loading screen or notification
local function showLoadingScreen(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.15, 0)
    frame.Position = UDim2.new(0.35, 0, 0.425, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Unlocking Weapons..."
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Parent = frame
    
    wait(2) -- Wait for 2 seconds before removing the loading screen
    
    screenGui:Destroy()
end

-- Function to unlock all weapons for the player
local function unlockAllWeapons(player)
    -- Show the loading screen
    showLoadingScreen(player)
    
    -- Assuming 'Weapons' is the folder containing all the weapon objects
    local weaponsFolder = game.ServerStorage:FindFirstChild("Weapons")
    
    if not weaponsFolder then
        warn("Weapons folder not found in ServerStorage")
        return
    end
    
    -- Get or create the player's inventory folder
    local playerInventory = player:FindFirstChild("Inventory")
    if not playerInventory then
        playerInventory = Instance.new("Folder", player)
        playerInventory.Name = "Inventory"
    end
    
    -- Loop through all weapons and clone them to the player's inventory
    for _, weapon in pairs(weaponsFolder:GetChildren()) do
        local clonedWeapon = weapon:Clone()
        clonedWeapon.Parent = playerInventory
        print("Unlocked weapon: " .. clonedWeapon.Name)  -- Debugging output
    end
    
    -- Optionally, refresh the player's UI or inventory display
    if player:FindFirstChild("PlayerGui") then
        if player.PlayerGui:FindFirstChild("UpdateInventory") then
            player.PlayerGui.UpdateInventory:Fire()
            print("Player inventory UI updated")
        else
            warn("Inventory UI update function not found")
        end
    end
end

-- Function to handle when a player joins the game
local function onPlayerAdded(player)
    unlockAllWeapons(player)
end

-- Connect the function to the PlayerAdded event
game.Players.PlayerAdded:Connect(onPlayerAdded)

-- Also unlock weapons for players who are already in the game
for _, player in pairs(game.Players:GetPlayers()) do
    unlockAllWeapons(player)
end
