-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Banana Hub " .. Fluent.Version,
    SubTitle = "by Vxstigely",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Enable AutoFarm", Icon = "bot" }),    
}

Tabs.Main:AddParagraph({
    Title = "Fish Section",
    Content = "Start Auto Fishing",
    Icon = "Bot"
})

-- Require FishingController safely
local FishingController
do
    local ok, result = pcall(function()
        return require(game:GetService("ReplicatedStorage").Controllers.FishingController)
    end)
    if ok then
        FishingController = result
        print("FishingController loaded successfully")
    else
        warn("Failed to load FishingController:", result)
    end
end

-- AutoFarm Toggle
local autofarm = false
local Toggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Auto Fish", Default = false })
Toggle:OnChanged(function(value)
    autofarm = value
end)

-- Status Label
local StatusLabel = Tabs.Main:AddParagraph({
    Title = "Status",
    Content = "Idle"
})

-- Fishing Loop
task.spawn(function()
    while true do
        if autofarm and FishingController then
            StatusLabel:SetDesc("Fishing…")
            local success, err = pcall(function()
                -- Start fishing
                FishingController:RequestChargeFishingRod(Vector2.new(0, 0), true)

                -- Get GUID
                local guid = FishingController.GetCurrentGUID and FishingController:GetCurrentGUID()
                if guid then
                    -- Fire FishingCompleted with GUID
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
                StatusLabel:SetDesc("Error — check console")
            end

            task.wait(3) -- delay between casts
        else
            StatusLabel:SetDesc("Idle")
            task.wait(0.5)
        end
    end
end)

-- Save Config
SaveManager:LoadAutoloadConfig()
