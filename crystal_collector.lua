-- Load the Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the Window
local Window = Rayfield:CreateWindow({
    Name = "Crystal Collector Hub",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "Crystal Collector",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil, -- Custom folder for your hub/game
        FileName = "CrystalCollectorConfig"
    },
    KeySystem = false, -- No key system
})

-- Create a Tab
local Tab = Window:CreateTab("Main", "rewind") -- Title and Icon

-- Create a Section
local Section = Tab:CreateSection("Crystal Collection")

-- State Variables
local collecting = false
local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Define the mine area remote event
local RequestWorld = game:GetService("ReplicatedStorage").Network.RequestWorld:FireServer("Mine")

-- Function to collect crystals
local function collectCrystal(crystal)
    if rootPart and (crystal:IsA("BasePart") or crystal:IsA("MeshPart")) then
        print("Collecting Crystal:", crystal:GetFullName(), "Position:", crystal.Position)
        rootPart.CFrame = crystal.CFrame + Vector3.new(0, 3, 0) -- Offset slightly above
    end
end

-- Get the Crystals folder dynamically
local function getCrystalsFolder()
    if game.Workspace:FindFirstChild("Other") then
        local otherFolder = game.Workspace.Other
        if otherFolder:FindFirstChild("Crystals") then
            return otherFolder.Crystals
        end
    end
    return nil  -- Return nil if no Crystals folder is found
end

-- Crystal collection loop
local function startCollecting()
    while collecting do
        local crystalsFolder = getCrystalsFolder()  -- Get Crystals folder
        if crystalsFolder then
            -- Collect existing crystals
            for _, obj in pairs(crystalsFolder:GetDescendants()) do
                collectCrystal(obj)
            end
        end
        wait(0.1) -- Small delay
    end
end

-- Monitor newly spawned crystals
local function setupCrystalMonitor()
    local crystalsFolder = getCrystalsFolder()
    if crystalsFolder then
        crystalsFolder.DescendantAdded:Connect(function(newCrystal)
            if collecting then
                print("New Crystal Spawned:", newCrystal:GetFullName())
                collectCrystal(newCrystal)
            end
        end)
    else
        print("Crystals folder not found in the current area.")
    end
end

-- Function to teleport to the mine area using the remote event
local function teleportToMineArea()
    print("Teleporting to Mine area...")
    RequestWorld
end

setupCrystalMonitor() -- Set up monitoring for new crystals

-- Add a Toggle to the GUI
local Toggle = Tab:CreateToggle({
    Name = "Enable Crystal Collector",
    CurrentValue = false,
    Flag = "CrystalCollectorToggle", -- Unique identifier
    Callback = function(Value)
        collecting = Value
        if collecting then
            -- Check if we're in the right area
            local currentPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            -- You can replace the check below with a specific condition if needed
            -- If the player isn't in the mine, teleport them
            if not game.Workspace:FindFirstChild("Other") or not game.Workspace.Other:FindFirstChild("Crystals") then
                teleportToMineArea()  -- Teleport to the mine area
                wait(2)  -- Wait for teleportation to complete (adjust as necessary)
            end
            print("Crystal collection started.")
            coroutine.wrap(startCollecting)() -- Start collecting in a coroutine
        else
            print("Crystal collection stopped.")
        end
    end,
})

-- Notify user when the script loads
Rayfield:Notify({
    Title = "Crystal Collector Loaded",
    Content = "Use the toggle to enable/disable crystal collection.",
    Duration = 6.5,
    Image = "rewind", -- Icon for the notification
})

-- Load Configuration
Rayfield:LoadConfiguration()
