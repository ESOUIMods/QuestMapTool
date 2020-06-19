--[[

QuestMapTool
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Add-on info
QuestMapTool = {}
QuestMapTool.name = "QuestMapTool"


local function p(str)
    d(QuestMapTool.name .. ": " .. str)
end

local function GetZoneAndSubzone()
    return select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+/[%w%-]+_[%w%-]+)"))
end

function QuestMapTool.getSubzone()
    if ZO_WorldMap:IsHidden() then p("Open submap first"); return end
    
    local zone, subzone
    local x1, x2, y1, y2
    local output
    
    -- Make sure waypoint is not set
    RemovePlayerWaypoint()
    -- Get subzone identification string
    subzone = GetZoneAndSubzone()
    -- Set waypoint to 0,0
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, 0, 0)
    -- Zoom out to main zone
    ZO_WorldMap_MouseUp(nil, 2, true)
    -- Get waypoint in this zone --> x, y of subzone
    x1, y1 = GetMapPlayerWaypoint()
    -- Get zone identification string
    zone = GetZoneAndSubzone()
    -- Check if we started at the correct map level
    if zone:find("tamriel/") == 1 then p("Press the key after clicking on the subzone, not before"); return end
    -- Zoom back in to subzone
    ZO_WorldMap_MouseUp(nil, 1, true)
    -- Remove waypoint
    RemovePlayerWaypoint()
    -- Set waypoint to 100,0
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, 1, 0)
    -- Zoom out to main zone
    ZO_WorldMap_MouseUp(nil, 2, true)
    -- Get waypoint in this zone --> x, y of subzone
    x2, y2 = GetMapPlayerWaypoint()
    -- Remove waypoint
    RemovePlayerWaypoint()
    -- Calculate zoom factor
    local zoom_factor = x2 - x1
    
    -- Save values
    if QuestMapTool.savedVars.zoneSubzones[zone] == nil then
        QuestMapTool.savedVars.zoneSubzones[zone] = {}
    end
    QuestMapTool.savedVars.zoneSubzones[zone][subzone] = {
        ["x"] = x1,
        ["y"] = y1,
        ["zoom_factor"] = zoom_factor
    }
    
    p("Info about subzone '" .. subzone .. "' collected")
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event)
    -- Set up SavedVariables table
    QuestMapTool.savedVars = ZO_SavedVars:NewAccountWide("QuestMapToolSavedVars", 1, nil, {zoneSubzones={}})
    EVENT_MANAGER:UnregisterForEvent(QuestMapTool.name, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(QuestMapTool.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)