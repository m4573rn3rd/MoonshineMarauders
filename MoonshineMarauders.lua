local addonName, addonTable = ...
local frame = CreateFrame("Frame")

-- Unified Event Handler for addon loading and initializations
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize the database if it doesn't exist
        if MoonshineMaraudersDB == nil then
            MoonshineMaraudersDB = {}
        end

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
        
        -- Ensure the main UI frame is initialized and associated with addonTable.TrackerGUI
        if not addonTable.TrackerGUI.frame then
            addonTable.TrackerGUI:Create() -- This will now get the XML frame
        end
        -- Hide it by default
        addonTable.TrackerGUI.frame:Hide()

        print("|cFF00FF00[MoonshineMarauders]|r: Systems Online: Boss Auto-Tracker, Guild Auditor, Market Monitor & Quest Log active.")
        print("Moonshine Marauders addon loaded! Type /mm to show/hide the window.")
    end
end)

frame:RegisterEvent("ADDON_LOADED")

-- Slash Command for the main GUI
SLASH_MM1 = "/mm"
SlashCmdList["MM"] = function()
    -- Get the XML frame
    local f = MoonshineMaraudersFrame
    if not f then
        -- This should not happen if XML is loaded correctly
        error("MoonshineMaraudersFrame not found for /mm command!")
    end

    -- Toggle visibility
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end