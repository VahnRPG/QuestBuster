-------------------------------------------------------------------------------
-- QuestBuster Globals
-------------------------------------------------------------------------------
QBG_MOD_NAME = "QuestBuster";
QBG_VERSION = GetAddOnMetadata(QBG_MOD_NAME, "Version");
QBG_LAST_UPDATED = GetAddOnMetadata(QBG_MOD_NAME, "X-Date");

QBG_HAS_MOGIT = IsAddOnLoaded("MogIt");
QBG_HAS_TOMTOM = IsAddOnLoaded("TomTom");
QBG_GOSSIP_PARAMS = 6;

QBG_REWARDS = {};

QBG_LEVEL_FORMAT = "[%d%s%s] %s";
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

QBG_WORLD_QUEST_TYPES = {
	[LE_QUEST_TAG_TYPE_PVP]			= "PVP",
	[LE_QUEST_TAG_TYPE_PET_BATTLE]	= "Pet Battle",
	[LE_QUEST_TAG_TYPE_PROFESSION]	= "Profession",
	[LE_QUEST_TAG_TYPE_DUNGEON]		= "Dungeon",
};

QBG_QUEST_LIST_FRAMES = {
	[1] = {
		["name"] = "Default",
		["label"] = "Default",
		["parent"] = UIParent,
		["strata"] = "LOW",
		["tooltip"] = GameTooltip,
	},
	[2] = {
		["name"] = "WorldMap",
		["label"] = "World Map",
		["parent"] = WorldMapFrame,
		["strata"] = "FULLSCREEN_DIALOG",
		["tooltip"] = WorldMapTooltip,
	},
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

-------------------------------------------------------------------------------
-- Map IDs
-------------------------------------------------------------------------------
QBG_MAP_IDS = {
	13,		--Kalimdor
	772,	--Ahn'Qiraj: The Fallen Kingdom
	894,	--Ammen Vale
	43,		--Ashenvale
	181,	--Azshara
	464,	--Azuremyst Isle
	476,	--Bloodmyst Isle
	890,	--Camp Narache
	42,		--Darkshore
	381,	--Darnassus
	101,	--Desolace
	4,		--Durotar
	141,	--Dustwallow Marsh
	891,	--Echo Isles
	182,	--Felwood
	121,	--Feralas
	795,	--Molten Front
	241,	--Moonglade
	606,	--Mount Hyjal
	9,		--Mulgore
	11,		--Northern Barrens
	321,	--Orgrimmar
	888,	--Shadowglen
	261,	--Silithus
	607,	--Southern Barrens
	81,		--Stonetalon Mountains
	161,	--Tanaris
	41,		--Teldrassil
	471,	--The Exodar
	61,		--Thousand Needles
	362,	--Thunder Bluff
	720,	--Uldum
	201,	--Un'Goro Crater
	889,	--Valley of Trials
	281,	--Winterspring

	14,		--Eastern Kingdoms
	614,	--Abyssal Depths
	16,		--Arathi Highlands
	17,		--Badlands
	19,		--Blasted Lands
	29,		--Burning Steppes
	866,	--Coldridge Valley
	32,		--Deadwind Pass
	892,	--Deathknell
	27,		--Dun Morogh
	34,		--Duskwood
	23,		--Eastern Plaguelands
	30,		--Elwynn Forest
	462,	--Eversong Woods
	463,	--Ghostlands
	545,	--Gilneas
	611,	--Gilneas City
	24,		--Hillsbrad Foothills
	341,	--Ironforge
	499,	--Isle of Quel'Danas
	610,	--Kelp'thar Forest
	35,		--Loch Modan
	895,	--New Tinkertown
	37,		--Northern Stranglethorn
	864,	--Northshire
	36,		--Redridge Mountains
	684,	--Ruins of Gilneas
	685,	--Ruins of Gilneas City
	28,		--Searing Gorge
	615,	--Shimmering Expanse
	480,	--Silvermoon City
	21,		--Silverpine Forest
	301,	--Stormwind City
	689,	--Stranglethorn Vale
	893,	--Sunstrider Isle
	38,		--Swamp of Sorrows
	673,	--The Cape of Stranglethorn
	26,		--The Hinterlands
	502,	--The Scarlet Enclave
	20,		--Tirisfal Glades
	708,	--Tol Barad
	709,	--Tol Barad Peninsula
	700,	--Twilight Highlands
	382,	--Undercity
	613,	--Vashj'ir
	22,		--Western Plaguelands
	39,		--Westfall
	40,		--Wetlands

	466,	--Outland
	475,	--Blade's Edge Mountains
	465,	--Hellfire Peninsula
	477,	--Nagrand
	479,	--Netherstorm
	473,	--Shadowmoon Valley
	481,	--Shattrath City
	478,	--Terokkar Forest
	467,	--Zangarmarsh

	485,	--Northrend
	486,	--Borean Tundra
	510,	--Crystalsong Forest
	504,	--Dalaran
	488,	--Dragonblight
	490,	--Grizzly Hills
	491,	--Howling Fjord
	541,	--Hrothgar's Landing
	492,	--Icecrown
	493,	--Sholazar Basin
	495,	--The Storm Peaks
	501,	--Wintergrasp
	496,	--Zul'Drak

	751,	--The Maelstrom
	640,	--Deepholm
	605,	--Kezan
	544,	--The Lost Isles
	737,	--The Maelstrom

	862,	--Pandaria
	858,	--Dread Wastes
	929,	--Isle of Giants
	928,	--Isle of Thunder
	857,	--Krasarang Wilds
	809,	--Kun-Lai Summit
	905,	--Shrine of Seven Stars
	903,	--Shrine of Two Moons
	806,	--The Jade Forest
	873,	--The Veiled Stair
	808,	--The Wandering Isle
	951,	--Timeless Isle
	810,	--Townlong Steppes
	811,	--Vale of Eternal Blossoms
	807,	--Valley of the Four Winds

	962,	--Draenor
	978,	--Ashran
	941,	--Frostfire Ridge
	976,	--Frostwall
	949,	--Gorgrond
	971,	--Lunarfall
	950,	--Nagrand
	947,	--Shadowmoon Valley
	948,	--Spires of Arak
	1009,	--Stormshield
	946,	--Talador
	945,	--Tanaan Jungle
	970,	--Tanaan Jungle - Assault on the Dark Portal
	1011,	--Warspear

	1007,	--Broken Isles
	1015,	--Aszuna
	1021,	--Broken Shore
	1014,	--Dalaran
	1098,	--Eye of Azshara
	1024,	--Highmountain
	1017,	--Stormheim
	1033,	--Suramar
	1018,	--Val'sharah
	
	1068,	--Hall of the Guardian - Mage Order Hall
	1052,	--Mardum, the Shattered Abyss - Demon Hunter
	1040,	--Netherlight Temple - Priest Order Hall
	1035,	--Skyhold - Warrior Order Hall
	1077,	--The Dreamgrove - Druid Order Hall
	1057,	--The Heart of Azeroth - Shaman Order Hall
	1044,	--The Wandering Isle - Monk Order Hall
	1072,	--Trueshot Lodge - Hunter Order Hall

	401,	--Alterac Valley
	461,	--Arathi Basin
	935,	--Deepwind Gorge
	482,	--Eye of the Storm
	540,	--Isle of Conquest
	860,	--Silvershard Mines
	512,	--Strand of the Ancients
	856,	--Temple of Kotmogu
	736,	--The Battle for Gilneas
	626,	--Twin Peaks
	443,	--Warsong Gulch

	878,	--A Brewing Storm
	912,	--A Little Patience
	899,	--Arena of Annihilation
	883,	--Assault on Zan'vess
	940,	--Battle on the High Seas
	939,	--Blood in the Snow
	884,	--Brewmoon Festival
	955,	--Celestial Tournament
	900,	--Crypt of Forgotten Kings
	914,	--Dagger in the Dark
	937,	--Dark Heart of Pandaria
	920,	--Domination Point (H)
	880,	--Greenstone Village
	911,	--Lion's Landing (A)
	938,	--The Secrets of Ragefire
	906,	--Theramore's Fall (A)
	851,	--Theramore's Fall (H)
	882,	--Unga Ingoo

	688,	--Blackfathom Deeps
	704,	--Blackrock Depths
	721,	--Blackrock Spire
	699,	--Dire Maul
	691,	--Gnomeregan
	750,	--Maraudon
	680,	--Ragefire Chasm
	760,	--Razorfen Downs
	761,	--Razorfen Kraul
	764,	--Shadowfang Keep
	765,	--Stratholme
	756,	--The Deadmines
	690,	--The Stockade
	687,	--The Temple of Atal'Hakkar
	692,	--Uldaman
	749,	--Wailing Caverns
	686,	--Zul'Farrak

	755,	--Blackwing Lair
	696,	--Molten Core
	717,	--Ruins of Ahn'Qiraj
	766,	--Temple of Ahn'Qiraj

	722,	--Auchenai Crypts
	797,	--Hellfire Ramparts
	798,	--Magisters' Terrace
	732,	--Mana-Tombs
	734,	--Old Hillsbrad Foothills
	723,	--Sethekk Halls
	724,	--Shadow Labyrinth
	731,	--The Arcatraz
	733,	--The Black Morass
	725,	--The Blood Furnace
	729,	--The Botanica
	730,	--The Mechanar
	710,	--The Shattered Halls
	728,	--The Slave Pens
	727,	--The Steamvault
	726,	--The Underbog

	796,	--Black Temple
	776,	--Gruul's Lair
	775,	--Hyjal Summit
	799,	--Karazhan
	779,	--Magtheridon's Lair
	780,	--Serpentshrine Cavern
	789,	--Sunwell Plateau
	782,	--The Eye

	522,	--Ahn'kahet: The Old Kingdom
	533,	--Azjol-Nerub
	534,	--Drak'Tharon Keep
	530,	--Gundrak
	525,	--Halls of Lightning
	603,	--Halls of Reflection
	526,	--Halls of Stone
	602,	--Pit of Saron
	521,	--The Culling of Stratholme
	601,	--The Forge of Souls
	520,	--The Nexus
	528,	--The Oculus
	536,	--The Violet Hold
	542,	--Trial of the Champion
	523,	--Utgarde Keep
	524,	--Utgarde Pinnacle

	604,	--Icecrown Citadel
	535,	--Naxxramas
	718,	--Onyxia's Lair
	527,	--The Eye of Eternity
	531,	--The Obsidian Sanctum
	609,	--The Ruby Sanctum
	543,	--Trial of the Crusader
	529,	--Ulduar
	532,	--Vault of Archavon

	753,	--Blackrock Caverns
	820,	--End Time
	757,	--Grim Batol
	759,	--Halls of Origination
	819,	--Hour of Twilight
	747,	--Lost City of the Tol'vir
	768,	--The Stonecore
	769,	--The Vortex Pinnacle
	767,	--Throne of the Tides
	816,	--Well of Eternity
	781,	--Zul'Aman
	793,	--Zul'Gurub

	752,	--Baradin Hold
	754,	--Blackwing Descent
	824,	--Dragon Soul
	800,	--Firelands
	758,	--The Bastion of Twilight
	773,	--Throne of the Four Winds

	875,	--Gate of the Setting Sun
	885,	--Mogu'Shan Palace
	871,	--Scarlet Halls
	874,	--Scarlet Monastery
	898,	--Scholomance
	877,	--Shado-pan Monastery
	887,	--Siege of Niuzao Temple
	876,	--Stormstout Brewery
	867,	--Temple of the Jade Serpent

	897,	--Heart of Fear
	896,	--Mogu'shan Vaults
	953,	--Siege of Orgrimmar
	886,	--Terrace of Endless Spring
	930,	--Throne of Thunder

	984,	--Auchindoun
	964,	--Bloodmaul Slag Mines
	993,	--Grimrail Depot
	987,	--Iron Docks
	969,	--Shadowmoon Burial Grounds
	989,	--Skyreach
	1008,	--The Everbloom
	995,	--Upper Blackrock Spire

	994,	--Highmaul
	988,	--Blackrock Foundry
	1026,	--Hellfire Citadel
	
	1081,	--Black Rook Hold
	1087,	--Court of Stars
	1067,	--Darkheart Thicket
	1046,	--Eye of Azshara
	1041,	--Halls of Valor
	1042,	--Maw of Souls
	1065,	--Neltharion's Lair
	1079,	--The Arcway
	1045,	--Vault of the Wardens
	1066,	--Violet Hold

	1094,	--The Emerald Nightmare
	1088,	--The Nighthold
};