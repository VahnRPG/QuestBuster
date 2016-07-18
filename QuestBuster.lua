local DB_VERSION = 0.00;

QuestBusterInit = nil;
QuestBusterOptions = {};
QuestBusterPlayer = nil;
QuestBusterServer = nil;
QuestBusterEntry_Personal = nil;
QuestBusterEntry = nil;

local _;

--==SLASH COMMANDS==--
SLASH_QBUSTER1 = "/QuestBuster";
SLASH_QBUSTER2 = "/qbuster";
SLASH_QBUSTER3 = "/qb";

function QuestBuster_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");

	SlashCmdList["QBUSTER"] = function(msg)
		QuestBuster_Command(msg);
	end
end

function QuestBuster_OnEvent(self, event, ...)
	local arg1 = ...;
	if (event == "ADDON_LOADED") then
		if (QuestBuster_InitPlayer()) then
			QuestBuster_InitSettings();
			QuestBuster_TitanPanel_Update();

			self:UnregisterEvent(event);
			QuestBusterInit = true;
	
			DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. QBG_MOD_NAME .. " (v" .. QBG_VERSION .. " - Last Updated: " .. QBG_LAST_UPDATED .. ")");
		end
	end
end

function QuestBuster_Command(cmd)
	cmd = string.lower(cmd);

	if (cmd == "help") then
		for i = 1, QBL["HELP_LINES"] do
			DEFAULT_CHAT_FRAME:AddMessage(QBL["HELP" .. i]);
		end
	elseif (cmd == "config") then
		QuestBuster_Config_Show();
	elseif (cmd == "test") then
		QuestBuster_Loot_HighlightRewards();
	elseif (cmd == "reset") then
		QuestBuster_InitSettings("character");
		QuestBuster_TitanPanel_Update();
		DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. "Reset");
	elseif (cmd == "fullreset") then
		QuestBuster_InitSettings(true);
		QuestBuster_TitanPanel_Update();
		DEFAULT_CHAT_FRAME:AddMessage(QBG_MOD_COLOR .. "Fully Reset");
	end
end

function QuestBuster_InitPlayer()
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

function QuestBuster_InitSettings(reset)
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
end