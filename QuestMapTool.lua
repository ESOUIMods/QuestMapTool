--[[

QuestMapTool
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Add-on info
QuestMapTool = {}
QuestMapTool.name = "QuestMapTool"
local logger = LibDebugLogger.Create(QuestMapTool.name)
QuestMapTool.logger = logger
local SDLV = DebugLogViewer

local function create_log(log_type, log_content)
    if QuestMapTool.logger and SDLV then
        if log_type == "Debug" then
            QuestMapTool.logger:Debug(log_content)
        end
        if log_type == "Verbose" then
            QuestMapTool.logger:Verbose(log_content)
        end
    else
        d(log_content)
    end
end

local function emit_message(text)
    if(text == "") then
        text = "[Empty String]"
    end
    create_log("Debug", text)
end

local function emit_table(t, indent, table_history)
    indent          = indent or "."
    table_history    = table_history or {}

    for k, v in pairs(t) do
        local vType = type(v)

        emit_message(indent.."("..vType.."): "..tostring(k).." = "..tostring(v))

        if(vType == "table") then
            if(table_history[v]) then
                emit_message(indent.."Avoiding cycle on table...")
            else
                table_history[v] = true
                emit_table(v, indent.."  ", table_history)
            end
        end
    end
end

function dm(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if(type(value) == "table")
        then
            emit_table(value)
        else
            emit_message(tostring (value))
        end
    end
end

local function GetZoneAndSubzone()
    local mapTexture = GetMapTileTexture():lower()
    mapTexture = mapTexture:gsub("^.*/maps/", "")
    mapTexture = mapTexture:gsub("%.dds$", "")
    return mapTexture
end

function QuestMapTool.getSubzone()
    dm("Starting QuestMapTool")
    if ZO_WorldMap:IsHidden() then
        dm("Open submap first")
        return
    end

    local zone, subzone
    local x1, x2, y1, y2
    local output

    -- Make sure waypoint is not set
    RemovePlayerWaypoint()
    -- Get subzone identification string
    subzone = GetZoneAndSubzone()
    dm(GetZoneAndSubzone())
    -- Set waypoint to 0,0
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, 0, 0)
    dm("Setting player waypoint")
    -- Zoom out to main zone
    ZO_WorldMap_MouseUp(nil, 2, true)
    dm(GetZoneAndSubzone())
    -- Get waypoint in this zone --> x, y of subzone
    x1, y1 = GetMapPlayerWaypoint()
    dm("Measuring")
    -- Get zone identification string
    zone = GetZoneAndSubzone()
    -- Check if we started at the correct map level
    if zone:find("tamriel/") == 1 or zone:find("skyrim/blackreachworld") == 1 then
        dm("Press the key after clicking on the subzone, not before")
        return
    end
    -- Zoom back in to subzone
    ZO_WorldMap_MouseUp(nil, 1, true)
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
    dm(GetZoneAndSubzone())
    -- Remove waypoint
    RemovePlayerWaypoint()
    -- Set waypoint to 100,0
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, 1, 0)
    dm("Setting player waypoint")
    -- Zoom out to main zone
    ZO_WorldMap_MouseUp(nil, 2, true)
    dm(GetZoneAndSubzone())
    -- Get waypoint in this zone --> x, y of subzone
    x2, y2 = GetMapPlayerWaypoint()
    dm("Measuring")
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

    dm(QuestMapTool.savedVars.zoneSubzones[zone][subzone])
    dm("Info about subzone '" .. subzone .. "' collected")

end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event)
    -- Set up SavedVariables table
    QuestMapTool.savedVars = ZO_SavedVars:NewAccountWide("QuestMapToolSavedVars", 1, nil, {zoneSubzones={}})
    EVENT_MANAGER:UnregisterForEvent(QuestMapTool.name, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(QuestMapTool.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)