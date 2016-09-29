-------------------------------------------------------------------------------
-- QuestBuster enUS Localization
-------------------------------------------------------------------------------
--if (GetLocale() == "enUS") then
	QBL["TITAN_INFO_DISABLED"] = "Disabled";
	QBL["TITAN_INFO_QUEST_LABEL"] = "Q: ";
	QBL["TITAN_INFO_LOW_LEVEL_LABEL"] = " L: ";
	QBL["TITAN_INFO_REWARD_LABEL"] = " R: ";
	QBL["TITAN_INFO_DAILIES"] = "Dailies";
	QBL["TITAN_INFO_ALL"] = "All";
	QBL["TITAN_INFO_YES"] = "Yes";
	QBL["TITAN_INFO_NO"] = "No";

	QBL["BINDING_TOGGLE_WORLD_QUESTS_FRAME"] = "Toggle World Quests Frame";
	QBL["BINDING_OPEN_SKILL_1"] = "Toggle Skill 1 Window";
	QBL["BINDING_OPEN_SKILL_1_BUSTER"] = "Toggle Skill 1 Buster Window";
	QBL["BINDING_OPEN_SKILL_2"] = "Toggle Skill 2 Window";
	QBL["BINDING_OPEN_SKILL_2_BUSTER"] = "Toggle Skill 2 Buster Window";
	QBL["BINDING_OPEN_COOKING"] = "Toggle Cooking Window";
	QBL["BINDING_OPEN_FIRST_AID"] = "Toggle First Aid Window";
	QBL["BINDING_OPEN_ARCHAEOLOGY"] = "Toggle Archaeology Window";
	QBL["BINDING_OPEN_LOCKPICKING_BUSTER"] = "Toggle Lockpicking Buster Window";
	
	QBL["TITAN_SETTINGS_PERSON"] = QBG_CLR_LIGHTGREY .. "   (personal settings)";
	QBL["TITAN_SETTINGS_GLOBAL"] = QBG_CLR_LIGHTGREY .. "   (global settings)";
	QBL["TITAN_QUESTS"] = QBG_CLR_LIGHTGREEN .. "Activate on Quests: " .. QBG_CLR_WHITE;
	QBL["TITAN_LOW_LEVEL"] = QBG_CLR_LIGHTGREEN .. "Also Low Level: " .. QBG_CLR_WHITE;
	QBL["TITAN_REWARD"] = QBG_CLR_LIGHTGREEN .. "Reward Selection: " .. QBG_CLR_WHITE;
	QBL["TITAN_MODIFIER"] = QBG_CLR_WHITE .. "Disable Key: ";
	QBL["TITAN_TOGGLE"] = QBG_CLR_WHITE .. "Left-click for " .. QBG_CLR_OFFBLUE .. "Toggle";
	QBL["TITAN_CONFIG"] = QBG_CLR_WHITE .. "Right-click for " .. QBG_CLR_OFFBLUE .. "Config";
	
	QBL["DAILY_QUEST_REWARD"] = QBG_CLR_OFFBLUE .. "CTRL + Left-click " .. QBG_CLR_WHITE .. "to auto-select this item in the future";
	QBL["DAILY_QUEST_SELECTED_REWARD"] = QBG_CLR_LIGHTGREEN .. "Auto-selected item";
	
	QBL["WORLD_QUEST_FACTIONS"] = "Quests by Faction";
	QBL["WORLD_QUEST_REWARDS"] = "Quests by Rewards";
	QBL["WORLD_QUEST_TYPES"] = "Quests by Type";
	QBL["WORLD_QUEST_ZONES"] = "Quests by Zone";
	
	QBL["CONFIG_SETTINGS_TYPE"] = "Settings Type:";
	QBL["CONFIG_SHOW_MINIMAP"] = "Show Minimap Button";
	QBL["CONFIG_TITLE_HIGHLIGHT_REWARD"] = "Highlight Rewards";
	QBL["CONFIG_AUTO_QUEST_ENABLED"] = "Automatically Complete Quests";
	QBL["CONFIG_AUTO_QUEST_ONLY_DAILIES"] = "Only Auto Complete Dailies";
	QBL["CONFIG_AUTO_QUEST_LOW_LEVEL"] = "Auto Complete Low Level Quests";
	QBL["CONFIG_AUTO_QUEST_REPEATABLE"] = "Auto Complete Repeatable Quests";
	QBL["CONFIG_TITLE_AUTO_QUEST_REWARD"] = "Auto Complete Reward Select:";
	QBL["CONFIG_TITLE_DAILY_QUEST_REWARD"] = "Daily Quest Auto-select Rewards:";
	QBL["CONFIG_TITLE_DAILY_QUEST_ITEM_ERROR"] = QBG_CLR_RED .. "ERROR - " .. QBG_CLR_OFFBLUE .. "Quest"  .. QBG_CLR_WHITE .. " #";
	QBL["CONFIG_TITLE_DAILY_QUEST_NONE"] = QBG_CLR_WHITE .. "None selected. " .. QBG_CLR_OFFBLUE .. "CTRL + Left-click " .. QBG_CLR_WHITE .. "on a reward item to add to auto-select list.";
	QBL["CONFIG_TITLE_AUTO_QUEST_MODIFIER"] = "Button to Prevent Auto Complete:";
	QBL["CONFIG_SHOW_LEVEL"] = "Show Quest Levels";
	QBL["CONFIG_SHOW_ABANDON"] = "Show Abandon Quest";
--end