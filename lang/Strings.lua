--[[

QuestMapTool
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

local strings = {
	QUESTMAPTOOL_BINDING_CATEGORY_TITLE           = "|c70C0DEQuestMap Tool|r",
	SI_BINDING_NAME_QUESTMAPTOOL_BINDING_STRING_1 = "Get subzone info",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end