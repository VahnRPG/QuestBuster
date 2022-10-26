local _, qb = ...;

local function checkEnabled()
	local settings = qb.settings:get().auto_quest;
	if (
		(not settings["enabled"])
		or (settings["modifier"] == ALT_KEY and IsAltKeyDown())
		or (settings["modifier"] == CTRL_KEY and IsControlKeyDown())
		or (settings["modifier"] == SHIFT_KEY and IsShiftKeyDown())
	) then
		return false;
	end

	return true;
end

local function checkTrivial(trivial)
	if (trivial and not qb.settings:get().auto_quest["low_level"]) then
		return false;
	end
	
	return true;
end

local function checkQuest(quest_id, frequency, passed)
	if (not passed) then
		_,_,_,_,_,_,_,frequency = C_QuestLog.GetInfo(C_QuestLog.GetLogIndexForQuestID(quest_id));
	end

	local daily = (frequency == Enum.QuestFrequency.Daily or frequency == Enum.QuestFrequency.Weekly);
	if (qb.settings:get().auto_quest["only_dailies"] and not daily) then
		return false;
	end

	return true;
end

local function processActiveQuests(quests)
	for i=1, #quests do
		local quest = quests[i];
		if (quest.isComplete) then
			if (checkQuest(quest.questID)) then
				C_GossipInfo.SelectActiveQuest(i);
			end
		end
	end
end

local function processAvailableQuests(quests)
	for i=1, #quests do
		local quest = quests[i];
		if (checkTrivial(quest.isTrivial) and checkQuest(quest.questID, quest.frequency, true)) then
			C_GossipInfo.SelectAvailableQuest(i);
		end
	end
end

qb.modules.auto_quest = {};
qb.modules.auto_quest.frame = CreateFrame("Frame", "QuestBuster_ModulesAutoQuestFrame", UIParent);
qb.modules.auto_quest.frame:RegisterEvent("QUEST_GREETING");
qb.modules.auto_quest.frame:RegisterEvent("GOSSIP_SHOW");
qb.modules.auto_quest.frame:RegisterEvent("QUEST_DETAIL");
qb.modules.auto_quest.frame:RegisterEvent("QUEST_PROGRESS");
qb.modules.auto_quest.frame:RegisterEvent("QUEST_COMPLETE");
qb.modules.auto_quest.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.modules.auto_quest[event] and qb.modules.auto_quest[event](qb, ...)
	end
end);

--Apparently there are some older NPCs that fire quests differently than what is standard now. Go figure
function qb.modules.auto_quest.QUEST_GREETING()
	if (checkEnabled()) then
		for i=1, GetNumActiveQuests() do
			local _, completed = GetActiveTitle(i);
			local quest_id = GetActiveQuestID(i);
			local cache_data = QuestCache:Get(quest_id);
			if (completed and checkQuest(quest_id, cache_data.frequency, true)) then
				SelectActiveQuest(i);
			end
		end

		for i=1, GetNumAvailableQuests() do
			local trivial, frequency, repeatable, _, quest_id = GetAvailableQuestInfo(i);
			if (checkTrivial(trivial) and checkQuest(quest_id, frequency, true)) then
				SelectAvailableQuest(i);
			end
		end
	end
end

function qb.modules.auto_quest.GOSSIP_SHOW()
	if (checkEnabled()) then
		processActiveQuests(C_GossipInfo.GetActiveQuests());
		processAvailableQuests(C_GossipInfo.GetAvailableQuests());
    end
end

function qb.modules.auto_quest.QUEST_DETAIL()
	local quest_id = GetQuestID();
	local cache_data = QuestCache:Get(quest_id);
	if (checkEnabled() and checkQuest(quest_id, cache_data.frequency, true)) then
		AcceptQuest();
	end
end

function qb.modules.auto_quest.QUEST_PROGRESS()
	local quest_id = GetQuestID();
	local cache_data = QuestCache:Get(quest_id);
	if (IsQuestCompletable() and checkEnabled() and checkQuest(quest_id, cache_data.frequency, true)) then
		CompleteQuest();
	end
end

function qb.modules.auto_quest.QUEST_COMPLETE()
	if (checkEnabled()) then
		if (GetNumQuestChoices() > 1) then
			local quest_id = GetQuestID();
			if (qb.settings:get().daily_quest_rewards[quest_id] ~= nil) then
				local reward = qb.settings:get().daily_quest_rewards[quest_id];
				GetQuestReward(reward.reward_id);
			else
				local reward_type = qb.settings:get().auto_quest["reward"];
				local selected = QBG_REWARDS[reward_type].sel_func();
				if (selected) then
					GetQuestReward(selected);
				end
			end
		else
			GetQuestReward(1);
		end
	end
end