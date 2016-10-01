local DB_VERSION = 0.00;

QuestBusterInit = nil;
QuestBusterOptions = {};
QuestBusterPlayer = nil;
QuestBusterServer = nil;
QuestBusterEntry_Personal = nil;
QuestBusterEntry = nil;

local _, qb = ...;

qb.frame = CreateFrame("Frame", "QuestBusterFrame", UIParent, "SecureFrameTemplate");

--==BINDING==--
BINDING_HEADER_QUESTBUSTER = QBG_MOD_NAME;
BINDING_NAME_QB_TOGGLE_WORLD_QUESTS_FRAME = QBL["BINDING_TOGGLE_WORLD_QUESTS_FRAME"];
--[[
BINDING_NAME_QB_OPEN_SKILL_1 = CBL["BINDING_OPEN_SKILL_1"];
BINDING_NAME_QB_OPEN_SKILL_1_BUSTER = CBL["BINDING_OPEN_SKILL_1_BUSTER"];
BINDING_NAME_QB_OPEN_SKILL_2 = CBL["BINDING_OPEN_SKILL_2"];
BINDING_NAME_QB_OPEN_SKILL_2_BUSTER = CBL["BINDING_OPEN_SKILL_2_BUSTER"];
BINDING_NAME_QB_OPEN_COOKING = CBL["BINDING_OPEN_COOKING"];
BINDING_NAME_QB_OPEN_FIRST_AID = CBL["BINDING_OPEN_FIRST_AID"];
BINDING_NAME_QB_OPEN_ARCHAEOLOGY = CBL["BINDING_OPEN_ARCHAEOLOGY"];
BINDING_NAME_QB_OPEN_LOCKPICKING_BUSTER = CBL["BINDING_OPEN_LOCKPICKING_BUSTER"];
]]--

--==SLASH COMMANDS==--
SLASH_QBUSTER1 = "/QuestBuster";
SLASH_QBUSTER2 = "/qbuster";
SLASH_QBUSTER3 = "/qb";

SlashCmdList["QBUSTER"] = function(cmd)
	cmd = string.lower(cmd);

	if (cmd == "help") then
		for i=1, QBL["HELP_LINES"] do
			DEFAULT_CHAT_FRAME:AddMessage(QBL["HELP" .. i]);
		end
	elseif (cmd == "config") then
		QuestBuster_Config_Show();
	elseif (cmd == "reset") then
		qb:initSettings("character");
		qb.titan:update();
		DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. "Reset");
	elseif (cmd == "fullreset") then
		qb:initSettings(true);
		qb.titan:update();
		DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. "Fully Reset");
	end
end

qb.frame:RegisterEvent("ADDON_LOADED");
qb.frame:SetScript("OnEvent", function(self, event, ...)
	return qb[event] and qb[event](qb, ...)
end);

function qb:ADDON_LOADED(self, ...)
	if (qb:initPlayer()) then
		qb:initSettings();
		qb.titan:QUEST_LOG_UPDATE();

		qb.frame:UnregisterEvent("ADDON_LOADED");
		QuestBusterInit = true;

		DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. QBG_MOD_NAME .. " (v" .. QBG_VERSION .. " - Last Updated: " .. QBG_LAST_UPDATED .. ")");
	end
end

function qb:initPlayer()
	QuestBusterPlayer = UnitName("player");
	QuestBusterPlayerLevel = UnitLevel("player");
	QuestBusterServer = GetRealmName();
	QuestBusterEntry_Personal = QuestBusterPlayer .. "@" .. QuestBusterServer;
	QuestBusterEntry = QuestBusterEntry_Personal;
	if (not QuestBusterOptions) then
		QuestBusterOptions = {};
	end
	if (not QuestBusterOptions.globals) then
		QuestBusterOptions.globals = {};
	end
	if (not QuestBusterOptions.globals[QuestBusterEntry_Personal]) then
		QuestBusterOptions.globals[QuestBusterEntry_Personal] = "global";
	end
	QuestBusterEntry = QuestBusterOptions.globals[QuestBusterEntry_Personal];
	
	if (QuestBusterPlayer == nil or QuestBusterPlayer == UNKNOWNOBJECT or QuestBusterPlayer == UKNOWNBEING) then
		return false;
	end
	
	return true;
end

function qb:initSettings(reset)
	if (QuestBusterInit and not reset) then
		return;
	end
	
	if (not QuestBusterOptions or reset == true) then
		QuestBusterOptions = {};
		QuestBusterOptions.globals = {};
		QuestBusterOptions.globals[QuestBusterEntry_Personal] = "global";
		QuestBusterEntry = QuestBusterOptions.globals[QuestBusterEntry_Personal];
	end
	if (not QuestBusterOptions[QuestBusterEntry] or reset == "character") then
		QuestBusterOptions[QuestBusterEntry] = {};
	end
	if (not QuestBusterOptions[QuestBusterEntry].settings) then
		QuestBusterOptions[QuestBusterEntry].settings = {
			["quest_ui"] = "default",
		};
	end
	if (not QuestBusterOptions[QuestBusterEntry].reward_highlights) then
		QuestBusterOptions[QuestBusterEntry].reward_highlights = {};
		for key, value in pairs(QBG_REWARDS) do
			QuestBusterOptions[QuestBusterEntry].reward_highlights[key] = true;
		end
	end
	if (not QuestBusterOptions[QuestBusterEntry].auto_quest) then
		QuestBusterOptions[QuestBusterEntry].auto_quest = {
			["enabled"] = true,
			["modifier"] = CTRL_KEY,
			["only_dailies"] = true,
			["low_level"] = true,
			["repeatable"] = true,
			["reward"] = QBT_REWARD_NONE,
		};
	end
	if (not QuestBusterOptions[QuestBusterEntry].daily_quest_rewards) then
		QuestBusterOptions[QuestBusterEntry].daily_quest_rewards = {};
	end
	if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames) then
		QuestBusterOptions[QuestBusterEntry].quest_list_frames = {};
	end
	if (not QuestBusterOptions[QuestBusterEntry].watch_frame) then
		QuestBusterOptions[QuestBusterEntry].watch_frame = {
			["show_level"] = true,
			["show_abandon"] = true,
		};
	end
	if (not QuestBusterOptions[QuestBusterEntry].minimap) then
		QuestBusterOptions[QuestBusterEntry].minimap = {};
		QuestBusterOptions[QuestBusterEntry].minimap.show = true;
		QuestBusterOptions[QuestBusterEntry].minimap.position = 310;
		QuestBuster_Minimap_Init();
	end
	
	for _, frame_data in pairs(QBG_QUEST_LIST_FRAMES) do
		if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]]) then
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]] = {};
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].show = true;
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].position = {
				point = "TOPLEFT",
				relative_point = "TOPLEFT",
				x = 490,
				y = -330,
			};
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].locked = false;
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].state = "expanded";
		end
	end
end