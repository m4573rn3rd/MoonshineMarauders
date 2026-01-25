MoonshineMarauders.StatsTracker = {}
local StatsTracker = MoonshineMarauders.StatsTracker
local addon = MoonshineMarauders

StatsTracker.startTime = 0
StatsTracker.isTracking = false

function StatsTracker:InitializeDB()
    if not MoonshineMaraudersDB.stats then
        MoonshineMaraudersDB.stats = { players = {}, lastReset = date() }
    end
end

function StatsTracker:Initialize()
    addon:LogMessage("Tracker Initialized.")
end

function StatsTracker:LogGroupDamage(playerName, targetName, amount)
    if not self.isTracking then return end

    if not MoonshineMaraudersDB.stats.players[playerName] then
        MoonshineMaraudersDB.stats.players[playerName] = { totalDamage = 0, targets = {} }
    end
    local pData = MoonshineMaraudersDB.stats.players[playerName]
    pData.totalDamage = pData.totalDamage + amount
    
    if not pData.targets[targetName] then 
        pData.targets[targetName] = 0 
    end
    pData.targets[targetName] = pData.targets[targetName] + amount
end

function StatsTracker:GetRankedStats()
    local sortedList = {}
    local totalGroupDamage = 0
    
    for name, data in pairs(MoonshineMaraudersDB.stats.players) do
        totalGroupDamage = totalGroupDamage + data.totalDamage
        table.insert(sortedList, { 
            name = name, 
            damage = data.totalDamage, 
            dps = self:GetDPS(data.totalDamage) 
        })
    end
    
    table.sort(sortedList, function(a, b) return a.damage > b.damage end)
    
    local duration = self.isTracking and (GetTime() - self.startTime) or 0
    return sortedList, totalGroupDamage, duration
end

function StatsTracker:StartTracking()
    if self.isTracking then return end
    addon:LogMessage("Starting combat tracking.")
    addon:BPrint("Tracking |cFF00FF00ENABLED|r.")
    self.isTracking = true
    self.startTime = GetTime()
    self:ResetData()
end

function StatsTracker:StopTracking()
    if not self.isTracking then return end
    addon:LogMessage("Stopping combat tracking.")
    addon:BPrint("Tracking |cFFFF0000STOPPED|r.")
    self.isTracking = false
end

function StatsTracker:GetDPS(totalDamage)
    local duration = GetTime() - self.startTime
    if duration <= 0 then return 0 end
    return math.floor(totalDamage / duration)
end

function StatsTracker:ResetData()
    addon:LogMessage("Resetting combat data.")
    MoonshineMaraudersDB.stats = { players = {}, lastReset = date() }
end

function StatsTracker:AutoReport()
    local stats, totalDamage, duration = self:GetRankedStats()
    if #stats == 0 then return end

    local channel = "SAY"
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then channel = "INSTANCE_CHAT"
    elseif IsInRaid() then channel = "RAID"
    elseif IsInGroup() then channel = "PARTY" end

    SendChatMessage(string.format("--- Boss Victory! Duration: %.1fs ---", duration), channel)
    
    for i = 1, math.min(5, #stats) do
        local data = stats[i]
        SendChatMessage(string.format("%d. %s: %d DPS", i, data.name, data.dps), channel)
    end
end

function StatsTracker:Register(eventFrame)
    eventFrame:RegisterEvent("ENCOUNTER_START")
    eventFrame:RegisterEvent("ENCOUNTER_END")
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    SLASH_BSTART1 = "/bstart"
    SlashCmdList["BSTART"] = function() self:StartTracking() end
        
    SLASH_BSTOP1 = "/bstop"
    SlashCmdList["BSTOP"] = function() self:StopTracking() end
end