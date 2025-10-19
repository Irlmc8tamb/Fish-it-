-- UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Banana Hub " .. Fluent.Version,
    SubTitle = "by Vxstigely",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Enable AutoFarm", Icon = "bot" }),    
}
Tabs.Main:AddParagraph({
    Title = "Fish Section",
    Content = "Start Auto Fishing",
    Icon = "Bot"
})
-- Main
local FishingController = require(game:GetService("ReplicatedStorage").Controllers.FishingController)



-- AutoFarm Toggle
local autofarm = false
local Toggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Auto Fish", Default = false })
Toggle:OnChanged(function(value)
    autofarm = value
end)

task.spawn(function()
    while true do
        if autofarm then
            local success, err = pcall(function()
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
                end
            end)
            if not success then
                warn("Fishing error:", err)
            end
            task.wait(3)
        else
            task.wait(0.5)
        end
    end
end)

-- Sell Section
Tabs.Main:AddParagraph({
    Title = "Auto Sell",
    Content = "Start Auto selling"
})

Tabs.Main:AddButton({
    Title = "Instant Sell",
    Description = "",
    Callback = function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")
            :WaitForChild("RF/SellAllItems")
            :InvokeServer()
    end 
})

-- Auto Sell
local AutoSellEnable = false 
local AutoSellDelay = 2

Tabs.Main:AddToggle("AutoSellToggle", {Title = "Enable Auto Sell", Default = false}):OnChanged(function(value)
    AutoSellEnable = value
end)

Tabs.Main:AddSlider("Slider", {
    Title = "Selling Delay",
    Description = "Adjust Selling Delay Here",
    Default = 2,
    Min = 1,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        AutoSellDelay = Value
    end
})

task.spawn(function()
    while true do
        if AutoSellEnable then
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RF/SellAllItems")
                :InvokeServer()
            task.wait(AutoSellDelay)
        else
            task.wait(1)
        end
    end
end)

-- Event Section
Tabs.Main:AddParagraph({
    Title = "Event Section",
    Content = ""
})

local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
   Title = "Dropdown",
   Description = "You can select multiple values.",
   Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
   Multi = true,
   Default = {"seven", "twelve"},
})

-- Save Config
SaveManager:LoadAutoloadConfig()
