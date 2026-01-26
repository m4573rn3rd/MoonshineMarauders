local addon = MoonshineMarauders

function addon:LogMessage(message)
    local timestamp = date("[%Y-%m-%d %H:%M:%S] ")
    local fullMessage = timestamp .. message
    table.insert(MoonshineMaraudersDB.logs, 1, fullMessage)
    if #MoonshineMaraudersDB.logs > 100 then
        table.remove(MoonshineMaraudersDB.logs, 101)
    end
end

function addon:BPrint(msg)
    print("|cFF00FF00[MoonshineMarauders]|r: " .. msg)
end

-- UI and Event Handling
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    local QuestTracker = MoonshineMarauders.QuestTracker
    local LootTracker = MoonshineMarauders.LootTracker
    local BattleTracker = MoonshineMarauders.BattleTracker

    if event == "ADDON_LOADED" and arg1 == "MoonshineMarauders" then
        if not MoonshineMaraudersDB then MoonshineMaraudersDB = {} end
        if not MoonshineMaraudersDB.logs then MoonshineMaraudersDB.logs = {} end
        
        QuestTracker:InitializeDB()
        LootTracker:InitializeDB()
        BattleTracker:InitializeDB()
        
        addon:LogMessage("ADDON_LOADED event fired.")
        
        addon:BPrint("Systems Online: Boss Auto-Tracker, Damage Meter & Telemetry active.")

    elseif event == "PLAYER_LOGIN" then
        addon:LogMessage("PLAYER_LOGIN event fired.")
        QuestTracker:Register(eventFrame)
        LootTracker:Register(eventFrame)
        BattleTracker:Register(eventFrame)

    elseif event == "QUEST_TURNED_IN" then
        QuestTracker:HandleQuestTurnIn()

    elseif event == "LOOT_OPENED" then
        LootTracker:HandleLootOpened()

    elseif event == "LOOT_CLOSED" then
        LootTracker:HandleLootClosed()

    elseif event == "ENCOUNTER_START" then
        local _, encounterName = ...
        BattleTracker:StartTracking()
        addon:BPrint("Boss Engaged: |cFFFFFF00" .. encounterName .. "|r. Tracking started.")

    elseif event == "ENCOUNTER_END" then
        local _, encounterName, _, _, success = ...
        if success == 1 then
            addon:BPrint("Victory! Reporting stats...")
            BattleTracker:AutoReport()
        end
        BattleTracker:StopTracking()

    elseif event == "PLAYER_TARGET_CHANGED" then
        local targetName = UnitName("target")
        if targetName then
            local classification = UnitClassification("target")
            if classification == "worldboss" or classification == "elite" then
                addon:BPrint("TARGET ACQUIRED: |cFFFF0000" .. targetName .. " (" .. classification:upper() .. ")|r")
            end
        end

    elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_MONEY" then
        LootTracker:HandleLootedMoney(arg1)

        -- This part can stay in core for now, or be moved to a misc module later.
        local msg = arg1
        local itemLink = string.match(msg, "|Hitem:.-|h%[.-%]|h")
        if itemLink and Auctionator and Auctionator.API and Auctionator.API.v1.GetAuctionPriceByItemLink then
            local price = Auctionator.API.v1.GetAuctionPriceByItemLink("MoonshineMarauders", itemLink)
            if price and price > 10000 then -- > 1g
                addon:BPrint("Market Alert: " .. itemLink .. " is worth " .. GetCoinTextureString(price))
            end
        end
        if msg:find("Fish") or msg:find("Fishing") then
            local mapID = C_Map.GetBestMapForUnit("player")
            if mapID then
                local pos = C_Map.GetPlayerMapPosition(mapID, "player")
                if pos then
                    addon:BPrint(string.format("Fishing Spot Logged: %.2f, %.2f", pos.x*100, pos.y*100))
                end
            end
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if BattleTracker.isTracking then
            local _, subevent, _, _, sourceName, sourceFlags, _, _, destName = CombatLogGetCurrentEventInfo()
            local MASK_GROUP = COMBATLOG_OBJECT_AFFILIATION_MINE + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_RAID
            if bit.band(sourceFlags, MASK_GROUP) ~= 0 then
                local amount
                if subevent == "SWING_DAMAGE" then
                    amount = select(12, CombatLogGetCurrentEventInfo())
                elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                    amount = select(15, CombatLogGetCurrentEventInfo())
                end

                if amount then
                    BattleTracker:LogGroupDamage(sourceName, destName, amount)
                end
            end
        end
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")
eventFrame:RegisterEvent("ENCOUNTER_START")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
