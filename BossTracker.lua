local addonName, addonTable = ...
local frame = CreateFrame("Frame")
local isTracking = false

local function BPrint(msg)
    print("|cFF00FF00[BrandonStats]|r: " .. msg)
end

-- Helper: Broadcasts ranked results with the clean header
local function AutoReport()
    if not addonTable.Tracker or not addonTable.Tracker.GetRankedStats then return end
    
    local stats, totalDamage, duration = addonTable.Tracker:GetRankedStats()
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

-- Slash Commands
SLASH_BSTART1 = "/bstart"
SlashCmdList["BSTART"] = function()
    isTracking = true
    BPrint("Manual Tracking |cFF00FF00ENABLED|r.")
end

SLASH_BSTOP1 = "/bstop"
SlashCmdList["BSTOP"] = function()
    isTracking = false
    BPrint("Manual Tracking |cFFFF0000STOPPED|r.")
end

-- Event Handler for Boss Tracking
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        local _, encounterName = ...
        if addonTable.Tracker then
            addonTable.Tracker:ResetData()
            addonTable.Tracker:StartTimer()
        end
        isTracking = true
        BPrint("Boss Engaged: |cFFFFFF00" .. encounterName .. "|r. Tracking started.")

    elseif event == "ENCOUNTER_END" then
        local _, encounterName, _, _, success = ...
        isTracking = false
        if success == 1 then
            BPrint("Victory! Recording achievement and reporting stats...")
            Screenshot() -- Automatic Boss Kill Capture
            AutoReport()
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        local targetName = UnitName("target")
        if targetName then
            local classification = UnitClassification("target")
            if classification == "worldboss" or classification == "elite" then
                BPrint("TARGET ACQUIRED: |cFFFF0000" .. targetName .. " (ELITE)|r")
            else
                BPrint("Now Targeting: |cFFFFFF00" .. targetName .. "|r")
            end
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and isTracking then
        local _, subevent, _, _, sourceName, sourceFlags, _, _, destName, _, _, amount = CombatLogGetCurrentEventInfo()
        
        -- Bitwise constants for group affiliation
        local MASK_GROUP = COMBATLOG_OBJECT_AFFILIATION_MINE + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_RAID
        
        -- Use the stable bit.band library for Retail
        if bit.band(sourceFlags, MASK_GROUP) ~= 0 then
            if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                local damage = (subevent == "SWING_DAMAGE") and amount or select(15, CombatLogGetCurrentEventInfo())
                if damage and sourceName and destName and addonTable.Tracker then
                    addonTable.Tracker:LogGroupDamage(sourceName, destName, damage)
                end
            end
        end
    end
end)

frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
