-- UI libs
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Window
local Window = Fluent:CreateWindow({
    Title = "Banana Hub " .. Fluent.Version,
    SubTitle = "by Vxstigely",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Enable AutoFarm", Icon = "bot" }),
}

-- Paragraphs (sections)
Tabs.Main:AddParagraph({ Title = "Fish Section", Content = "Start Auto Fishing", Icon = "fish" })
Tabs.Main:AddParagraph({ Title = "Sell Section", Content = "Configure Auto Sell" })

local FishingController
do
    local ok, result = pcall(function()
        return require(game:GetService("ReplicatedStorage").Controllers.FishingController)
    end)
    if ok then
        FishingController = result
    else
        warn("Failed to load FishingController:", result)
    end
end

local autofarm = false
local autosell = false
local sellDelay = 5


local FishToggle = Tabs.Main:AddToggle("AutoFishToggle", { Title = "Auto Fish", Default = false })
FishToggle:OnChanged(function(v) autofarm = v end)

local StatusFish = Tabs.Main:AddParagraph({ Title = "Fishing status", Content = "Idle" })

local SellToggle = Tabs.Main:AddToggle("AutoSellToggle", { Title = "Auto Sell", Default = false })
SellToggle:OnChanged(function(v) autosell = v end)

local SellSlider = Tabs.Main:AddSlider("AutoSellDelay", {
    Title = "Selling delay (seconds)",
    Description = "How often to sell your items",
    Default = sellDelay,
    Min = 2,
    Max = 60,
    Rounding = 1,
    Callback = function(v) sellDelay = v end
})

local StatusSell = Tabs.Main:AddParagraph({ Title = "Sell status", Content = "Disabled" })

Tabs.Main:AddButton({
    Title = "Instant Sell",
    Description = "Sell all items immediately",
    Callback = function()
        local ok, err = pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RF")
                :WaitForChild("SellAllItems")
                :InvokeServer()
        end)
        if ok then
            StatusSell:SetDesc("Sold once")
        else
            warn("Instant sell error:", err)
            StatusSell:SetDesc("Error — check console")
        end
    end
})


task.spawn(function()
    while true do
        if autofarm and FishingController then
            StatusFish:SetDesc("Casting…")
            local castOk, castErr = pcall(function()
                
                FishingController:RequestChargeFishingRod(Vector2.new(0, 0), true)

                
                local guid = FishingController.GetCurrentGUID and FishingController:GetCurrentGUID()
                if guid then
                   
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Packages")
                        :WaitForChild("_Index")
                        :WaitForChild("sleitnick_net@0.2.0")
                        :WaitForChild("net")
                        :WaitForChild("RE")
                        :WaitForChild("FishingCompleted")
                        :FireServer(guid)
                    StatusFish:SetDesc("Caught — waiting")
                else
                    StatusFish:SetDesc("No GUID — retrying")
                end
            end)

            if not castOk then
                warn("Fishing error:", castErr)
                StatusFish:SetDesc("Error — check console")
            end

            
            task.wait(3)
        else
            StatusFish:SetDesc(autofarm and "Controller missing" or "Idle")
            task.wait(0.5)
        end
    end
end)


task.spawn(function()
    while true do
        if autosell then
            StatusSell:SetDesc("Selling…")
            local ok, err = pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0")
                    :WaitForChild("net")
                    :WaitForChild("RF")
                    :WaitForChild("SellAllItems")
                    :InvokeServer()
            end)
            if ok then
                StatusSell:SetDesc("Sold — waiting " .. tostring(sellDelay) .. "s")
            else
                warn("Auto-sell error:", err)
                StatusSell:SetDesc("Error — check console")
            end
            task.wait(sellDelay)
        else
            StatusSell:SetDesc("Disabled")
            task.wait(1)
        end
    end
end)


SaveManager:LoadAutoloadConfig()
