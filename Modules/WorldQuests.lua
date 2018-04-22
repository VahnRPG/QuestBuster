local _, qb = ...;

qb.modules.world_quests = {};
qb.modules.world_quests.quests = {};
qb.modules.world_quests.quests.count = 0;
qb.modules.world_quests.quests.quests = {};
qb.modules.world_quests.frame = CreateFrame("Frame", "QuestBuster_ModulesWorldQuestsBuilderFrame", UIParent);
qb.modules.world_quests.frame:RegisterEvent("QUEST_LOG_UPDATE");
qb.modules.world_quests.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.modules.world_quests[event] and qb.modules.world_quests[event](qb, ...)
	end
end);
qb.modules.world_quests.emissary = {};
qb.modules.world_quests.emissary.count = 0;
qb.modules.world_quests.emissary.quests = {};
qb.modules.world_quests.quest_data = {};

local function isWorldQuest(quest_id)
	local _, _, world_quest_type = GetQuestTagInfo(quest_id);
	
	return world_quest_type ~= nil;
end

local function setQuestData(zone_name, info)
	local quest_id = info.questId;
	if (not qb.modules.world_quests.quest_data[quest_id]) then
		qb.modules.world_quests.quest_data[quest_id] = {
			["name"] = "",
			["objectives"] = info.numObjectives,
			["location"] = {
				["zone"] = "",
				["x"] = "",
				["y"] = "",
				["floor"] = "",
				["map_id"] = "",
			},
			["type"] = "",
			["faction"] = "",
			["rewards"] = {
				["experience"] = 0,
				["money"] = 0,
				["artifact experience"] = 0,
				["currency"] = "",
				["items"] = {},
				["other"] = {},
			},
			["time"] = "",
			["find_group"] = true,
		};
	end

	if (HaveQuestData(quest_id)) then
		if (isWorldQuest(quest_id) and WorldMap_DoesWorldQuestInfoPassFilters(info)) then
			--process zone
			C_TaskQuest.RequestPreloadRewardData(quest_id);
			qb.modules.world_quests.quests.count = qb.modules.world_quests.quests.count + 1;

			if (not qb.modules.world_quests.quests.quests["zones"][zone_name]) then
				qb.modules.world_quests.quests.quests["zones"][zone_name] = {};
			end
			qb.modules.world_quests.quests.quests["zones"][zone_name][quest_id] = quest_id;
			qb.modules.world_quests.quest_data[quest_id]["location"]["zone"] = zone_name;
			qb.modules.world_quests.quest_data[quest_id]["location"]["x"] = info.x;
			qb.modules.world_quests.quest_data[quest_id]["location"]["y"] = info.y;
			qb.modules.world_quests.quest_data[quest_id]["location"]["floor"] = info.floor;
			qb.modules.world_quests.quest_data[quest_id]["location"]["map_id"] = zone_map_id;
			
			--process quest type
			local _, _, world_quest_type = GetQuestTagInfo(quest_id);
			local type_name = "Other";
			if (QBG_WORLD_QUEST_TYPES[world_quest_type]) then
				type_name = QBG_WORLD_QUEST_TYPES[world_quest_type];
			end
			if (not qb.modules.world_quests.quests.quests["types"][type_name]) then
				qb.modules.world_quests.quests.quests["types"][type_name] = {};
			end
			qb.modules.world_quests.quests.quests["types"][type_name][quest_id] = quest_id;
			qb.modules.world_quests.quest_data[quest_id]["type"] = world_quest_type;

			if (world_quest_type == LE_QUEST_TAG_TYPE_PET_BATTLE or world_quest_type == LE_QUEST_TAG_TYPE_PROFESSION) then
				qb.modules.world_quests.quest_data[quest_id]["find_group"] = nil;
			end
			
			--process faction
			local _, faction_id = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
			local faction_name = "No Faction";
			if (faction_id) then
				faction_name = GetFactionInfoByID(faction_id);
			end
			if (not qb.modules.world_quests.quests.quests["factions"][faction_name]) then
				qb.modules.world_quests.quests.quests["factions"][faction_name] = {};
			end
			qb.modules.world_quests.quests.quests["factions"][faction_name][quest_id] = quest_id;
			qb.modules.world_quests.quest_data[quest_id]["faction"] = faction_name;
			
			--process rewards
			local rewards = false;
			local xp = GetQuestLogRewardXP(quest_id);
			if (xp > 0) then
				qb.modules.world_quests.quests.quests["rewards"]["experience"][quest_id] = quest_id;
				qb.modules.world_quests.quest_data[quest_id]["rewards"]["experience"] = xp;
				rewards = true;
			end
			
			local money = GetQuestLogRewardMoney(quest_id);
			if (money > 0) then
				qb.modules.world_quests.quests.quests["rewards"]["money"][quest_id] = quest_id;
				qb.modules.world_quests.quest_data[quest_id]["rewards"]["money"] = money;
				rewards = true;
			end
			
			local artifact_xp = GetQuestLogRewardArtifactXP(quest_id);
			if (artifact_xp > 0) then
				qb.modules.world_quests.quests.quests["rewards"]["artifact experience"][quest_id] = quest_id;
				qb.modules.world_quests.quest_data[quest_id]["rewards"]["artifact experience"] = artifact_xp;
				rewards = true;
			end
			
			local currency = GetNumQuestLogRewardCurrencies(quest_id);
			if (currency > 0) then
				for i=1, currency do
					local currency_name = GetQuestLogRewardCurrencyInfo(i, quest_id);
					if (currency_name) then
						if (not qb.modules.world_quests.quests.quests["rewards"][currency_name]) then
							qb.modules.world_quests.quests.quests["rewards"][currency_name] = {};
						end
						qb.modules.world_quests.quests.quests["rewards"][currency_name][quest_id] = quest_id;
						qb.modules.world_quests.quest_data[quest_id]["rewards"]["currency"] = currency_name;
					end
				end

				rewards = true;
			end
			
			local items = GetNumQuestLogRewards(quest_id);
			if (items > 0) then
				for i=1, items do
					local item_link = GetQuestItemLink(i, quest_id);
					local _, _, _, _, _, item_id = GetQuestLogRewardInfo(i, quest_id);
					if (item_id) then
						local _, _, _, _, _, item_type = GetItemInfo(item_id);
						if (not qb.modules.world_quests.quests.quests["rewards"][item_type]) then
							qb.modules.world_quests.quests.quests["rewards"][item_type] = {};
						end
						qb.modules.world_quests.quests.quests["rewards"][item_type][quest_id] = quest_id;
						qb.modules.world_quests.quest_data[quest_id]["rewards"]["items"][item_id] = item_id;
					end
				end

				rewards = true;
			end
			
			if (not rewards) then
				qb.modules.world_quests.quests.quests["rewards"]["other"][quest_id] = quest_id;
				qb.modules.world_quests.quest_data[quest_id]["rewards"]["other"] = "No / Other Rewards";
			end
			
			local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(quest_id);
			if (minutes_left and minutes_left > 0) then
				qb.modules.world_quests.quest_data[quest_id]["time"] = minutes_left;

				local color = NORMAL_FONT_COLOR;
				local time_str = qb.omg:str_pad(minutes_left, 6, "0", "right");
				if (minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
					qb.modules.world_quests.quests.quests["time"]["less than " .. WORLD_QUESTS_TIME_CRITICAL_MINUTES .. " minutes"][time_str .. "-" .. quest_id] = quest_id;
				elseif (minutes_left <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
					qb.modules.world_quests.quests.quests["time"]["less than one hour"][time_str .. "-" .. quest_id] = quest_id;
				elseif (minutes_left < 12 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
					qb.modules.world_quests.quests.quests["time"]["less than twelve hours"][time_str .. "-" .. quest_id] = quest_id;
				elseif (minutes_left < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
					qb.modules.world_quests.quests.quests["time"]["less than twenty four hours"][time_str .. "-" .. quest_id] = quest_id;
				else
					qb.modules.world_quests.quests.quests["time"]["one day or longer"][time_str .. "-" .. quest_id] = quest_id;
				end
			else
				qb.modules.world_quests.quests.quests["time"]["invalid time left"][quest_id .. "-" .. quest_id] = quest_id;
			end
		end
	end
end

local previous_time = 0;
function qb.modules.world_quests:QUEST_LOG_UPDATE()
	if (WorldMapFrame:IsShown()) then
		return;
	end
	
	local cur_time = GetTime();
	--if (Nx ~= nil and cur_time < previous_time + 3) then		--Carbonite Maps calls this event a ton. Prevent updates from being attempted too quickly
	if (cur_time < previous_time + 3) then
		return;
	end
	previous_time = cur_time;

	qb.modules.world_quests:updateWorldQuests();
	qb.modules.world_quests:updateEmissary();
	qb.modules.quest_lists:update();
end

function qb.modules.world_quests:updateWorldQuests()
	qb.modules.world_quests.quests.count = 0;
	qb.modules.world_quests.quests.quests = {
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
		["time"] = {
			["less than " .. WORLD_QUESTS_TIME_CRITICAL_MINUTES .. " minutes"] = {},
			["less than one hour"] = {},
			["less than twelve hours"] = {},
			["less than twenty four hours"] = {},
			["one day or longer"] = {},
			["invalid time left"] = {},
		},
	};
	
	for i, map_id in pairs(QBG_MAP_IDS) do
		if (C_MapCanvas.GetNumZones(map_id) ~= nil) then
			for zone_id=1, C_MapCanvas.GetNumZones(map_id) do
				local zone_map_id, zone_name, zone_depth = C_MapCanvas.GetZoneInfo(map_id, zone_id);
				if (zone_depth <= 1) then
					local task_info = nil;
					if (qb.omg:in_array(zone_map_id, QBG_ARGUS_MAP_IDS)) then
						SetMapByID(zone_map_id);
						task_info = C_TaskQuest.GetQuestsForPlayerByMapID(zone_map_id);
						SetMapToCurrentZone();
					else
						task_info = C_TaskQuest.GetQuestsForPlayerByMapID(zone_map_id, map_id);
					end
					if (task_info) then
						for _, info in ipairs(task_info) do
							setQuestData(zone_name, info);
						end
					end
				end
			end
		end
	end
end

local function CalculateBountySubObjectives(bountyData)
	local numCompleted = 0;
	local numTotal = 0;

	for objectiveIndex = 1, bountyData.numObjectives do
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(bountyData.questID, objectiveIndex, false);
		if objectiveText and #objectiveText > 0 and numRequired > 0 then
			for objectiveSubIndex = 1, numRequired do
				if objectiveSubIndex <= numFulfilled then
					numCompleted = numCompleted + 1;
				end
				numTotal = numTotal + 1;

				if numTotal >= MAX_BOUNTY_OBJECTIVES then
					return numCompleted, numTotal;
				end
			end
		end
	end

	return numCompleted, numTotal;
end

function qb.modules.world_quests:findEmissary()
	--World Quest emissary frame doesn't get processed until you view the map. So, do it manually.
	for i, map_id in pairs(QBG_EMISSARY_MAP_IDS) do
		local bounty_data, _, locked_quest_id = GetQuestBountyInfoForMapID(map_id);
		if (bounty_data ~= nil and qb.omg:tcount(bounty_data) > 0) then
			bounties = {};
			for i, bounty in ipairs(bounty_data) do
				local faction_id = bounty.factionID;
				if (faction_id == 0 and bounty.questID == 48639) then
					faction_id = 2165;
				elseif (faction_id == 0 and bounty.questID == 48641) then
					faction_id = 2045;
				elseif (faction_id == 0 and bounty.questID == 48642) then
					faction_id = 2170;
				--[[
				elseif (faction_id == 0) then
					qb.omg:echo("Here: " .. i);
					qb.omg:print_r(bounty);
				]]--
				end
				
				local completed, total = CalculateBountySubObjectives(bounty);

				bounties[i] = {
					["index"] = i,
					["quest_id"] = bounty.questID,
					["faction_id"] = faction_id,
					["icon"] = bounty.icon,
					["completed"] = completed,
					["total"] = total,
					["pending"] = bounty.turninRequirementText,
				};
			end

			return bounties;
		end
	end

	return nil;
end

function qb.modules.world_quests:updateEmissary()
	qb.modules.world_quests.emissary.count = 0;
	qb.modules.world_quests.emissary.quests = {};

	--Something about this function borks when "using spells on world quests"
	local start_time = GetTime();
	local bounties = qb.modules.world_quests:findEmissary();
	if (bounties ~= nil) then
		for i, bounty in ipairs(bounties) do
			qb.modules.world_quests.emissary.count = qb.modules.world_quests.emissary.count + 1;
			qb.modules.world_quests.emissary.quests[qb.modules.world_quests.emissary.count] = bounty;
		end
	end
end