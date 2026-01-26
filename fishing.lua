MoonshineMarauders.FishingLog = {}
local FishingLog = MoonshineMarauders.FishingLog
local addon = MoonshineMarauders

function FishingLog:HandleLootMessage(msg)
    if msg:find("Fish") or msg:find("Fishing") then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                addon:BPrint(string.format("Fishing Spot Logged: %.2f, %.2f", pos.x*100, pos.y*100))
            end
        end
    end
end