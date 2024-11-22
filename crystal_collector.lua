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
local crystalSection = Tab:CreateSection("Crystal Collection")
local buttonSection = Tab:CreateSection("Button Automation")
local afkSection = Tab:CreateSection("Anti-AFK")

-- Crystal Collection Variables
local collectingCrystals = false

local function collectCrystal(crystal)
    local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if rootPart and (crystal:IsA("BasePart") or crystal:IsA("MeshPart")) then
        rootPart.CFrame = crystal.CFrame + Vector3.new(0, 3, 0)
    end
end

local function getCrystalsFolder()
    if game.Workspace:FindFirstChild("Other") then
        local otherFolder = game.Workspace.Other
        if otherFolder:FindFirstChild("Crystals") then
            return otherFolder.Crystals
        end
    end
    return nil
end

local function startCrystalCollection()
    while collectingCrystals do
        local crystalsFolder = getCrystalsFolder()
        if crystalsFolder then
            for _, obj in pairs(crystalsFolder:GetDescendants()) do
                collectCrystal(obj)
            end
        end
        wait(0.1)
    end
end

-- Button Automation Variables
local automatingButton = false

local function standOnButton()
    local hitbox = workspace.Others.Buttons.Winter["2"].hitbox
    local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if hitbox and humanoidRootPart then
        while automatingButton do
            humanoidRootPart.CFrame = hitbox.CFrame + Vector3.new(0, 3, 0)
            wait(0.1)
        end
    else
        print("Hitbox or HumanoidRootPart not found.")
    end
end

-- Anti-AFK Feature
local antiAFK = false
local function preventAFK()
    local vu = game:GetService("VirtualUser")
    game.Players.LocalPlayer.Idled:Connect(function()
        if antiAFK then
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            print("Prevented AFK kick.")
        end
    end)
end

-- Create Toggles
Tab:CreateToggle({
    Name = "Enable Crystal Collector",
    CurrentValue = false,
    Flag = "CrystalCollectorToggle",
    Callback = function(value)
        collectingCrystals = value
        if value then
            print("Crystal collection started.")
            coroutine.wrap(startCrystalCollection)()
        else
            print("Crystal collection stopped.")
        end
    end,
})

Tab:CreateToggle({
    Name = "Auto Stand on Button",
    CurrentValue = false,
    Flag = "ButtonAutomationToggle",
    Callback = function(value)
        automatingButton = value
        if value then
            print("Button automation started.")
            coroutine.wrap(standOnButton)()
        else
            print("Button automation stopped.")
        end
    end,
})

Tab:CreateToggle({
    Name = "Enable Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(value)
        antiAFK = value
        if value then
            print("Anti-AFK enabled.")
        else
            print("Anti-AFK disabled.")
        end
    end,
})

-- Initialize Anti-AFK
preventAFK()

-- Notify User
Rayfield:Notify({
    Title = "Crystal Collector Hub Loaded",
    Content = "All features are ready. Use toggles to enable/disable.",
    Duration = 6.5,
    Image = "rewind",
})

-- Load Configuration
Rayfield:LoadConfiguration()
