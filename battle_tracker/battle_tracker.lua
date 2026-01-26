MoonshineMarauders.BattleTracker = {}
local BattleTracker = MoonshineMarauders.BattleTracker
local addon = MoonshineMarauders

BattleTracker.startTime = 0
BattleTracker.isTracking = false

function BattleTracker:InitializeDB()
    if not MoonshineMaraudersDB.battleStats then
        MoonshineMaraudersDB.battleStats = { players = {}, lastReset = date() }
    end
end

function BattleTracker:LogGroupDamage(playerName, targetName, amount)
    if not self.isTracking then return end

    if not MoonshineMaraudersDB.battleStats.players[playerName] then
        MoonshineMaraudersDB.battleStats.players[playerName] = { totalDamage = 0, targets = {} }
    end
    local pData = MoonshineMaraudersDB.battleStats.players[playerName]
    pData.totalDamage = pData.totalDamage + amount
    
    if not pData.targets[targetName] then 
        pData.targets[targetName] = 0 
    end
    pData.targets[targetName] = pData.targets[targetName] + amount
end

function BattleTracker:GetRankedStats()
    local sortedList = {}
    local totalGroupDamage = 0
    
    for name, data in pairs(MoonshineMaraudersDB.battleStats.players) do
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

function BattleTracker:StartTracking()
    if self.isTracking then return end
    self.isTracking = true
    self.startTime = GetTime()
    self:ResetData()
end

function BattleTracker:StopTracking()
    if not self.isTracking then return end
    self.isTracking = false
end

function BattleTracker:GetDPS(totalDamage)
    local duration = GetTime() - self.startTime
    if duration <= 0 then return 0 end
    return math.floor(totalDamage / duration)
end

function BattleTracker:ResetData()
    MoonshineMaraudersDB.battleStats = { players = {}, lastReset = date() }
end

function BattleTracker:AutoReport()
    local stats, totalDamage, duration = self:GetRankedStats()
    if #stats == 0 then return end

    local channel = "SAY"
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then channel = "INSTANCE_CHAT"
    elseif IsInRaid() then channel = "RAID"
    elseif IsInGroup() then channel = "PARTY" end

    SendChatMessage(string.format("--- Battle Report! Duration: %.1fs ---", duration), channel)
    
    for i = 1, math.min(5, #stats) do
        local data = stats[i]
        SendChatMessage(string.format("%d. %s: %d DPS", i, data.name, data.dps), channel)
    end
end

function BattleTracker:Register(eventFrame)
    -- We don't need to register events here because Core.lua will call this module's
    -- functions directly from its own event handlers.
end
