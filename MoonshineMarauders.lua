-- Create a slash command to show/hide the main frame
SLASH_MOONSHINEMARAUDERS1 = "/mm"
SlashCmdList["MOONSHINEMARAUDERS"] = function(msg)
    if MoonshineMaraudersFrame:IsShown() then
        MoonshineMaraudersFrame:Hide()
    else
        MoonshineMaraudersFrame:Show()
    end
end

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
