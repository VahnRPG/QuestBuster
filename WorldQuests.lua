local WORLD_QUEST_COUNT = 0;
local WORLD_QUESTS = {};

local LDB2 = LibStub("LibDataBroker-1.1"):NewDataObject(QBG_MOD_NAME .. "2", {
	type = "data source",
	label = QBG_MOD_NAME .. " World Quests",
	icon = "Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_TitanPanel_ButtonOn",
	OnClick = function(self, button)
		if (button == "LeftButton") then
			QuestBuster_WorldQuests_UpdateWorldQuests();
		elseif (button == "RightButton") then
			QuestBuster_Config_Show();
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine(QBG_CLR_OFFBLUE .. QBG_MOD_NAME .. " v" .. QBG_VERSION .. " - World Quests");

		for quest_type, quest_data in sortedpairs(WORLD_QUESTS) do
			for name, quest_ids in sortedpairs(quest_data) do
				if (quest_ids and next(quest_ids)) then
					tooltip:AddLine(" > " .. name .. ": ");
					for i, quest_id in pairs(quest_ids) do
						local tag_id, tag_name, world_quest_type, rarity, elite, tradeskill_line = GetQuestTagInfo(quest_id);
						local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);

						tooltip:AddLine("    - " .. title);
					end
				end
			end

			found = true;
		end

		tooltip:AddLine(QBL["TITAN_CONFIG"]);
	end,
});

function QuestBuster_WorldQuestsFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function QuestBuster_WorldQuestsFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if (QuestBusterInit and (event == "QUEST_LOG_UPDATE")) then
		QuestBuster_WorldQuestsFrame_Update();
	end
end

function QuestBuster_WorldQuestsFrame_Update()
	if (InCombatLockdown()) then
		QuestBuster_AddLeaveCombatCommand("QuestBuster_WorldQuestsFrame_Update");
		return;
	end

	QuestBuster_WorldQuestsFrame_UpdateQuests();
	if (QuestBusterOptions[QuestBusterEntry].world_quests_frame.show and WORLD_QUEST_COUNT > 0) then
		if (QuestBusterOptions[QuestBusterEntry].world_quests_frame.state == "expanded") then
			--[[
			for i=1,MAX_FRAMES do
				_G["QuestBuster_WorldQuestsFrameZoneNode" .. i]:Hide();
				_G["QuestBuster_WorldQuestsFrameSkillNode" .. i]:Hide();
			end
			]]--
			local count = 0;
			local padding = 0;

			if (count > 0) then
				QuestBuster_WorldQuests_MoverFrame:Show();
				QuestBuster_WorldQuests_MoverFrame_CollapseFrame:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
				QuestBuster_WorldQuestsFrame:SetHeight(15 + ((count + padding) * 20));
				QuestBuster_WorldQuestsFrame:Show();
			else
				QuestBuster_WorldQuests_MoverFrame:Show();
				QuestBuster_WorldQuests_MoverFrame_CollapseFrame:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
				QuestBuster_WorldQuestsFrame:SetHeight(28);
				QuestBuster_WorldQuestsFrame:Show();
			end
		else
			QuestBuster_WorldQuests_MoverFrame:Show();
			QuestBuster_WorldQuests_MoverFrame_CollapseFrame:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Expand");
			QuestBuster_WorldQuestsFrame:Hide();
		end

		if (not QuestBusterOptions[QuestBusterEntry].world_quests_frame.locked) then
			QuestBuster_WorldQuests_MoverFrame_LockFrame:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
		else
			QuestBuster_WorldQuests_MoverFrame_LockFrame:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Locked");
		end
	else
		QuestBuster_WorldQuests_MoverFrame:Hide();
		QuestBuster_WorldQuestsFrame:Hide();
	end
end

