local addonName, addonTable = ...
addonTable.QuestLog = {}

-- 1. Initialize Quest Database
function addonTable.QuestLog:Initialize()
    -- Ensure the global MoonshineMaraudersDB exists (should be handled by SavedVariables)
    if not MoonshineMaraudersDB then
        MoonshineMaraudersDB = {}
    end

    if not MoonshineMaraudersDB.questData then
        MoonshineMaraudersDB.questData = {
            completedToday = 0,
            totalCompleted = 0,
            lastReset = date("%Y-%m-%d")
        }
    end

    -- Daily Reset Check
    local today = date("%Y-%m-%d")
    if MoonshineMaraudersDB.questData.lastReset ~= today then
        MoonshineMaraudersDB.questData.completedToday = 0
        MoonshineMaraudersDB.questData.lastReset = today
    end
end

-- 2. Create a Small Quest HUD
function addonTable.QuestLog:CreateHUD(parentFrame)
    if self.hud then return end

    local f = CreateFrame("Frame", "MoonshineMaraudersQuestHUD", parentFrame, "BackdropTemplate")
    f:SetSize(180, 60)
    f:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -5) -- Positioned relative to parent
    -- f:SetMovable(true) -- Parent frame is movable, not the HUD itself
    -- f:EnableMouse(true)
    -- f:RegisterForDrag("LeftButton")
    -- f:SetScript("OnDragStart", f.StartMoving)
    -- f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Styling (removed backdrop as parent frame has one)
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.text:SetPoint("CENTER", 0, 0)
    f.text:SetJustifyH("LEFT")
    
    self.hud = f
    self:UpdateHUD()
end

-- 3. Update the HUD Text
function addonTable.QuestLog:UpdateHUD()
    if not self.hud then return end
    local data = MoonshineMaraudersDB.questData
    local activeQuests = C_QuestLog.GetNumQuestLogEntries()
    
    self.hud.text:SetText(string.format(
        "|cFF00FF00Quests Today:|r %d\n|cFFFFFF00Active:|r %d\n|cFF00FFFFTotal Done:|r %d",
        data.completedToday, activeQuests, data.totalCompleted
    ))
end

-- 4. Event: Quest Turned In
local qFrame = CreateFrame("Frame")
qFrame:RegisterEvent("QUEST_TURNED_IN")
qFrame:SetScript("OnEvent", function(self, event, questID, xpReward, moneyReward)
    MoonshineMaraudersDB.questData.completedToday = MoonshineMaraudersDB.questData.completedToday + 1
    MoonshineMaraudersDB.questData.totalCompleted = MoonshineMaraudersDB.questData.totalCompleted + 1
    
    print("|cFF00FF00[MidnightMarauders]|r: Quest Complete! Rewards: " .. GetCoinTextureString(moneyReward))
    addonTable.QuestLog:UpdateHUD()
end)
