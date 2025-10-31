local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Local Window
local Window = Fluent:CreateWindow({
    Title = "Hydrageans Hub",
    SubTitle = "Auto Farm",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "badge-dollar-sign" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })

}

-- Local Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local GetItem = require(ReplicatedStorage.Shared.ItemUtility)
local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"] -- RemoteFunction 
local RunService = game:GetService("RunService")
local isHovering = false
local hoverConnection
local RFPurchaseFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]
local RFPurchaseBait = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]

-- Variables
local autofarm = false

-- Add Main Farming Section
Tabs.Main:AddSection("Auto Farm Functions")

Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(Value)
        autofarm = Value
    end
})

task.spawn(function()
    while true do
        if autofarm then
            FishingController:RequestChargeFishingRod(Vector2.new(0, 0), true)
            local guid = FishingController.GetCurrentGUID and FishingController:GetCurrentGUID()
            if guid then
                while guid == FishingController:GetCurrentGUID() do
                    FishingController:FishingMinigameClick()
                    task.wait(0.11)
                end
            end
        end
        task.wait(0.2)
    end
end)

Tabs.Main:AddSection("Selling Option")

Tabs.Main:AddSlider("SellDelay", {
    Title = "Auto Sell Delay",
    Description = "Delay between auto-sells in seconds",
    Default = 5,
    Min = 1,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        sellDelay = Value
    end
})

Tabs.Main:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Default = false,
    Callback = function(Value)
        autoSell = Value
    end
})

Tabs.Main:AddButton({
    Title = "Sell All Items",
    Description = "Instantly sell all items",
    Callback = function()
        RFSellAllItems:InvokeServer()
    end
})

task.spawn(function()
    while true do
        if autoSell then
            RFSellAllItems:InvokeServer()
            task.wait(sellDelay)
        end
        task.wait(0.1)
    end
end)


Tabs.Main:AddSection("Location Options")

Tabs.Main:AddToggle("MegalodonHover", {
    Title = "Hover at Megalodon",
    Default = false,
    Description = "Auto-teleport ",
    Callback = function(Value)
        isHovering = Value
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if Value then
                
                lastPosition = character.HumanoidRootPart.CFrame
                
                
                hoverConnection = RunService.Heartbeat:Connect(function()
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        
                        character.HumanoidRootPart.CFrame = CFrame.new(-1077, 5, 1675)
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                
                if hoverConnection then
                    hoverConnection:Disconnect()
                    hoverConnection = nil
                end
                
                
                if lastPosition then
                    character.HumanoidRootPart.CFrame = lastPosition
                    lastPosition = nil
                end
                
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Store Tab 

Tabs.Shop:AddSection("Shop Functions")

local rods = {
    ["Luck Rod"] = 79,
    ["Carbon Rod"] = 76,
    ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77,
    ["Ice Rod"] = 78,
    ["Lucky Rod"] = 4,
    ["Midnight Rod"] = 80,
    ["Steampunk Rod"] = 6,
    ["Chrome Rod"] = 7,
    ["Flourescent Rod"] = 255,
    ["Astral Rod"] = 5
}

local rodNamesList = {}
for name, _ in pairs(rods) do
    table.insert(rodNamesList, name)
end

local selectedRod = rodNamesList[1]

Tabs.Shop:AddDropdown("SelectRod", {
    Title = "Select Fishing Rod",
    Values = rodNamesList,
    Multi = false,
    Default = 1,
    Description = "Select a fishing rod to buy",
    Callback = function(Value)
        selectedRod = Value
    end
})

Tabs.Shop:AddButton({
    Title = "Purchase Rod",
    Callback = function()
        local rodId = rods[selectedRod]
        if rodId then
            RFPurchaseFishingRod:InvokeServer(rodId)
        end
    end
})

Tabs.Shop:AddSection("Bait")

local bait = {
    ["TopWater Bait"] = 10,
    ["Luck Bait"] = 2,
    ["Midnight Bait"] = 3,
    ["Nature Bait"] = 17,
    ["Chroma Bait"] = 6,
    ["Dark Matter Bait"] = 8,
    ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16,
    ["Floral Bait"] = 20
}

local baitNamesList = {}
for name, _ in pairs(bait) do
    table.insert(baitNamesList, name)
end

local selectedBait = baitNamesList[1]

Tabs.Shop:AddDropdown("SelectBait", {
    Title = "Select Bait",
    Values = baitNamesList,
    Multi = false,
    Default = 1,
    Description = "Select bait to buy",
    Callback = function(Value)
        selectedBait = Value
    end
})

Tabs.Shop:AddButton({
    Title = "Purchase Bait",
    Callback = function()
        local baitId = bait[selectedBait]
        if baitId then
            RFPurchaseBait:InvokeServer(baitId)
        end
    end
})



-- Save Manager
SaveManager:SetLocation("FishItScript")
SaveManager:SetFolder("FishIt")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:Load("AutoSave")

-- Auto Save
Window:OnClose(function()
    SaveManager:Save("AutoSave")
end)



