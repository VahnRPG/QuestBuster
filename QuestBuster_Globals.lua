-------------------------------------------------------------------------------
-- QuestBuster Globals
-------------------------------------------------------------------------------
QBG_MOD_NAME = "QuestBuster";
QBG_VERSION = GetAddOnMetadata(QBG_MOD_NAME, "Version");
QBG_LAST_UPDATED = GetAddOnMetadata(QBG_MOD_NAME, "X-Date");

QBG_HAS_MOGIT = IsAddOnLoaded("MogIt");
QBG_GOSSIP_PARAMS = 6;

QBG_REWARDS = {};
QBG_REWARDS[QBT_REWARD_NONE] = { label="None", sel_func=function() end };
QBG_REWARDS[QBT_REWARD_PRICE] = { label="Max Sell Price", sel_func=function() return QuestBuster_Loot_GetBestPriceReward() end, r=0, g=0.55, b=0 };
QBG_REWARDS[QBT_REWARD_UPGRADE] = { label="Upgrade", sel_func=function() return QuestBuster_Loot_GetUpgrade() end, r=0.96, g=1, b=0.55 };
if (QBG_HAS_MOGIT) then
	QBG_REWARDS[QBT_REWARD_TRANSMOG] = { label="Transmog", sel_func=function() return QuestBuster_Loot_GetTransmogItem() end, r=0.55, g=0, b=0.55 };
end
QBG_REWARDS[QBT_REWARD_AUTOSELECT] = { label="Auto Selected", sel_func=function() end, r=0.55, g=0.55, b=0 };

QBG_LEVEL_fORMAT = "[%d%s%s] %s";
--Built from http://www.wowinterface.com/forums/showthread.php?t=44549
QBG_QUEST_TYPES = {
	[0] = "",		--Default
	[1] = "G",		--Group
	[41] = "P",		--PvP
	[62] = "R",		--Raid
	[81] = "D",		--Dungeon
	[83] = "L",		--Legendary
	[85] = "H",		--Heroic 
	[98] = "S",		--Scenario
	[102] = "A",	--Account
};

-------------------------------------------------------------------------------
-- Colors
-------------------------------------------------------------------------------
QBG_CLR_MIN_ALPHA = "|c00"
QBG_CLR_MAX_ALPHA = "|cff"
QBG_CLR_DEFAULT = QBG_CLR_MAX_ALPHA .. "ffff00";
QBG_CLR_WHITE = QBG_CLR_MAX_ALPHA .. "ffffff";
QBG_CLR_RED = QBG_CLR_MAX_ALPHA .. "ff0000";
QBG_CLR_BLUE = QBG_CLR_MAX_ALPHA .. "0000ff";
QBG_CLR_OFFBLUE = QBG_CLR_MAX_ALPHA .. "00d9ec";
QBG_CLR_DARKBLUE = QBG_CLR_MAX_ALPHA .. "0066cc";
QBG_CLR_LIGHTGREY = QBG_CLR_MAX_ALPHA .. "bbbbbb";
QBG_CLR_LIGHTGREEN = QBG_CLR_MAX_ALPHA .. "20ff20";
QBG_CLR_ORANGE = QBG_CLR_MAX_ALPHA .. "ffaa00";

QBG_MOD_COLOR = QBG_CLR_MAX_ALPHA .. "ee2299";