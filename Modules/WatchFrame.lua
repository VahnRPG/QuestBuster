local _, qb = ...;

qb.modules.watch_frame = {};
qb.modules.watch_frame.frame = CreateFrame("Frame", "QuestBuster_ModulesWatchFrameFrame", UIParent);
qb.modules.watch_frame.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.modules.watch_frame[event] and qb.modules.watch_frame[event](qb, ...)
	end
end);
qb.modules.watch_frame.reload = nil;

function QuestBuster_WatchFrame_ShowQuestLevel(self)
	local show_level = qb.settings:get().watch_frame["show_level"];
	if (not show_level and not qb.modules.watch_frame.reload) then
		return;
	end
	
	local tracker = ObjectiveTrackerFrame;
	if (not tracker.initialized) then 
		return;
	end

	for i=1, #tracker.MODULES do
		for _, block in pairs(tracker.MODULES[i].usedBlocks) do
			local questLogIndex = GetQuestLogIndexByID(block.id);
			local title, level, _,_,_,_, is_daily = GetQuestLogTitle(questLogIndex);
			if (not show_level) then
				block.HeaderText:SetText(title);
			elseif (questLogIndex > 0 and block.HeaderText ~= nil and block.HeaderText:GetText() and (not string.find(block.HeaderText:GetText(), "^%[.*%].*"))) then
				--qb.omg:echo("Here: " .. i .. " - " .. questLogIndex .. " -> " .. block.HeaderText:GetText());
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
				block.HeaderText:SetText(QBG_LEVEL_FORMAT:format(level, quest_type, is_daily, title));
				block.height = height + block.HeaderText:GetHeight();
				block:SetHeight(block.height);
			end
		end
	end
	qb.modules.watch_frame.reload = nil;
end

function QuestBuster_WatchFrame_AddToWatchFrame(self)
	if (not qb.settings:get().watch_frame["show_abandon"]) then 
		return;
	end
	
	local block = self.activeFrame;
	local questLogIndex = GetQuestLogIndexByID(block.id);
	local _,_,_,_,_,_,_,quest_id = GetQuestLogTitle(questLogIndex);
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

hooksecurefunc("ObjectiveTracker_Update", QuestBuster_WatchFrame_ShowQuestLevel);
hooksecurefunc("QuestObjectiveTracker_OnOpenDropDown", QuestBuster_WatchFrame_AddToWatchFrame);