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

-- Create Sections
local Section = Tab:CreateSection("Crystal Collection")
local ButtonSection = Tab:CreateSection("Button Automation")

-- State Variables
local collecting = false
local automatingButton = false
local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Define the mine area remote event (store the RemoteEvent here)
local RequestWorld = game:GetService("ReplicatedStorage").Network:FindFirstChild("RequestWorld")

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
    if RequestWorld then
        print("Teleporting to Mine area...")
        RequestWorld:FireServer("Mine")  -- Fire the remote event to teleport to the Mine area
    else
        print("Error: RequestWorld remote event not found.")
    end
end

setupCrystalMonitor() -- Set up monitoring for new crystals

-- Button Automation Function
local function standOnButton()
    local hitbox = workspace.Other.Buttons.Winter["2"].hitbox
    if hitbox and rootPart then
        while automatingButton do
            rootPart.CFrame = hitbox.CFrame + Vector3.new(0, 3, 0) -- Position above the hitbox
            wait(0.1) -- Adjust the delay as needed
        end
    else
        print("Button hitbox or HumanoidRootPart not found.")
    end
end

-- Add Toggle for Crystal Collector
Tab:CreateToggle({
    Name = "Enable Crystal Collector",
    CurrentValue = false,
    Flag = "CrystalCollectorToggle", -- Unique identifier
    Callback = function(Value)
        collecting = Value
        if collecting then
            -- Check if we're in the right area
            local currentPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            -- If the player isn't in the mine, teleport them
            if not game.Workspace:FindFirstChild("Other") or not game.Workspace.Other:FindFirstChild("Crystals") then
                teleportToMineArea()  -- Teleport to the mine area
                wait(5)  -- Wait for teleportation to complete (increased time)
                -- Check if we are in the mine area after teleporting
                if game.Workspace:FindFirstChild("Other") and game.Workspace.Other:FindFirstChild("Crystals") then
                    print("Successfully teleported to the Mine!")
                else
                    print("Failed to teleport to the Mine.")
                end
            end
            print("Crystal collection started.")
            coroutine.wrap(startCollecting)() -- Start collecting in a coroutine
        else
            print("Crystal collection stopped.")
        end
    end,
})

-- Add Toggle for Button Automation
Tab:CreateToggle({
    Name = "Enable Button Automation",
    CurrentValue = false,
    Flag = "ButtonAutomationToggle", -- Unique identifier
    Callback = function(Value)
        automatingButton = Value
        if automatingButton then
            print("Button automation started.")
            coroutine.wrap(standOnButton)() -- Start button automation
        else
            print("Button automation stopped.")
        end
    end,
})

-- Notify user when the script loads
Rayfield:Notify({
    Title = "Crystal Collector Loaded",
    Content = "Use the toggles to enable/disable crystal collection and button automation.",
    Duration = 6.5,
    Image = "rewind", -- Icon for the notification
})

-- Load Configuration
Rayfield:LoadConfiguration()
