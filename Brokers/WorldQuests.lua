local _, qb = ...;
--[[
local MAX_EMISSARY_QUESTS = WorldMapFrame.UIElementsFrame.BountyBoard.minimumTabsToDisplay;

qb.brokers.world_quests = {};
qb.brokers.world_quests.frame = CreateFrame("Frame", "QuestBuster_BrokersWorldQuestsFrame", UIParent);
qb.brokers.world_quests.frame:RegisterEvent("QUEST_LOG_UPDATE");
qb.brokers.world_quests.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.brokers.world_quests[event] and qb.brokers.world_quests[event](qb, ...)
	end
end);

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(QBG_MOD_NAME .. "-WQ", {
	type = "data source",
	text = "",
	label = QBG_MOD_NAME,
	icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerWorldQuests_ButtonOn",
	OnClick = function(self, button)
		if (button == "LeftButton") then
			qb.brokers.world_quests:show_menu(self);
		elseif (button == "RightButton") then
			QuestBuster_Config_Show();
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine(QBG_CLR_WHITE .. QBG_MOD_NAME .. " v" .. QBG_VERSION .. " - World Quests");
		tooltip:AddLine(" ");
		tooltip:AddLine(QBL["BROKER_WORLD_QUEST_COUNT"] .. QBG_CLR_LIGHTGREY .. qb.modules.world_quests.quests.count);
		tooltip:AddLine(QBL["BROKER_WORLD_QUEST_EMISSARY"]);

		for i=1, MAX_EMISSARY_QUESTS do
			if (qb.modules.world_quests.emissary.quests[i]) then
				local emissary_data = qb.modules.world_quests.emissary.quests[i];
				local faction_name, _, faction_standing = GetFactionInfoByID(emissary_data["faction_id"]);

				local text = "  " .. QBG_CLR_DEFAULT .. faction_name .. " - " .. getglobal("FACTION_STANDING_LABEL" .. faction_standing);
				text = text .. " - " .. QBG_CLR_LIGHTGREY .. emissary_data["completed"] .. "/" .. emissary_data["total"];
				tooltip:AddLine(text);
				
				local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(emissary_data["quest_id"]);
				if (minutes_left and minutes_left > 0) then
					local color = NORMAL_FONT_COLOR;
					local time_str;
					if (minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
						color = RED_FONT_COLOR;
						time_str = SecondsToTime(minutes_left * 60);
					elseif (minutes_left <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
						time_str = SecondsToTime((minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60);
					elseif (minutes_left < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
						time_str = D_HOURS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60);
					else
						time_str = D_DAYS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440);
					end
					tooltip:AddLine("    " .. BONUS_OBJECTIVE_TIME_LEFT:format(time_str), color:GetRGB());
				end

			end
		end

		tooltip:AddLine(" ");
		tooltip:AddLine(QBL["BROKER_WORLD_QUEST_MENU"]);
		tooltip:AddLine(QBL["BROKER_CONFIG"]);
	end,
});

function qb.brokers.world_quests:show_menu(self)
	qb.omg:echo("Show World Quests Menu");
end

function qb.brokers.world_quests:QUEST_LOG_UPDATE()
	if (qb.modules.world_quests.quests.count > 0) then
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerWorldQuests_ButtonOn";
	else
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerWorldQuests_ButtonOff";
	end
	
	LDB.text = "WorldQuests";
end
]]--