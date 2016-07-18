local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(QBG_MOD_NAME, {
	type = "data source",
	text = "",
	label = QBG_MOD_NAME,
	icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_TitanPanel_ButtonOff",
	OnClick = function(self, button)
		if (button == "LeftButton") then
			QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"] = not QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"];
			QuestBuster_TitanPanel_Update();
		elseif (button == "RightButton") then
			QuestBuster_Config_Show();
		end
	end,
	OnTooltipShow = function(tooltip)
		local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;

		local color = QBG_CLR_LIGHTGREY;
		if (QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]) then
			color = QBG_CLR_WHITE;
		end
		tooltip:AddLine(color .. QBG_MOD_NAME .. " v" .. QBG_VERSION);
		if (QuestBusterEntry == "global") then
			tooltip:AddLine(QBL["TITAN_SETTINGS_GLOBAL"]);
		else
			tooltip:AddLine(QBL["TITAN_SETTINGS_PERSON"]);
		end
		tooltip:AddLine(" ");
		tooltip:AddLine(QBL["TITAN_QUESTS"] .. (settings["only_dailies"] and QBL["TITAN_INFO_DAILIES"] or QBL["TITAN_INFO_ALL"]));
		tooltip:AddLine(QBL["TITAN_LOW_LEVEL"] .. (settings["low_level"] and QBL["TITAN_INFO_YES"] or QBL["TITAN_INFO_NO"]));
		tooltip:AddLine(QBL["TITAN_REWARD"] .. QBG_REWARDS[settings.reward].label);
		tooltip:AddLine(" ");
		if (settings["modifier"] ~= NONE_KEY) then
			tooltip:AddLine(QBL["TITAN_MODIFIER"] .. CBG_CLR_OFFBLUE .. QuestBusterOptions[QuestBusterEntry].auto_quest["modifier"]);
		end
		tooltip:AddLine(QBL["TITAN_TOGGLE"]);
		tooltip:AddLine(QBL["TITAN_CONFIG"]);
	end,
});

function QuestBuster_TitanPanel_Update()
	if (QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]) then
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_TitanPanel_ButtonOn";
		
		local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
		local text = "";
		text = text .. QBL["TITAN_INFO_QUEST_LABEL"] .. (settings["only_dailies"] and QBL["TITAN_INFO_DAILIES"] or QBL["TITAN_INFO_ALL"]);
		text = text .. QBL["TITAN_INFO_LOW_LEVEL_LABEL"] .. (settings["low_level"] and QBL["TITAN_INFO_YES"] or QBL["TITAN_INFO_NO"]);
		text = text .. QBL["TITAN_INFO_REWARD_LABEL"] .. QBG_REWARDS[settings.reward].label;
		LDB.text = text;
	else
		LDB.icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_TitanPanel_ButtonOff";
		LDB.text = QBL["TITAN_INFO_DISABLED"];
	end
end

local frame = CreateFrame("Frame", "QuestBuster_TitanPanelFrame", UIParent, SecureFrameTemplate);
frame:RegisterEvent("QUEST_LOG_UPDATE");
frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit and (event == "QUEST_LOG_UPDATE")) then
		QuestBuster_TitanPanel_Update();
	end
end);