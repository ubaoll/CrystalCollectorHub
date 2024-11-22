-- Load the Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the Window
local Window = Rayfield:CreateWindow({
    Name = "Crystal Collector Hub",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "Crystal Collector + Anti-AFK + Aura Auto-Open",
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
local CollectorSection = Tab:CreateSection("Crystal Collection")
local AntiAFKSection = Tab:CreateSection("Anti-AFK")
local AuraSection = Tab:CreateSection("Aura Auto-Open")

-- State Variables
local collecting = false
local antiAFKEnabled = false
local autoAuraEnabled = false
local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Crystal Collector Functions
local function collectCrystal(crystal)
    if rootPart and (crystal:IsA("BasePart") or crystal:IsA("MeshPart")) then
        print("Collecting Crystal:", crystal:GetFullName(), "Position:", crystal.Position)
        rootPart.CFrame = crystal.CFrame + Vector3.new(0, 3, 0) -- Offset slightly above
    end
end

local function startCollecting()
    while collecting do
        -- Collect existing crystals
        for _, obj in pairs(game.Workspace.Other.Crystals:GetDescendants()) do
            collectCrystal(obj)
        end
        wait(0.1) -- Small delay
    end
end

local function setupCrystalMonitor()
    game.Workspace.Other.Crystals.DescendantAdded:Connect(function(newCrystal)
        if collecting then
            print("New Crystal Spawned:", newCrystal:GetFullName())
            collectCrystal(newCrystal)
        end
    end)
end

setupCrystalMonitor() -- Set up monitoring for new crystals

-- Anti-AFK Functionality
local VirtualUser = game:GetService("VirtualUser")

local function enableAntiAFK()
    game.Players.LocalPlayer.Idled:Connect(function()
        if antiAFKEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new()) -- Simulate right-click to prevent being kicked
            print("Anti-AFK: Simulated activity to prevent kick.")
        end
    end)
end

-- Aura Auto-Open Functions
local function openAura(button)
    if rootPart and button:IsA("BasePart") then
        print("Opening Aura Button:", button:GetFullName(), "Position:", button.Position)
        rootPart.CFrame = button.CFrame -- Move the player to the button
        wait(0.2) -- Allow time for the button to register the interaction
    end
end

local function startAutoAura()
    while autoAuraEnabled do
        -- Find and step on aura buttons
        for _, button in pairs(game.Workspace.Other.AuraButtons:GetChildren()) do
            openAura(button)
        end
        wait(0.5) -- Adjust delay to match button respawn times
    end
end

-- Create Crystal Collector Toggle
local CollectorToggle = Tab:CreateToggle({
    Name = "Enable Crystal Collector",
    CurrentValue = false,
    Flag = "CrystalCollectorToggle", -- Unique identifier
    Callback = function(Value)
        collecting = Value
        if collecting then
            print("Crystal collection started.")
            coroutine.wrap(startCollecting)() -- Start collecting in a coroutine
        else
            print("Crystal collection stopped.")
        end
    end,
})

-- Create Anti-AFK Toggle
local AntiAFKToggle = Tab:CreateToggle({
    Name = "Enable Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle", -- Unique identifier
    Callback = function(Value)
        antiAFKEnabled = Value
        if antiAFKEnabled then
            print("Anti-AFK enabled.")
            enableAntiAFK() -- Start Anti-AFK
        else
            print("Anti-AFK disabled.")
        end
    end,
})

-- Create Aura Auto-Open Toggle
local AuraToggle = Tab:CreateToggle({
    Name = "Enable Aura Auto-Open",
    CurrentValue = false,
    Flag = "AuraAutoOpenToggle", -- Unique identifier
    Callback = function(Value)
        autoAuraEnabled = Value
        if autoAuraEnabled then
            print("Aura auto-open started.")
            coroutine.wrap(startAutoAura)() -- Start aura auto-open in a coroutine
        else
            print("Aura auto-open stopped.")
        end
    end,
})

-- Notify the user about the features
Rayfield:Notify({
    Title = "Crystal Collector Hub Loaded",
    Content = "Use the toggles to enable/disable Crystal Collector, Anti-AFK, and Aura Auto-Open.",
    Duration = 6.5,
    Image = "rewind", -- Icon for the notification
})

-- Load Configuration
Rayfield:LoadConfiguration()
