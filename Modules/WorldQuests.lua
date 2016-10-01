local _, qb = ...;

qb.world_quests = {};
qb.world_quests.quests = {};
qb.world_quests.quests.count = 0;
qb.world_quests.quests.quests = {};
qb.world_quests.frame = CreateFrame("Frame", "QuestBuster_WorldQuestsBuilderFrame", UIParent, SecureFrameTemplate);
qb.world_quests.frame:RegisterEvent("QUEST_LOG_UPDATE");
qb.world_quests.frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit) then
		return qb.world_quests[event] and qb.world_quests[event](qb, ...)
	end
end);
qb.world_quests.quest_data = {};

function qb.world_quests:QUEST_LOG_UPDATE()
	qb.world_quests.quests.count = 0;
	qb.world_quests.quests.quests = {
		["zones"] = {},
		["types"] = {},
		["factions"] = {},
		["rewards"] = {
			["experience"] = {},
			["money"] = {},
			["artifact experience"] = {},
			["currency"] = {},
			["items"] = {},
			["other"] = {},
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
							if (not qb.world_quests.quest_data[quest_id]) then
								qb.world_quests.quest_data[quest_id] = {
									["name"] = "",
									["objectives"] = info.numObjectives,
									["zone"] = {},
									["type"] = {},
									["faction"] = {},
									["rewards"] = {
										["experience"] = 0,
										["money"] = 0,
										["artifact experience"] = 0,
										["currency"] = {},
										["items"] = {},
										["other"] = {},
									},
								};
							end

							if (HaveQuestData(quest_id)) then
								if (QuestMapFrame_IsQuestWorldQuest(quest_id) and WorldMap_DoesWorldQuestInfoPassFilters(info)) then
									--process zone
									C_TaskQuest.RequestPreloadRewardData(quest_id);
									qb.world_quests.quests.count = qb.world_quests.quests.count + 1;

									if (not qb.world_quests.quests.quests["zones"][zone_name]) then
										qb.world_quests.quests.quests["zones"][zone_name] = {};
									end
									qb.world_quests.quests.quests["zones"][zone_name][quest_id] = quest_id;
									qb.world_quests.quest_data[quest_id]["zone"] = zone_name;
									
									--process quest type
									local _, _, world_quest_type = GetQuestTagInfo(quest_id);
									local type_name = "Other";
									if (QBG_WORLD_QUEST_TYPES[world_quest_type]) then
										type_name = QBG_WORLD_QUEST_TYPES[world_quest_type];
									end
									if (not qb.world_quests.quests.quests["types"][type_name]) then
										qb.world_quests.quests.quests["types"][type_name] = {};
									end
									qb.world_quests.quests.quests["types"][type_name][quest_id] = quest_id;
									qb.world_quests.quest_data[quest_id]["type"] = world_quest_type;
									
									--process faction
									local _, faction_id = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
									local faction_name = "No Faction";
									if (faction_id) then
										faction_name = GetFactionInfoByID(faction_id);
									end
									if (not qb.world_quests.quests.quests["factions"][faction_name]) then
										qb.world_quests.quests.quests["factions"][faction_name] = {};
									end
									qb.world_quests.quests.quests["factions"][faction_name][quest_id] = quest_id;
									qb.world_quests.quest_data[quest_id]["faction"] = faction_name;
									
									--process rewards
									local rewards = false;
									local xp = GetQuestLogRewardXP(quest_id);
									if (xp > 0) then
										qb.world_quests.quests.quests["rewards"]["experience"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["experience"] = xp;
										rewards = true;
									end
									
									local money = GetQuestLogRewardMoney(quest_id);
									if (money > 0) then
										qb.world_quests.quests.quests["rewards"]["money"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["money"] = money;
										rewards = true;
									end
									
									local artifact_xp = GetQuestLogRewardArtifactXP(quest_id);
									if (artifact_xp > 0) then
										qb.world_quests.quests.quests["rewards"]["artifact experience"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["artifact experience"] = artifact_xp;
										rewards = true;
									end
									
									local currency = GetNumQuestLogRewardCurrencies(quest_id);
									if (currency > 0) then
										qb.world_quests.quests.quests["rewards"]["currency"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["currency"] = currency;
										rewards = true;
									end
									
									local items = GetNumQuestLogRewards(quest_id);
									if (items > 0) then
										qb.world_quests.quests.quests["rewards"]["items"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["items"] = items;
										rewards = true;
									end

									if (not rewards) then
										qb.world_quests.quests.quests["rewards"]["other"][quest_id] = quest_id;
										qb.world_quests.quest_data[quest_id]["rewards"]["other"] = "No / Other Rewards";
									end
								end
							end
						end
					end
				end
			end
		end
	end

	qb.quest_lists:update();
end