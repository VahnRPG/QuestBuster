local _, qb = ...;

local function checkTrivial(trivial)
	if (trivial and not QuestBusterOptions[QuestBusterEntry].auto_quest["low_level"]) then
		return false;
	end
	
	return true;
end

local function checkEnabled()
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

local function checkQuest(daily, passed)
	local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
	if (not passed) then
		daily = (QuestIsDaily() or QuestIsWeekly());
	end
	if (settings["only_dailies"] and not daily) then
		return false;
	end

	return true;
end

local function processActiveQuests(...)
    local params = QBG_GOSSIP_PARAMS - 1;	--GetGossipActiveQuests has 1 less param than GetGossipAvailableQuests
	for i=1, select("#", ...), params do
		local completed = select(i + 3, ...);
		if (completed) then
			if (checkQuest()) then
				SelectGossipActiveQuest(math.floor(i / params) + 1);
			end
		end
	end
end

local function processAvailableQuests(...)
    local params = QBG_GOSSIP_PARAMS;
	for i=1, select("#", ...), params do
		local trivial = select(i + 2, ...);
		local daily = (select(i + 3, ...) ~= 1);
		if (checkTrivial(trivial) and checkQuest(daily, true)) then
			SelectGossipAvailableQuest(math.floor(i / params) + 1);
		end
	end
end

qb.auto_quest = {};
qb.auto_quest.frame = CreateFrame("Frame", "QuestBuster_AutoQuestFrame", UIParent);
qb.auto_quest.frame:RegisterEvent("QUEST_GREETING");
qb.auto_quest.frame:RegisterEvent("GOSSIP_SHOW");
qb.auto_quest.frame:RegisterEvent("QUEST_DETAIL");
qb.auto_quest.frame:RegisterEvent("QUEST_PROGRESS");
qb.auto_quest.frame:RegisterEvent("QUEST_COMPLETE");
qb.auto_quest.frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit) then
		return qb.auto_quest[event] and qb.auto_quest[event](qb, ...)
	end
end);

--Apparently there are some older NPCs that fire quests differently than what is standard now. Go figure
function qb.auto_quest.QUEST_GREETING()
	if (checkEnabled()) then
		for i=1, GetNumActiveQuests() do
			local _, completed = GetActiveTitle(i);
			if (completed and checkQuest()) then
				SelectActiveQuest(i);
			end
		end

		local settings = QuestBusterOptions[QuestBusterEntry].auto_quest;
		for i=1, GetNumAvailableQuests() do
			local trivial, daily, repeatable = GetAvailableQuestInfo(i);
			if (checkTrivial(trivial) and checkQuest()) then
				SelectAvailableQuest(i);
			end
		end
	end
end

function qb.auto_quest.GOSSIP_SHOW()
	if (checkEnabled()) then
		processActiveQuests(GetGossipActiveQuests());
	    processAvailableQuests(GetGossipAvailableQuests());
    end
end

function qb.auto_quest.QUEST_DETAIL()
	if (checkEnabled() and checkQuest()) then
		AcceptQuest();
	end
end

function qb.auto_quest.QUEST_PROGRESS()
	if (IsQuestCompletable() and checkEnabled() and checkQuest()) then
		CompleteQuest();
	end
end

function qb.auto_quest.QUEST_COMPLETE()
	if (checkEnabled()) then
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