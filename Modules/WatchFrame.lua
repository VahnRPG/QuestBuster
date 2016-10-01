local _, qb = ...;

qb.watch_frame = {};
qb.watch_frame.frame = CreateFrame("Frame", "QuestBuster_WatchFrameFrame", UIParent, SecureFrameTemplate);
qb.watch_frame.frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit) then
		return qb.watch_frame[event] and qb.watch_frame[event](qb, ...)
	end
end);

function qb.watch_frame.showQuestLevel()
	if (not QuestBusterOptions[QuestBusterEntry].watch_frame["show_level"]) then 
		return;
	end

	local tracker = ObjectiveTrackerFrame;
	if (not tracker.initialized) then 
		return;
	end

	for i=1, #tracker.MODULES do
		for _, block in pairs(tracker.MODULES[i].usedBlocks) do
			local questLogIndex = GetQuestLogIndexByID(block.id);
			if (questLogIndex > 0 and block.HeaderText ~= nil and block.HeaderText:GetText() and (not string.find(block.HeaderText:GetText(), "^%[.*%].*"))) then
				--qb.omg:echo("Here: " .. i .. " - " .. questLogIndex .. " -> " .. block.HeaderText:GetText());
				local title, level, _,_,_,_, is_daily = GetQuestLogTitle(questLogIndex);
				local quest_type = GetQuestLogQuestType(questLogIndex);
				quest_type = QBG_QUEST_TYPES[quest_type] or "";

				if (is_daily == LE_QUEST_FREQUENCY_DAILY) then
					is_daily = "d";
				elseif (is_daily == LE_QUEST_FREQUENCY_WEEKLY) then
					is_daily = "w";
				else
					is_daily = "";
				end
				
				local height = block.height - block.HeaderText:GetHeight();
				block.HeaderText:SetText(QBG_LEVEL_fORMAT:format(level, quest_type, is_daily, title));
				block.height = height + block.HeaderText:GetHeight();
				block:SetHeight(block.height);
			end
		end
	end
end

function qb.watch_frame.addToWatchFrame(self)
	if (not QuestBusterOptions[QuestBusterEntry].watch_frame["show_abandon"]) then 
		return;
	end
	
	local block = self.activeFrame;
	local questLogIndex = GetQuestLogIndexByID(block.id);
	local _,_,_,_, _,_,_,quest_id = GetQuestLogTitle(questLogIndex);
	if (CanAbandonQuest(quest_id)) then
		local info = UIDropDownMenu_CreateInfo();
		info.text = ABANDON_QUEST;
		info.func = (function() 
			QuestMapQuestOptions_AbandonQuest(quest_id);
		end);
		info.notCheckable = 1;
		info.noClickSound = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

hooksecurefunc("ObjectiveTracker_Update", qb.watch_frame.showQuestLevel);
hooksecurefunc("QuestObjectiveTracker_OnOpenDropDown", qb.watch_frame.addToWatchFrame);