MoonshineMarauders.QuestTracker = {}
local QuestTracker = MoonshineMarauders.QuestTracker
local addon = MoonshineMarauders

function QuestTracker:InitializeDB()
    if not MoonshineMaraudersDB.quests then
        MoonshineMaraudersDB.quests = { total = 0, daily = 0, lastReset = "" }
    end
end

function QuestTracker:HandleQuestTurnIn()
    local today = date("%Y-%m-%d")
    if MoonshineMaraudersDB.quests.lastReset ~= today then
        MoonshineMaraudersDB.quests.daily = 0
        MoonshineMaraudersDB.quests.lastReset = today
    end
    MoonshineMaraudersDB.quests.daily = MoonshineMaraudersDB.quests.daily + 1
    MoonshineMaraudersDB.quests.total = MoonshineMaraudersDB.quests.total + 1
    addon:LogMessage(string.format("Quest completed. Daily: %d, Total: %d", MoonshineMaraudersDB.quests.daily, MoonshineMaraudersDB.quests.total))
end

function QuestTracker:Register(eventFrame)
    -- Register events
    eventFrame:RegisterEvent("QUEST_TURNED_IN")

    -- Register slash commands
    SLASH_MOONSHINEMARAUDERS1 = "/mm"
    SlashCmdList["MOONSHINEMARAUDERS"] = function()
        local quests = MoonshineMaraudersDB.quests
        if not quests then
            addon:BPrint("Quest data not available yet.")
            return
        end
        addon:BPrint(string.format("Quests completed today: %d", quests.daily))
        addon:BPrint(string.format("Total quests completed: %d", quests.total))
    end
end