function QuestBuster_WorldQuestsFrame_UpdateQuests()
	WORLD_QUEST_COUNT = 0;
	WORLD_QUESTS = {
		["zones"] = {},
		["types"] = {},
		["factions"] = {},
		["rewards"] = {
			["xp"] = {},
			["money"] = {},
			["artifact_xp"] = {},
			["currency"] = {},
			["items"] = {},
		},
	};

	for i, map_id in pairs(QBG_MAP_IDS) do
		if (C_MapCanvas.GetNumZones(map_id) ~= nil) then
			for zone_id=1, C_MapCanvas.GetNumZones(map_id) do
				local zone_map_id, zone_name, zone_depth = C_MapCanvas.GetZoneInfo(map_id, zone_id);
				if (zone_depth <= 1) then
					local task_info = C_TaskQuest.GetQuestsForPlayerByMapID(zone_map_id, map_id);
					if (task_info) then
						for i, info in ipairs(task_info) do
							local quest_id = info.questId;
							if (HaveQuestData(quest_id)) then
								if (QuestMapFrame_IsQuestWorldQuest(quest_id) and WorldMap_DoesWorldQuestInfoPassFilters(info)) then
									C_TaskQuest.RequestPreloadRewardData(quest_id);
									WORLD_QUEST_COUNT = WORLD_QUEST_COUNT + 1;

									if (not WORLD_QUESTS["zones"][zone_name]) then
										WORLD_QUESTS["zones"][zone_name] = {};
									end
									WORLD_QUESTS["zones"][zone_name][quest_id] = quest_id;

									local _, _, world_quest_type = GetQuestTagInfo(quest_id);
									local type_name = "Other";
									if (QBG_WORLD_QUEST_TYPES[world_quest_type]) then
										type_name = QBG_WORLD_QUEST_TYPES[world_quest_type];
									end
									if (not WORLD_QUESTS["types"][type_name]) then
										WORLD_QUESTS["types"][type_name] = {};
									end
									WORLD_QUESTS["types"][type_name][quest_id] = quest_id;
									
									local _, faction_id = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
									local faction_name = "No Faction";
									if (faction_id) then
										faction_name = GetFactionInfoByID(faction_id);
									end
									if (not WORLD_QUESTS["factions"][faction_name]) then
										WORLD_QUESTS["factions"][faction_name] = {};
									end
									WORLD_QUESTS["factions"][faction_name][quest_id] = quest_id;
									
									local xp = GetQuestLogRewardXP(quest_id);
									if (xp > 0) then
										WORLD_QUESTS["rewards"]["xp"][quest_id] = quest_id;
									end
									
									local money = GetQuestLogRewardMoney(quest_id);
									if (money > 0) then
										WORLD_QUESTS["rewards"]["money"][quest_id] = quest_id;
									end
									
									local artifact_xp = GetQuestLogRewardArtifactXP(quest_id);
									if (artifact_xp > 0) then
										WORLD_QUESTS["rewards"]["artifact_xp"][quest_id] = quest_id;
									end
									
									local currency = GetNumQuestLogRewardCurrencies(quest_id);
									if (currency > 0) then
										WORLD_QUESTS["rewards"]["currency"][quest_id] = quest_id;
									end
									
									local items = GetNumQuestLogRewards(quest_id);
									if (items > 0) then
										WORLD_QUESTS["rewards"]["items"][quest_id] = quest_id;
									end

									--1090 - Kirin Tor
									--1828 - Highmountain Tribe
									--1859 - The Nightfallen
									--1883 - Dreamweavers
									--1894 - The Wardens
									--1900 - Court of Farondis
									--1948 - Valarjar
									if (faction_id ~= nil and faction_id == 1828) then
										local tag_id, tag_name, world_quest_type, rarity, elite, tradeskill_line = GetQuestTagInfo(quest_id);
										local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
										--echo("Here: " .. zone_name .. " - " .. title);
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function QuestBuster_WorldQuestsFrame_Lock_OnClick()
	if (InCombatLockdown()) then
		QuestBuster_AddLeaveCombatCommand("QuestBuster_WorldQuestsFrame_Lock_OnClick");
		return;
	end
	if (not QuestBusterOptions[QuestBusterEntry].world_quests_frame.locked) then
		QuestBusterOptions[QuestBusterEntry].world_quests_frame.locked = true;
	else
		QuestBusterOptions[QuestBusterEntry].world_quests_frame.locked = false;
	end
	QuestBuster_WorldQuestsFrame_Update();
end

function QuestBuster_WorldQuestsFrame_Collapse_OnClick()
	if (InCombatLockdown()) then
		QuestBuster_AddLeaveCombatCommand("QuestBuster_WorldQuestsFrame_Collapse_OnClick");
		return;
	end
	if (QuestBuster_WorldQuestsFrame:IsShown()) then
		QuestBuster_WorldQuestsFrame:Hide();
		QuestBusterOptions[QuestBusterEntry].world_quests_frame.state = "collapsed";
	else
		QuestBuster_WorldQuestsFrame:Show();
		QuestBusterOptions[QuestBusterEntry].world_quests_frame.state = "expanded";
	end
	QuestBuster_WorldQuestsFrame_Update();
end

function QuestBuster_WorldQuestsFrame_Close_OnClick()
	if (InCombatLockdown()) then
		QuestBuster_AddLeaveCombatCommand("QuestBuster_WorldQuestsFrame_Close_OnClick");
		return;
	end
	QuestBuster_WorldQuests_MoverFrame:Hide();
	QuestBuster_WorldQuestsFrame:Hide();
	if (not QuestBuster_WorldQuests_MoverFrame:IsShown()) then
		QuestBusterOptions[QuestBusterEntry].world_quests_frame.show = false;
	end
end

function QuestBuster_WorldQuestsFrame_OnDrag()
	local point, _, relative_point, x, y = QuestBuster_WorldQuests_MoverFrame:GetPoint();
	QuestBusterOptions[QuestBusterEntry].world_quests_frame.position.point = point;
	QuestBusterOptions[QuestBusterEntry].world_quests_frame.position.relative_point = relative_point;
	QuestBusterOptions[QuestBusterEntry].world_quests_frame.position.x = x;
	QuestBusterOptions[QuestBusterEntry].world_quests_frame.position.y = y;
	QuestBuster_WorldQuestsFrame_UpdatePosition();
end

function QuestBuster_WorldQuestsFrame_UpdatePosition()
	if (InCombatLockdown()) then
		QuestBuster_AddLeaveCombatCommand("QuestBuster_WorldQuestsFrame_UpdatePosition");
		return;
	end

	local position = QuestBusterOptions[QuestBusterEntry].world_quests_frame.position;
	QuestBuster_WorldQuests_MoverFrame:ClearAllPoints();
	QuestBuster_WorldQuests_MoverFrame:SetPoint(position.point, nil, position.relative_point, position.x, position.y);
end

function QuestBuster_WorldQuestsFrame_ResetPosition()
	QuestBusterOptions[QuestBusterEntry].world_quests_frame.position = {
		point = "TOPLEFT",
		relative_point = "TOPLEFT",
		x = 490,
		y = -330,
	};
	QuestBuster_WorldQuestsFrame_UpdatePosition();
end