MoonshineMarauders.LootTracker = {}
local LootTracker = MoonshineMarauders.LootTracker
local addon = MoonshineMarauders

LootTracker.isLooting = false

function LootTracker:InitializeDB()
    if not MoonshineMaraudersDB.loot then
        MoonshineMaraudersDB.loot = { daily = 0, lastReset = "" }
    end
end

function LootTracker:HandleLootOpened()
    self.isLooting = true
end

function LootTracker:HandleLootClosed()
    self.isLooting = false
end

function LootTracker:HandleLootedMoney(message)
    -- Only parse for money if we are currently in a loot session.

    local lowerMessage = string.lower(message)

    if string.find(lowerMessage, "|hitem:") then
        return
    end

    local amount = 0
    for value, unit in string.gmatch(lowerMessage, "(%d+)%s*(%a+)") do
        if unit == "gold" or unit == "g" then
            amount = amount + (tonumber(value) * 10000)
        elseif unit == "silver" or unit == "s" then
            amount = amount + (tonumber(value) * 100)
        elseif unit == "copper" or unit == "c" then
            amount = amount + tonumber(value)
        end
    end

    if amount > 0 then
        local today = date("%Y-%m-%d")
        if not MoonshineMaraudersDB.loot or MoonshineMaraudersDB.loot.lastReset ~= today then
            if not MoonshineMaraudersDB.loot then MoonshineMaraudersDB.loot = {} end
            MoonshineMaraudersDB.loot.daily = 0
            MoonshineMaraudersDB.loot.lastReset = today
        end
        
        MoonshineMaraudersDB.loot.daily = MoonshineMaraudersDB.loot.daily + amount
    end
end

function LootTracker:GetDailyLoot()
    local today = date("%Y-%m-%d")
    if MoonshineMaraudersDB.loot and MoonshineMaraudersDB.loot.lastReset == today then
        return MoonshineMaraudersDB.loot.daily
    end
    return 0
end

function LootTracker:Register(eventFrame)
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:RegisterEvent("LOOT_CLOSED")
end