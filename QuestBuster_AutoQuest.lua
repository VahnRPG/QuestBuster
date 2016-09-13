local function QuestBuster_AutoQuest_CheckTrivial(trivial)
	if (trivial and not QuestBusterOptions[QuestBusterEntry].auto_quest["low_level"]) then
		return false;
	end
	
	return true;
end

local function QuestBuster_AutoQuest_CheckEnabled()
	local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
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

local function QuestBuster_AutoQuest_CheckQuest(daily, passed)
	local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
	if (not passed) then
		daily = (QuestIsDaily() or QuestIsWeekly());
	end
	if (settings["only_dailies"] and not daily) then
		return false;
	end

	return true;
end

local function QuestBuster_AutoQuest_ProcessActiveQuests(...)
    local params = QBG_GOSSIP_PARAMS - 1;	--GetGossipActiveQuests has 1 less param than GetGossipAvailableQuests
	for i=1, select("#", ...), params do
		local completed = select(i + 3, ...);
		if (completed) then
			if (QuestBuster_AutoQuest_CheckQuest()) then
				SelectGossipActiveQuest(math.floor(i / params) + 1);
			end
		end
	end
end

local function QuestBuster_AutoQuest_ProcessAvailableQuests(...)
    local params = QBG_GOSSIP_PARAMS;
	for i=1, select("#", ...), params do
		local trivial = select(i + 2, ...);
		local daily = (select(i + 3, ...) ~= 1);
		if (QuestBuster_AutoQuest_CheckTrivial(trivial) and QuestBuster_AutoQuest_CheckQuest(daily, true)) then
			SelectGossipAvailableQuest(math.floor(i / params) + 1);
		end
	end
end

--Apparently there are some older NPCs that fire quests differently than what is standard now. Go figure
local function QuestBuster_AutoQuest_ListOld()
	if (QuestBuster_AutoQuest_CheckEnabled()) then
		for i=1, GetNumActiveQuests() do
			local _, completed = GetActiveTitle(i);
			if (completed and QuestBuster_AutoQuest_CheckQuest()) then
				SelectActiveQuest(i);
			end
		end

		local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
		for i=1, GetNumAvailableQuests() do
			local trivial, daily, repeatable = GetAvailableQuestInfo(i);
			if (QuestBuster_AutoQuest_CheckTrivial(trivial) and QuestBuster_AutoQuest_CheckQuest()) then
				SelectAvailableQuest(i);
			end
		end
	end
end

local function QuestBuster_AutoQuest_ListNew()
	if (QuestBuster_AutoQuest_CheckEnabled()) then
		QuestBuster_AutoQuest_ProcessActiveQuests(GetGossipActiveQuests());
	    QuestBuster_AutoQuest_ProcessAvailableQuests(GetGossipAvailableQuests());
    end
end

local function QuestBuster_AutoQuest_AcceptQuest()
	if (QuestBuster_AutoQuest_CheckEnabled() and QuestBuster_AutoQuest_CheckQuest()) then
		AcceptQuest();
	end
end

local function QuestBuster_AutoQuest_CompleteQuest()
	if (IsQuestCompletable() and QuestBuster_AutoQuest_CheckEnabled() and QuestBuster_AutoQuest_CheckQuest()) then
		CompleteQuest();
	end
end

local function QuestBuster_AutoQuest_SelectReward()
	if (QuestBuster_AutoQuest_CheckEnabled()) then
		if (GetNumQuestChoices() > 1) then
			local quest_id = GetQuestID();
			if (QuestBusterOptions[QuestBusterEntry].daily_quest_rewards[quest_id] ~= nil) then
				local reward = QuestBusterOptions[QuestBusterEntry].daily_quest_rewards[quest_id];
				GetQuestReward(reward.reward_id);
			else
				local reward_type = QuestBusterOptions[QuestBusterEntry].auto_quest["reward"];
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

local frame = CreateFrame("Frame", "QuestBuster_AutoQuestFrame", UIParent, SecureFrameTemplate);
frame:RegisterEvent("QUEST_GREETING");
frame:RegisterEvent("GOSSIP_SHOW");
frame:RegisterEvent("QUEST_DETAIL");
frame:RegisterEvent("QUEST_PROGRESS");
frame:RegisterEvent("QUEST_COMPLETE");
frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit and (event == "QUEST_GREETING")) then
		QuestBuster_AutoQuest_ListOld();
	elseif (QuestBusterInit and (event == "GOSSIP_SHOW")) then
		QuestBuster_AutoQuest_ListNew();
	elseif (QuestBusterInit and (event == "QUEST_DETAIL")) then
		QuestBuster_AutoQuest_AcceptQuest();
	elseif (QuestBusterInit and (event == "QUEST_PROGRESS")) then
		QuestBuster_AutoQuest_CompleteQuest();
	elseif (QuestBusterInit and (event == "QUEST_COMPLETE")) then
		QuestBuster_AutoQuest_SelectReward();
	end
end);