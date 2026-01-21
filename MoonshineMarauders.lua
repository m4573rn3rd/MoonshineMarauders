-- Initialize the addon
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MoonshineMarauders" then
        -- Initialize the database if it doesn't exist
        if MoonshineMaraudersDB == nil then
            MoonshineMaraudersDB = {}
        end
        print("Moonshine Marauders addon loaded! Type /mm to show/hide the window.")
    end
end)

local addonName, addonTable = ...
local frame = CreateFrame("Frame")

-- Unified Event Handler for initializations that depend on addonTable
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        -- Initialize Damage Tracker
        if addonTable.Tracker and addonTable.Tracker.Initialize then
            addonTable.Tracker:Initialize()
        end
        
        -- Initialize Guild Auditor
        if addonTable.GuildTracker and addonTable.GuildTracker.Initialize then
            addonTable.GuildTracker:Initialize()
        end

        -- Initialize Quest Log
        if addonTable.QuestLog and addonTable.QuestLog.Initialize then
            addonTable.QuestLog:Initialize()
        end
        
        print("|cFF00FF00[MoonshineMarauders]|r: Systems Online: Boss Auto-Tracker, Guild Auditor, Market Monitor & Quest Log active.")
    end
end)

frame:RegisterEvent("ADDON_LOADED")