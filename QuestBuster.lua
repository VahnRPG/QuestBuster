local DB_VERSION = 0.00;

local _, qb = ...;

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
SLASH_QBUSTER1 = "/questbuster";
SLASH_QBUSTER2 = "/qbuster";
SLASH_QBUSTER3 = "/qb";

SlashCmdList["QBUSTER"] = function(cmd)
	cmd = string.lower(cmd);

	if (cmd == "help") then
		for i=1, QBL["HELP_LINES"] do
			qb.omg:echo(QBL["HELP" .. i]);
		end
	elseif (cmd == "config") then
		QuestBuster_Config_Show();
	elseif (cmd == "reset") then
		qb.settings:initSettings("character");
		qb.brokers:update();
		qb.omg:echo(QBG_MOD_COLOR .. "Reset");
	elseif (cmd == "fullreset") then
		qb.settings:initSettings(true);
		qb.brokers:update();
		qb.omg:echo(QBG_MOD_COLOR .. "Fully Reset");
	end
end

qb.frame = CreateFrame("Frame", "QuestBusterFrame", UIParent);
qb.frame:RegisterEvent("ADDON_LOADED");
qb.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb[event] and qb[event](qb, ...);
	end
end);

function qb:ADDON_LOADED(self, ...)
	qb.brokers:update();

	qb.omg:echo(CBG_MOD_COLOR .. CBG_MOD_NAME .. " (v" .. CBG_VERSION .. " - Last Updated: " .. CBG_LAST_UPDATED .. ")");
	
	qb.frame:UnregisterEvent("ADDON_LOADED");
end