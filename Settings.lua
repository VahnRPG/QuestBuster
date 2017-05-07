local DB_VERSION = 0.06;

QuestBusterOptions = {};
QuestBusterEntry = nil;

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
	qb.settings.player.name = UnitName("player");
	qb.settings.player.level = UnitLevel("player");
	qb.settings.player.server = GetRealmName();
	QuestBusterEntry = qb.settings.player.name .. "@" .. qb.settings.player.server;
	
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
	end
	if (not QuestBusterOptions[QuestBusterEntry] or reset == "character") then
		QuestBusterOptions[QuestBusterEntry] = qb.omg:clone_table(qb.settings:default());
	end

	local _, player_class = UnitClass("player");
	if (player_class == "ROGUE") then
		QuestBusterOptions[QuestBusterEntry].skills_frame.bars.lockpicking = true;
	end

	qb.settings:versionSettings();
end

function qb.settings:versionSettings()
	local settings = qb.settings:get();

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

	for _, frame_data in pairs(QBG_QUEST_LIST_FRAMES) do
		if (not settings.quest_list_frames[frame_data["name"]]) then
			settings.quest_list_frames[frame_data["name"]] = {};
			settings.quest_list_frames[frame_data["name"]].show = true;
			settings.quest_list_frames[frame_data["name"]].position = {
				point = "TOPLEFT",
				relative_point = "TOPLEFT",
				x = 490,
				y = -330,
			};
			settings.quest_list_frames[frame_data["name"]].locked = false;
			settings.quest_list_frames[frame_data["name"]].state = "expanded";
		end
	end

	return settings;
end