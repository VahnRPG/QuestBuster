local _, qb = ...;

qb.brokers.main = {};
qb.brokers.main.frame = CreateFrame("Frame", "QuestBuster_BrokersMainFrame", UIParent);
qb.brokers.main.frame:RegisterEvent("QUEST_LOG_UPDATE");
qb.brokers.main.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.brokers.main[event] and qb.brokers.main[event](qb, ...)
	end
end);

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(QBG_MOD_NAME, {
	type = "data source",
	text = "",
	label = QBG_MOD_NAME,
	icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerMain_ButtonOff",
	OnClick = function(self, button)
		if (button == "LeftButton") then
			qb.settings:get().auto_quest["enabled"] = not qb.settings:get().auto_quest["enabled"];
			qb.brokers.main:QUEST_LOG_UPDATE();
		elseif (button == "RightButton") then
			QuestBuster_Config_Show();
		end
	end,
	OnTooltipShow = function(tooltip)
		local settings = qb.settings:get().auto_quest;

		local color = QBG_CLR_LIGHTGREY;
		if (qb.settings:get().auto_quest["enabled"]) then
			color = QBG_CLR_WHITE;
		end
		tooltip:AddLine(color .. QBG_MOD_NAME .. " v" .. QBG_VERSION .. " - Main");
		if (QuestBusterEntry == "global") then
			tooltip:AddLine(QBL["BROKER_SETTINGS_GLOBAL"]);
		else
			tooltip:AddLine(QBL["BROKER_SETTINGS_PERSON"]);
		end
		tooltip:AddLine(" ");
		tooltip:AddLine(QBL["BROKER_QUESTS"] .. (settings["only_dailies"] and QBL["BROKER_INFO_DAILIES"] or QBL["BROKER_INFO_ALL"]));
		tooltip:AddLine(QBL["BROKER_LOW_LEVEL"] .. (settings["low_level"] and QBL["BROKER_INFO_YES"] or QBL["BROKER_INFO_NO"]));
		tooltip:AddLine(QBL["BROKER_REWARD"] .. QBG_REWARDS[settings.reward].label);
		tooltip:AddLine(" ");
		if (settings["modifier"] ~= NONE_KEY) then
			tooltip:AddLine(QBL["BROKER_MODIFIER"] .. QBG_CLR_OFFBLUE .. qb.settings:get().auto_quest["modifier"]);
		end
		tooltip:AddLine(QBL["BROKER_TOGGLE"]);
		tooltip:AddLine(QBL["BROKER_CONFIG"]);
	end,
});

function qb.brokers.main:QUEST_LOG_UPDATE()
	if (qb.settings:get().auto_quest["enabled"]) then
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerMain_ButtonOn";
		
		local settings = qb.settings:get().auto_quest;
		local text = "";
		text = text .. QBL["BROKER_INFO_QUEST_LABEL"] .. (settings["only_dailies"] and QBL["BROKER_INFO_DAILIES"] or QBL["BROKER_INFO_ALL"]);
		text = text .. QBL["BROKER_INFO_LOW_LEVEL_LABEL"] .. (settings["low_level"] and QBL["BROKER_INFO_YES"] or QBL["BROKER_INFO_NO"]);
		text = text .. QBL["BROKER_INFO_REWARD_LABEL"] .. QBG_REWARDS[settings.reward].label;
		LDB.text = text;
	else
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_BrokerMain_ButtonOff";
		LDB.text = QBL["BROKER_INFO_DISABLED"];
	end
end