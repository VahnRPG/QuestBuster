-------------------------------------------------------------------------------
-- QuestBuster Globals
-------------------------------------------------------------------------------
QBG_MOD_NAME = "QuestBuster";
QBG_VERSION = GetAddOnMetadata(QBG_MOD_NAME, "Version");
QBG_LAST_UPDATED = GetAddOnMetadata(QBG_MOD_NAME, "X-Date");

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
	[LE_QUEST_TAG_TYPE_DUNGEON]		= "Dungeon",
	[LE_QUEST_TAG_TYPE_INVASION]	= "Invasion",
	[LE_QUEST_TAG_TYPE_PVP]			= "PVP",
	[LE_QUEST_TAG_TYPE_PET_BATTLE]	= "Pet Battle",
	[LE_QUEST_TAG_TYPE_PROFESSION]	= "Profession",
	[LE_QUEST_TAG_TYPE_RAID]		= "Raid",
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
-- uiMapIDs
--   Normally generated from: https://wow.gamepedia.com/MapID
-------------------------------------------------------------------------------
QBG_MAP_IDS = {
	12,	--Kalimdor
		1,	--Durotar
			85,	--Orgrimmar
				213,	--Ragefire Chasm
				503,	--Brawl'gar Arena
				522,	--The Secrets of Ragefire
			461,	--Valley of Trials
			463,	--Echo Isles
		7,	--Mulgore
			462,	--Camp Narache
		10,	--Northern Barrens
			92,	--Warsong Gulch
			279,	--Wailing Caverns
		57,	--Teldrassil
			460,	--Shadowglen
		62,	--Darkshore
		63,	--Ashenvale
			221,	--Blackfathom Deeps
		64,	--Thousand Needles
			300,	--Razorfen Downs
		65,	--Stonetalon Mountains
		66,	--Desolace
			280,	--Maraudon
		69,	--Feralas
			234,	--Dire Maul
		70,	--Dustwallow Marsh
			248,	--Onyxia's Lair
		71,	--Tanaris
			130,	--The Culling of Stratholme
			219,	--Zul'Farrak
			398,	--Well of Eternity
			399,	--Hour of Twilight
			401,	--End Time
			409,	--Dragon Soul
		76,	--Azshara
		77,	--Felwood
		78,	--Un'Goro Crater
		80,	--Moonglade
		81,	--Silithus
			247,	--Ruins of Ahn'Qiraj
			319,	--Ahn'Qiraj
			904,	--Silithus Brawl
			1021,	--Chamber of Heart
		83,	--Winterspring
		88,	--Thunder Bluff
		89,	--Darnassus
		97,	--Azuremyst Isle
			468,	--Ammen Vale
		103,	--The Exodar
		106,	--Bloodmyst Isle
		198,	--Mount Hyjal
			338,	--Molten Front
			367,	--Firelands
			760,	--Malorne's Nightmare
		199,	--Southern Barrens
			301,	--Razorfen Kraul
		249,	--Uldum
			277,	--Lost City of the Tol'vir
			297,	--Halls of Origination
			325,	--The Vortex Pinnacle
			328,	--Throne of the Four Winds
			716,	--Skywall
		327,	--Ahn'Qiraj: The Fallen Kingdom
		524,	--Battle on the High Seas
		782,	--The Emerald Nightmare
		891,	--Azuremyst Isle (3)
		907,	--Seething Shore
	13,	--Eastern Kingdoms
		14,	--Arathi Highlands
			93,	--Arathi Basin
		15,	--Badlands
			230,	--Uldaman
		17,	--Blasted Lands
		18,	--Tirisfal Glades
			302,	--Scarlet Monastery
			431,	--Scarlet Halls
			465,	--Deathknell
		21,	--Silverpine Forest
			310,	--Shadowfang Keep
		22,	--Western Plaguelands
			306,	--ScholomanceOLD
			476,	--Scholomance
			827,	--Stratholme
		23,	--Eastern Plaguelands
			124,	--Plaguelands: The Scarlet Enclave
		25,	--Hillsbrad Foothills
			91,	--Alterac Valley
			623,	--Hillsbrad Foothills (Southshore vs. Tarren Mill)
		26,	--The Hinterlands
		27,	--Dun Morogh
			226,	--Gnomeregan
			427,	--Coldridge Valley
			469,	--New Tinkertown
		32,	--Searing Gorge
			242,	--Blackrock Depths
		36,	--Burning Steppes
			232,	--Molten Core
			250,	--Blackrock Spire
			283,	--Blackrock Caverns
			285,	--Blackwing Descent
			287,	--Blackwing Lair
			616,	--Upper Blackrock Spire
			838,	--Battle for Blackrock Mountain
		37,	--Elwynn Forest
			425,	--Northshire
		42,	--Deadwind Pass
			350,	--Karazhan
		47,	--Duskwood
		48,	--Loch Modan
		49,	--Redridge Mountains
		224,	--Stranglethorn Vale
			50,	--Northern Stranglethorn
				233,	--Zul'Gurub
			210,	--The Cape of Stranglethorn
			423,	--Silvershard Mines
		51,	--Swamp of Sorrows
			220,	--The Temple of Atal'Hakkar
		52,	--Westfall
			291,	--The Deadmines
		56,	--Wetlands
		84,	--Stormwind City
			225,	--The Stockade
			499,	--Deeprun Tram
		87,	--Ironforge
		90,	--Undercity
		94,	--Eversong Woods
			467,	--Sunstrider Isle
				335,	--Sunwell Plateau
					973,	--The Sunwell
		95,	--Ghostlands
			333,	--Zul'Aman
		110,	--Silvermoon City
		122,	--Isle of Quel'Danas
			348,	--Magisters' Terrace
		179,	--Gilneas
			202,	--Gilneas City
			275,	--The Battle for Gilneas
		203,	--Vashj'ir
			201,	--Kelp'thar Forest
			204,	--Abyssal Depths
				322,	--Throne of the Tides
				742,	--Abyssal Maw
			205,	--Shimmering Expanse
		241,	--Twilight Highlands
			206,	--Twin Peaks
			293,	--Grim Batol
			294,	--The Bastion of Twilight
		217,	--Ruins of Gilneas
		218,	--Ruins of Gilneas City
		244,	--Tol Barad
			282,	--Baradin Hold
		245,	--Tol Barad Peninsula
		501,	--Dalaran
		908,	--Ruins of Lordaeron
	113,	--Northrend
		114,	--Borean Tundra
			129,	--The Nexus
			141,	--The Eye of Eternity
			142,	--The Oculus
			736,	--The Beyond
		115,	--Dragonblight
			128,	--Strand of the Ancients
			132,	--Ahn'kahet: The Old Kingdom
			155,	--The Obsidian Sanctum
			157,	--Azjol-Nerub
			162,	--Naxxramas
			200,	--The Ruby Sanctum
		116,	--Grizzly Hills
			757,	--Ursoc's Lair
		117,	--Howling Fjord
			133,	--Utgarde Keep
			136,	--Utgarde Pinnacle
		118,	--Icecrown
			169,	--Isle of Conquest
			171,	--Trial of the Champion
			172,	--Trial of the Crusader
			183,	--The Forge of Souls
			184,	--Pit of Saron
			185,	--Halls of Reflection
			186,	--Icecrown Citadel
		119,	--Sholazar Basin
			888,	--Hall of Communion
		120,	--The Storm Peaks
			138,	--Halls of Lightning
			140,	--Halls of Stone
			147,	--Ulduar
		121,	--Zul'Drak
			153,	--Gundrak
			160,	--Drak'Tharon Keep
		123,	--Wintergrasp
			156,	--Vault of Archavon
		127,	--Crystalsong Forest
			125,	--Dalaran (3)
				168,	--The Violet Hold
		170,	--Hrothgar's Landing
		871,	--The Lost Glacier
		897,	--The Deaths of Chromie
	948,	--The Maelstrom
		174,	--The Lost Isles
		194,	--Kezan
			1010,	--The MOTHERLODE!!
		207,	--Deepholm
			324,	--The Stonecore
	424,	--Pandaria
		371,	--The Jade Forest
			429,	--Temple of the Jade Serpent
			447,	--A Brewing Storm
		376,	--Valley of the Four Winds
			439,	--Stormstout Brewery
			519,	--Deepwind Gorge
		379,	--Kun-Lai Summit
			443,	--Shado-Pan Monastery
			452,	--Brewmoon Festival
			480,	--Proving Grounds
			481,	--Crypt of Forgotten Kings
			489,	--Dagger in the Dark
			843,	--Shado-Pan Showdown
		388,	--Townlong Steppes
			457,	--Siege of Niuzao Temple
		390,	--Vale of Eternal Blossoms
			417,	--Temple of Kotmogu
			437,	--Gate of the Setting Sun
			453,	--Mogu'shan Palace
			471,	--Mogu'shan Vaults
			556,	--Siege of Orgrimmar
		418,	--Krasarang Wilds
			450,	--Unga Ingoo
			487,	--A Little Patience
		422,	--Dread Wastes
			451,	--Assault on Zan'vess
			474,	--Heart of Fear
		433,	--The Veiled Stair
			456,	--Terrace of Endless Spring
		504,	--Isle of Thunder
			508,	--Throne of Thunder
			518,	--Thunder King's Citadel
		507,	--Isle of Giants
		516,	--Isle of Thunder (2)
		554,	--Timeless Isle
			571,	--Celestial Tournament
	378,	--The Wandering Isle
	407,	--Darkmoon Island
	619,	--Broken Isles
		627,	--Dalaran (7)
			732,	--Violet Hold
			734,	--Hall of the Guardian
		630,	--Azsuna
			677,	--Vault of the Wardens
			713,	--Eye of Azshara
		634,	--Stormheim
			649,	--Helheim
			694,	--Helmouth Shallows
			703,	--Halls of Valor
			706,	--Helmouth Cliffs
			806,	--Trial of Valor
			877,	--Fields of the Eternal Hunt
		641,	--Val'sharah
			747,	--The Dreamgrove
				715,	--Emerald Dreamway
			733,	--Darkheart Thicket
			751,	--Black Rook Hold
			758,	--Gloaming Reef
		645,	--Twisting Nether
		646,	--Broken Shore
			845,	--Cathedral of Eternal Night
			850,	--Tomb of Sargeras
		650,	--Highmountain
			731,	--Neltharion's Lair
			739,	--Trueshot Lodge
			750,	--Thunder Totem
			826,	--Cave of the Bloodtotem
		671,	--The Cove of Nashal
		672,	--Mardum, the Shattered Abyss
		680,	--Suramar
			749,	--The Arcway
			761,	--Court of Stars
			764,	--The Nighthold
		695,	--Skyhold
		702,	--Netherlight Temple
		714,	--Niskara
		717,	--Dreadscar Rift
		719,	--Mardum, the Shattered Abyss (5)
		740,	--Shadowgore Citadel
		905,	--Argus
			830,	--Krokuun
				940,	--The Vindicaar
			882,	--Mac'Aree
				903,	--The Seat of the Triumvirate
			885,	--Antoran Wastes
				909,	--Antorus, the Burning Throne
			921,	--Invasion Point: Aurinor
			922,	--Invasion Point: Bonich
			923,	--Invasion Point: Cen'gar
			924,	--Invasion Point: Naigtal
			925,	--Invasion Point: Sangua
			926,	--Invasion Point: Val
			927,	--Greater Invasion Point: Pit Lord Vilemus
			928,	--Greater Invasion Point: Mistress Alluradel
			929,	--Greater Invasion Point: Matron Folnuna
			930,	--Greater Invasion Point: Inquisitor Meto
			931,	--Greater Invasion Point: Sotanathor
			932,	--Greater Invasion Point: Occularus
		858,	--Assault on Broken Shore
		971,	--Telogrus Rift
	824,	--Islands
	875,	--Zandalar
		862,	--Zuldazar
			934,	--Atal'Dazar
			1004,	--Kings' Rest
			1165,	--Dazar'alor
				1166,	--Zanchul
			1177,	--Breath Of Pa'ku
		863,	--Nazmir
			1042,	--The Underrot
			1148,	--Uldir
		864,	--Vol'dun
			1038,	--Temple of Sethraliss
	876,	--Kul Tiras
		895,	--Tiragarde Sound
			974,	--Tol Dagor
			1161,	--Boralus
			1162,	--Siege of Boralus
		896,	--Drustvar
			1015,	--Waycrest Manor
			1029,	--WaycrestDimension
			1045,	--Thros, The Blighted Lands
		936,	--Freehold
		942,	--Stormsong Valley
			1039,	--Shrine of the Storm
			1182,	--SalstoneMine_Stormsong
			1183,	--Thornheart
	938,	--Gilneas Island
	939,	--Tropical Isle 8.0
	981,	--Un'gol Ruins
	1156,	--The Great Sea
	100,	--Hellfire Peninsula
		246,	--The Shattered Halls
		261,	--The Blood Furnace
		331,	--Magtheridon's Lair
		347,	--Hellfire Ramparts
	102,	--Zangarmarsh
		262,	--The Underbog
		263,	--The Steamvault
		265,	--The Slave Pens
		332,	--Serpentshrine Cavern
	104,	--Shadowmoon Valley
		339,	--Black Temple
		490,	--Black Temple (9)
	105,	--Blade's Edge Mountains
		330,	--Gruul's Lair
	107,	--Nagrand
	108,	--Terokkar Forest
		256,	--Auchenai Crypts
		258,	--Sethekk Halls
		260,	--Shadow Labyrinth
		272,	--Mana-Tombs
	109,	--Netherstorm
		112,	--Eye of the Storm
		266,	--The Botanica
		267,	--The Mechanar
		269,	--The Arcatraz
		334,	--Tempest Keep
		889,	--Arcatraz
	111,	--Shattrath City
	525,	--Frostfire Ridge
		573,	--Bloodmaul Slag Mines
		590,	--Frostwall
	534,	--Tanaan Jungle
		661,	--Hellfire Citadel
	535,	--Talador
		593,	--Auchindoun
	539,	--Shadowmoon Valley (2)
		574,	--Shadowmoon Burial Grounds
		582,	--Lunarfall
		592,	--Defense of Karabor
	542,	--Spires of Arak
		601,	--Skyreach
	543,	--Gorgrond
		595,	--Iron Docks
		596,	--Blackrock Foundry
		606,	--Grimrail Depot
		620,	--The Everbloom
	550,	--Nagrand (2)
		610,	--Highmaul
	577,	--Tanaan Jungle (2)
	588,	--Ashran
		622,	--Stormshield
		624,	--Warspear
	933,	--Forge of Aeons
};

QBG_EMISSARY_MAP_IDS = {
	572,	--Draenor
	619,	--Broken Isles
	905,	--Argus
	875,	--Zandalar
	876,	--Kul Tiras
};