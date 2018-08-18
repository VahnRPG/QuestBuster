-------------------------------------------------------------------------------
-- QuestBuster enUS Localization
-------------------------------------------------------------------------------
--if (GetLocale() == "enUS") then
	QBL["BROKER_INFO_DISABLED"] = "Disabled";
	QBL["BROKER_INFO_QUEST_LABEL"] = "Q: ";
	QBL["BROKER_INFO_LOW_LEVEL_LABEL"] = " L: ";
	QBL["BROKER_INFO_REWARD_LABEL"] = " R: ";
	QBL["BROKER_INFO_DAILIES"] = "Dailies";
	QBL["BROKER_INFO_ALL"] = "All";
	QBL["BROKER_INFO_YES"] = "Yes";
	QBL["BROKER_INFO_NO"] = "No";

	QBL["BINDING_TOGGLE_WORLD_QUESTS_FRAME"] = "Toggle World Quests Frame";
	QBL["BINDING_OPEN_SKILL_1"] = "Toggle Skill 1 Window";
	QBL["BINDING_OPEN_SKILL_1_BUSTER"] = "Toggle Skill 1 Buster Window";
	QBL["BINDING_OPEN_SKILL_2"] = "Toggle Skill 2 Window";
	QBL["BINDING_OPEN_SKILL_2_BUSTER"] = "Toggle Skill 2 Buster Window";
	QBL["BINDING_OPEN_COOKING"] = "Toggle Cooking Window";
	QBL["BINDING_OPEN_FIRST_AID"] = "Toggle First Aid Window";
	QBL["BINDING_OPEN_ARCHAEOLOGY"] = "Toggle Archaeology Window";
	QBL["BINDING_OPEN_LOCKPICKING_BUSTER"] = "Toggle Lockpicking Buster Window";
	
	QBL["BROKER_SETTINGS_PERSON"] = QBG_CLR_LIGHTGREY .. "   (personal settings)";
	QBL["BROKER_SETTINGS_GLOBAL"] = QBG_CLR_LIGHTGREY .. "   (global settings)";
	QBL["BROKER_QUESTS"] = QBG_CLR_LIGHTGREEN .. "Activate on Quests: " .. QBG_CLR_WHITE;
	QBL["BROKER_LOW_LEVEL"] = QBG_CLR_LIGHTGREEN .. "Also Low Level: " .. QBG_CLR_WHITE;
	QBL["BROKER_REWARD"] = QBG_CLR_LIGHTGREEN .. "Reward Selection: " .. QBG_CLR_WHITE;
	QBL["BROKER_MODIFIER"] = QBG_CLR_WHITE .. "Disable Key: ";
	QBL["BROKER_TOGGLE"] = QBG_CLR_WHITE .. "Left-click for " .. QBG_CLR_OFFBLUE .. "Toggle";
	QBL["BROKER_CONFIG"] = QBG_CLR_WHITE .. "Right-click for " .. QBG_CLR_OFFBLUE .. "Config";
	
	QBL["BROKER_WORLD_QUEST_COUNT"] = QBG_CLR_LIGHTGREEN .. "World Quests Available: ";
	QBL["BROKER_WORLD_QUEST_EMISSARY"] = QBG_CLR_LIGHTGREEN .. "Emissary Quests:";
	QBL["BROKER_WORLD_QUEST_MENU"] = QBG_CLR_WHITE .. "Left-click for " .. QBG_CLR_OFFBLUE .. "World Quests";
	
	QBL["DAILY_QUEST_REWARD"] = QBG_CLR_OFFBLUE .. "CTRL + Left-click " .. QBG_CLR_WHITE .. "to auto-select this item in the future";
	QBL["DAILY_QUEST_SELECTED_REWARD"] = QBG_CLR_LIGHTGREEN .. "Auto-selected item";
	
	QBL["WORLD_QUEST_HEADER"] = "World Quests";
	QBL["WORLD_QUEST_FACTIONS"] = "Quests by Faction";
	QBL["WORLD_QUEST_REWARDS"] = "Quests by Rewards";
	QBL["WORLD_QUEST_TIME"] = "Quests by Time Left";
	QBL["WORLD_QUEST_TYPES"] = "Quests by Type";
	QBL["WORLD_QUEST_ZONES"] = "Quests by Zone";
	QBL["WORLD_QUEST_TRACKING_TOOLTIP"] = QBG_CLR_OFFBLUE .. "Click to Toggle Tracking";
	QBL["WORLD_QUEST_TOMTOM"] = QBG_CLR_OFFBLUE .. "Add TomTom Waypoint to\n";
	QBL["WORLD_QUEST_FIND_GROUP"] = QBG_CLR_OFFBLUE .. "Find Group for\n";
	
	QBL["EMISSARY_PENDING"] = QBG_CLR_RED .. "Pending";
	
	QBL["CONFIG_SETTINGS_TYPE"] = "Settings Type:";
	QBL["CONFIG_SHOW_MINIMAP"] = "Show Minimap Button";
	QBL["CONFIG_TITLE_HIGHLIGHT_REWARD"] = "Highlight Rewards";
	QBL["CONFIG_AUTO_QUEST_ENABLED"] = "Automatically Complete Quests";
	QBL["CONFIG_AUTO_QUEST_ONLY_DAILIES"] = "Only Auto Complete Dailies";
	QBL["CONFIG_AUTO_QUEST_LOW_LEVEL"] = "Auto Complete Low Level Quests";
	QBL["CONFIG_AUTO_QUEST_REPEATABLE"] = "Auto Complete Repeatable Quests";
	QBL["CONFIG_TITLE_AUTO_QUEST_REWARD"] = "Auto Complete Reward Select:";
	QBL["CONFIG_TITLE_DAILY_QUEST_REWARD"] = "Daily Quest Auto-Select Rewards:";
	QBL["CONFIG_TITLE_DAILY_QUEST_ITEM_ERROR"] = QBG_CLR_RED .. "ERROR - " .. QBG_CLR_OFFBLUE .. "Quest"  .. QBG_CLR_WHITE .. " #";
	QBL["CONFIG_TITLE_DAILY_QUEST_NONE"] = QBG_CLR_WHITE .. "None selected. " .. QBG_CLR_OFFBLUE .. "CTRL + Left-click " .. QBG_CLR_WHITE .. "on a reward item to add to auto-select list.";
	QBL["CONFIG_TITLE_AUTO_QUEST_MODIFIER"] = "Button to Prevent Auto Complete:";
	QBL["CONFIG_SHOW_LEVEL"] = "Show Quest Levels";
	QBL["CONFIG_SHOW_ABANDON"] = "Show Abandon Quest";
	QBL["CONFIG_WORLD_QUESTS_SHOW"] = "Show World Quests";
	QBL["CONFIG_WORLD_QUESTS_LOCKED"] = "Lock World Quests Frame";
	QBL["CONFIG_WORLD_QUESTS_EXPAND"] = "Expand World Quests Frame";
	QBL["CONFIG_WORLD_QUESTS_POSITION"] = "Position";
	QBL["CONFIG_POSITION_X"] = "X:";
	QBL["CONFIG_POSITION_Y"] = "Y:";
	QBL["CONFIG_POSITION_SET"] = "SET";
	QBL["CONFIG_POSITIONS_RESET"] = "Reset Position";

	-- Minimap Localization
	QBL["MINIMAP_HOVER_LINE1"] = QBG_CLR_WHITE .. "Left button to " .. QBG_CLR_LIGHTGREEN .. "Drag";
	QBL["MINIMAP_HOVER_LINE2"] = QBG_CLR_WHITE .. "Right-click for " .. QBG_CLR_OFFBLUE .. "Config";
--end