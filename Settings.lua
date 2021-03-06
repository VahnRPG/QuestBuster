local DB_VERSION = 0.08;

QuestBusterOptions = {};
QuestBusterEntry = nil;
QuestBusterEntry_Personal = nil;

local _, qb = ...;

qb.settings = {};
qb.settings.frame = CreateFrame("Frame", "QuestBuster_SettingsFrame", Minimap);
qb.settings.frame:RegisterEvent("ADDON_LOADED");
qb.settings.frame:RegisterEvent("PLAYER_LEVEL_UP");
qb.settings.frame:SetScript("OnEvent", function(self, event, ...)
	return qb.settings[event] and qb.settings[event](qb, ...)
end);
qb.settings.init = false;
qb.settings.player = {
	["name"] = "",
	["level"] = 0,
	["server"] = "",
};

function qb.settings:ADDON_LOADED(self, ...)
	qb.settings.frame:UnregisterEvent("ADDON_LOADED");

	if (not QuestBusterOptions) then
		QuestBusterOptions = {};
	end
	if (not QuestBusterOptions.globals) then
		QuestBusterOptions.globals = {};
	end
	qb.settings.player.name = UnitName("player");
	qb.settings.player.level = UnitLevel("player");
	qb.settings.player.server = GetRealmName();
	QuestBusterEntry_Personal = qb.settings.player.name .. "@" .. qb.settings.player.server;
	QuestBusterEntry = QuestBusterEntry_Personal;
	if (not QuestBusterOptions.globals[QuestBusterEntry_Personal]) then
		QuestBusterOptions.globals[QuestBusterEntry_Personal] = "global";
	end
	QuestBusterEntry = QuestBusterOptions.globals[QuestBusterEntry_Personal];
	
	qb.settings:initSettings();
	qb.settings.init = true;
end

function qb.settings:PLAYER_LEVEL_UP(player_level)
	if (not player_level) then
		player_level = UnitLevel("player");
	end
	qb.settings.player.level = player_level;
end

function qb.settings:get(entry)
	if (not entry) then
		entry = QuestBusterEntry;
	end

	if (QuestBusterOptions[entry] ~= nil) then
		return QuestBusterOptions[entry];
	end

	return {};
end

function qb.settings:initSettings(reset)
	if (qb.settings.init and not reset) then
		return;
	end

	if (not QuestBusterOptions or reset == true) then
		QuestBusterOptions = {};
		QuestBusterOptions.globals = {};
		QuestBusterOptions.globals[QuestBusterEntry_Personal] = "global";
		QuestBusterEntry = QuestBusterOptions.globals[QuestBusterEntry_Personal];
	end
	if (not QuestBusterOptions[QuestBusterEntry] or reset == "character") then
		QuestBusterOptions[QuestBusterEntry] = qb.omg:clone_table(qb.settings:default());
	end

	qb.settings:versionSettings();
end

function qb.settings:versionSettings()
	local settings = qb.settings:get();

	if (not settings.db_version or settings.db_version < 0.08) then
		if (not settings.quest_list_frame) then
			settings.quest_list_frame = {};
			settings.quest_list_frame.show = true;
			settings.quest_list_frame.position = {
				point = "TOPLEFT",
				relative_point = "TOPLEFT",
				x = 490,
				y = -330,
			};
			settings.quest_list_frame.locked = false;
			settings.quest_list_frame.state = "expanded";
			settings.quest_list_frame.show_find_group = true;
		end

		if (settings.quest_list_frames["Default"] ~= nil) then
			settings.quest_list_frame.show = settings.quest_list_frames["Default"].show;
			settings.quest_list_frame.position = settings.quest_list_frames["Default"].position;
			settings.quest_list_frame.locked = settings.quest_list_frames["Default"].locked;
			settings.quest_list_frame.state = settings.quest_list_frames["Default"].state;
			settings.quest_list_frame.show_find_group = settings.quest_list_frames["Default"].show_find_group;
		end

		settings.quest_list_frames = nil;
	end

	settings.db_version = DB_VERSION;
end

function qb.settings:copy(from, to)
	local from_settings = qb.settings:get(from);
	local to_settings = qb.settings:get(to);

	to_settings = qb.omg:clone_table(from_settings);
end

function qb.settings:default()
	local settings = {
		["settings"] = {
			["quest_ui"] = "default",
		},
		["reward_highlights"] = {},
		["auto_quest"] = {
			["enabled"] = true,
			["modifier"] = CTRL_KEY,
			["only_dailies"] = true,
			["low_level"] = true,
			["repeatable"] = true,
			["reward"] = QBT_REWARD_NONE,
		},
		["daily_quest_rewards"] = {},
		["quest_list_frames"] = {},
		["watch_frame"] = {
			["show_level"] = true,
			["show_abandon"] = true,
		},
		["minimap"] = {
			["show"] = true,
			["position"] = 310,
		},
	};
	
	for key, value in pairs(QBG_REWARDS) do
		settings.reward_highlights[key] = true;
	end

	if (not settings.quest_list_frame) then
		settings.quest_list_frame = {};
		settings.quest_list_frame.show = true;
		settings.quest_list_frame.position = {
			point = "TOPLEFT",
			relative_point = "TOPLEFT",
			x = 490,
			y = -330,
		};
		settings.quest_list_frame.locked = false;
		settings.quest_list_frame.state = "expanded";
		settings.quest_list_frame.show_find_group = true;
	end

	return settings;
end