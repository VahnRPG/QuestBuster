local _, qb = ...;

--local MAX_EMISSARY_QUESTS = WorldMapFrame.UIElementsFrame.BountyBoard.minimumTabsToDisplay;
local MAX_EMISSARY_QUESTS = 9;

local QUEST_TYPE_COLOR = { r=0.25, g=0.36, b=0.69 };
local QUEST_TYPE_HOVER_COLOR = { r=0.39, g=0.47, b=0.72 };
local QUEST_TYPE_EXPANDED_COLOR = { r=0.08, g=0.20, b=0.51 };

local FILTER_COLOR = { r=0.31, g=0.25, b=0.69 };
local FILTER_HOVER_COLOR = { r=0.43, g=0.39, b=0.72 };
local FILTER_EXPANDED_COLOR = { r=0.21, g=0.08, b=0.51 };

local QUEST_COLOR = { r=0.32, g=0.69, b=0.25 };
local QUEST_HOVER_COLOR = { r=0.50, g=0.72, b=0.39 };
--local QUEST_EXPANDED_COLOR = { r=0.16, g=0.51, b=0.08 };		--currently unused

qb.modules.quest_lists = {};
qb.modules.quest_lists.mover_frame = CreateFrame("Frame", "QuestBuster_QuestLists_MoverFrame", UIParent, "QuestBuster_MoverBar_Template");
qb.modules.quest_lists.mover_frame:SetSize(336, 10);
qb.modules.quest_lists.mover_frame:RegisterForDrag("LeftButton");
qb.modules.quest_lists.mover_frame:SetScript("OnDragStart", function(self)
	if (not qb.settings:get().quest_list_frame.locked) then
		self.dragging = true;
		self:StartMoving();
	end
end);
qb.modules.quest_lists.mover_frame:SetScript("OnDragStop", function(self)
	if (not qb.settings:get().quest_list_frame.locked) then
		self.dragging = false;
		self:StopMovingOrSizing();
	end
end);
qb.modules.quest_lists.mover_frame:SetScript("OnUpdate", function(self)
	if (self.dragging) then
		qb.modules.quest_lists:dragFrame();
	end
end);
QuestBuster_QuestLists_MoverFrameTexture:SetSize(336, 16);
QuestBuster_QuestLists_MoverFrameLabel:SetText(QBL["WORLD_QUEST_HEADER"]);
QuestBuster_QuestLists_MoverFrame_LockFrame:SetScript("OnClick", function(self)
	qb.modules.quest_lists:lockFrame();
end);
QuestBuster_QuestLists_MoverFrame_CollapseFrame:SetScript("OnClick", function(self)
	qb.modules.quest_lists:collapseFrame();
end);
QuestBuster_QuestLists_MoverFrame_CloseFrame:SetScript("OnClick", function(self)
	qb.modules.quest_lists:closeFrame();
end);

qb.modules.quest_lists.frame = CreateFrame("Frame", "QuestBuster_QuestLists_Frame", UIParent, "QuestBuster_ContainerFrame_Template");
qb.modules.quest_lists.frame:SetSize(336, 16);
--qb.modules.quest_lists.frame:SetStrata("LOW");
qb.modules.quest_lists.frame:SetPoint("TOPLEFT", qb.modules.quest_lists.mover_frame, "BOTTOMLEFT", 0, 2);
qb.modules.quest_lists.frame:RegisterEvent("ADDON_LOADED");
qb.modules.quest_lists.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.modules.quest_lists[event] and qb.modules.quest_lists[event](qb, ...)
	end
end);
qb.modules.quest_lists.emissary_frames = {};
qb.modules.quest_lists.type_frames = {};
qb.modules.quest_lists.type_expanded = "";
qb.modules.quest_lists.filter_expanded = "";

function qb.modules.quest_lists:ADDON_LOADED()
	--build base frame - emissary buttons
	local x_pos = 0;
	local y_pos = 0;
	for i=1, MAX_EMISSARY_QUESTS do
		if (i > 1) then
			if ((i - 1) % 3 == 0) then
				x_pos = x_pos - 15;
				y_pos = 0;
			else
				y_pos = y_pos - 16;
			end
		end
		local emissary_frame = CreateFrame("Frame", "QuestBuster_QuestLists_Emissary" .. i .. "Frame", qb.modules.quest_lists.frame);
		emissary_frame:SetPoint("TOPRIGHT", qb.modules.quest_lists.frame, "TOPLEFT", x_pos, y_pos - 5);
		emissary_frame:SetSize(16, 16);
		emissary_frame.emissary_data = {};
		emissary_frame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
			qb.modules.quest_lists:setEmissaryTooltip(self.emissary_data);
			GameTooltip:Show();
		end);
		emissary_frame:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end);
		
		emissary_frame.icon = emissary_frame:CreateTexture("ARTWORK");
		emissary_frame.icon:SetAllPoints();

		emissary_frame.check_icon = CreateFrame("Frame", nil, emissary_frame);
		emissary_frame.check_icon:SetPoint("TOPLEFT", emissary_frame, "TOPLEFT", -(emissary_frame:GetWidth() * .25), (emissary_frame:GetHeight() * .25));
		emissary_frame.check_icon:SetSize(emissary_frame:GetWidth() * 1.5, emissary_frame:GetHeight() * 1.5);
		
		emissary_frame.check_icon.icon = emissary_frame.check_icon:CreateTexture("ARTWORK");
		emissary_frame.check_icon.icon:SetAllPoints();
		emissary_frame.check_icon.icon:SetAtlas("worldquest-tracker-checkmark", true);
		
		qb.modules.quest_lists.emissary_frames[i] = emissary_frame;
	end
	qb.modules.quest_lists:updatePosition();
	
	qb.modules.quest_lists.frame:UnregisterEvent("ADDON_LOADED");
end

function qb.modules.quest_lists:update()
	local config = qb.settings:get().quest_list_frame;
	if (config.show and qb.modules.world_quests.quests.count > 0) then
		if (config.state == "expanded") then
			_G[qb.modules.quest_lists.mover_frame:GetName() .. "_CollapseFrame"]:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");

			for i=1, MAX_EMISSARY_QUESTS do
				local emissary_frame = qb.modules.quest_lists.emissary_frames[i];
				if (qb.modules.world_quests.emissary.quests[i]) then
					local quest_data = qb.modules.world_quests.emissary.quests[i];
					emissary_frame.emissary_data = quest_data;
					emissary_frame.icon:SetTexture(quest_data["icon"]);
					emissary_frame.check_icon.icon:SetAlpha(quest_data["completed"] / quest_data["total"]);
					emissary_frame:Show();
				else
					emissary_frame:Hide();
				end
			end
			
			local type_count, type_bars = qb.modules.quest_lists:processQuestTypes();
			if (type_count > 0) then
				qb.modules.quest_lists.mover_frame:Show();
				qb.modules.quest_lists.frame:SetHeight(12 + (type_bars * 16));
				qb.modules.quest_lists.frame:Show();
			else
				qb.modules.quest_lists.mover_frame:Hide();
				qb.modules.quest_lists.frame:Hide();
			end
		else
			qb.modules.quest_lists.mover_frame:Show();
			_G[qb.modules.quest_lists.mover_frame:GetName() .. "_CollapseFrame"]:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Expand");
			qb.modules.quest_lists.frame:Hide();
		end
		
		if (not config.locked) then
			_G[qb.modules.quest_lists.mover_frame:GetName() .. "_LockFrame"]:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
		else
			_G[qb.modules.quest_lists.mover_frame:GetName() .. "_LockFrame"]:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Locked");
		end
	else
		qb.modules.quest_lists.mover_frame:Hide();
		qb.modules.quest_lists.frame:Hide();
	end
end

function qb.modules.quest_lists:processQuestTypes()
	local total_bars = 0;

	local type_count = 0;
	local previous_frame = nil;
	for quest_type, quest_data in qb.omg:sortedpairs(qb.modules.world_quests.quests.quests) do
		if (not qb.modules.quest_lists.type_frames[quest_type]) then
			local type_frame = CreateFrame("Frame", "QuestBuster_QuestLists_Type" .. type_count .. "Frame", qb.modules.quest_lists.frame, "QuestBuster_QuuestListBar_Template");
			type_frame:SetSize(324, 16);
			local expand = _G[type_frame:GetName() .. "_Expand"];
			_G[expand:GetName() .. "Label"]:SetText(QBL["WORLD_QUEST_" .. string.upper(quest_type)]);
			expand:SetSize(324, 16);
			expand:GetNormalTexture():SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
			expand:SetScript("OnEnter", function(self)
				expand:GetNormalTexture():SetVertexColor(QUEST_TYPE_HOVER_COLOR.r, QUEST_TYPE_HOVER_COLOR.g, QUEST_TYPE_HOVER_COLOR.b);
			end);
			expand:SetScript("OnLeave", function(self)
				if (qb.modules.quest_lists.type_expanded == quest_type) then
					expand:GetNormalTexture():SetVertexColor(QUEST_TYPE_EXPANDED_COLOR.r, QUEST_TYPE_EXPANDED_COLOR.g, QUEST_TYPE_EXPANDED_COLOR.b);
				else
					expand:GetNormalTexture():SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
				end
			end);
			expand:SetScript("OnClick", function(self)
				if (qb.modules.quest_lists.type_expanded == quest_type) then
					qb.modules.quest_lists.type_expanded = "";
				else
					qb.modules.quest_lists.type_expanded = quest_type;
				end
				qb.modules.quest_lists.filter_expanded = "";
				qb.modules.quest_lists:update();
			end);
			
			qb.modules.quest_lists.type_frames[quest_type] = {
				["name"] = quest_type,
				["frame"] = type_frame,
				["filters"] = {},
			};
		end
		
		for filter_name, child_frame in pairs(qb.modules.quest_lists.type_frames[quest_type]["filters"]) do
			child_frame["frame"]:Hide();
			child_frame["frame"].hideChildren();
		end
		
		local type_frame = qb.modules.quest_lists.type_frames[quest_type]["frame"];
		if (not previous_frame) then
			type_frame:SetPoint("TOPLEFT", qb.modules.quest_lists.frame, "TOPLEFT", 8, -6);
		else
			type_frame:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0);
		end
		
		local filter_count, filter_bars = qb.modules.quest_lists:processQuestTypeFilters(quest_type, quest_data, type_count);
		if (filter_count > 0) then
			local bar_height = 0;
			total_bars = total_bars + 1;
			if (qb.modules.quest_lists.type_expanded == quest_type) then
				total_bars = total_bars + filter_bars;
				bar_height = filter_bars * 16;
				_G[type_frame:GetName() .. "_Expand"]:GetNormalTexture():SetVertexColor(QUEST_TYPE_EXPANDED_COLOR.r, QUEST_TYPE_EXPANDED_COLOR.g, QUEST_TYPE_EXPANDED_COLOR.b);
			else
				_G[type_frame:GetName() .. "_Expand"]:GetNormalTexture():SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
			end
			type_frame:SetHeight(16 + bar_height);
			type_frame:Show();
			previous_frame = type_frame;
		else
			type_frame:Hide();
		end
		
		type_count = type_count + 1;
	end

	return type_count, total_bars;
end

function qb.modules.quest_lists:processQuestTypeFilters(quest_type, type_data, type_count)
	local total_bars = 0;

	local filter_count = 0;
	local previous_frame = nil;
	if (type_data and next(type_data)) then
		local quest_data = qb.modules.quest_lists.type_frames[quest_type];
		for filter_name, quest_ids in qb.omg:sortedpairs(type_data) do
			if (not qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]) then
				local filter_frame = CreateFrame("Frame", "QuestBuster_QuestLists_Type" .. type_count .. "_" .. filter_name .."Frame", qb.modules.quest_lists.frame, "QuestBuster_QuuestListBar_Template");
				filter_frame:SetPoint("TOPLEFT", quest_data["frame"], "TOPLEFT", 20, 0);
				filter_frame:SetSize(304, 16);
				local expand = _G[filter_frame:GetName() .. "_Expand"];
				_G[expand:GetName() .. "Label"]:SetText(qb.omg:trim(qb.omg:ucwords(filter_name)));
				expand:SetSize(304, 16);
				expand:GetNormalTexture():SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
				expand:SetScript("OnEnter", function(self)
					expand:GetNormalTexture():SetVertexColor(FILTER_HOVER_COLOR.r, FILTER_HOVER_COLOR.g, FILTER_HOVER_COLOR.b);
				end);
				expand:SetScript("OnLeave", function(self)
					if (qb.modules.quest_lists.filter_expanded == filter_name) then
						expand:GetNormalTexture():SetVertexColor(FILTER_EXPANDED_COLOR.r, FILTER_EXPANDED_COLOR.g, FILTER_EXPANDED_COLOR.b);
					else
						expand:GetNormalTexture():SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
					end
				end);
				expand:SetScript("OnClick", function(self)
					if (qb.modules.quest_lists.filter_expanded == filter_name) then
						qb.modules.quest_lists.filter_expanded = "";
					else
						qb.modules.quest_lists.filter_expanded = filter_name;
					end
					qb.modules.quest_lists:update();
				end);

				filter_frame.hideChildren = function()
					for quest_id, quest_data in pairs(qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]["quests"]) do
						quest_data["frame"]:Hide();
					end
				end
				
				qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name] = {
					["name"] = filter_name,
					["frame"] = filter_frame,
					["quests"] = {},
				};
			end
			
			for quest_id, quest_data in pairs(qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]["quests"]) do
				if (C_QuestLog.IsQuestFlaggedCompleted(quest_id)) then
					quest_data["frame"]:Hide();
					qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = nil;
				end
			end
			
			local filter_frame = qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]["frame"];
			if (not previous_frame) then
				filter_frame:SetPoint("TOPLEFT", quest_data["frame"], "TOPLEFT", 20, -16);
			else
				filter_frame:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0);
			end

			local quest_count, quest_bars = qb.modules.quest_lists:processQuestTypeFilterQuests(quest_type, filter_name, quest_ids, type_count, filter_count);
			if (quest_count > 0 and qb.modules.quest_lists.type_expanded == quest_type) then
				local bar_height = 0;
				total_bars = total_bars + 1;
				if (qb.modules.quest_lists.filter_expanded == filter_name) then
					total_bars = total_bars + quest_bars;
					bar_height = quest_bars * 16;
					_G[filter_frame:GetName() .. "_Expand"]:GetNormalTexture():SetVertexColor(FILTER_EXPANDED_COLOR.r, FILTER_EXPANDED_COLOR.g, FILTER_EXPANDED_COLOR.b);
				else
					_G[filter_frame:GetName() .. "_Expand"]:GetNormalTexture():SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
				end
				filter_frame:SetHeight(16 + bar_height);
				filter_frame:Show();
				previous_frame = filter_frame;
			else
				filter_frame:Hide();
			end
			
			filter_count = filter_count + 1;
		end
	end

	return filter_count, total_bars;
end

function qb.modules.quest_lists:processQuestTypeFilterQuests(quest_type, filter_name, quest_ids, type_count, filter_count)
	local total_bars = 0;

	local quest_count = 0;
	local previous_frame = nil;
	if (quest_ids and next(quest_ids)) then
		local filter_data = qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name];
		for _, quest_id in qb.omg:sortedpairs(quest_ids) do
			local filter_quest_data = qb.modules.world_quests.quest_data[quest_id];
			if (not filter_quest_data["completed"]) then
				if (not filter_data["quests"][quest_id]) then
					local quest_frame = CreateFrame("Frame", "QuestBuster_QuestLists_Type" .. type_count .. "_" .. filter_count .. "_" .. quest_id .."Frame", qb.modules.quest_lists.frame, "QuestBuster_QuuestListQuestBar_Template");
					quest_frame:SetPoint("TOPLEFT", filter_data["frame"], "TOPLEFT", 20, 0);
					quest_frame:SetSize(284, 16);

					local _, _, _, rarity, elite, tradeskill_line = C_QuestLog.GetQuestTagInfo(quest_id);
					local info = C_QuestLog.GetQuestTagInfo(quest_id);
					local rarity = info and info.quality or Enum.WorldQuestQuality.Common;
					local tradeskill_line = info.tradeskillLineID;
					local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);

					local expand = _G[quest_frame:GetName() .. "_Expand"];
					expand:SetSize(268, 16);
					expand:GetNormalTexture():SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
					_G[expand:GetName() .. "Label"]:SetText(title);
					--_G[expand:GetName() .. "Label"]:SetTextColor(color.r, color.g, color.b);
					expand:GetNormalTexture():SetVertexColor(QUEST_COLOR.r, QUEST_COLOR.g, QUEST_COLOR.b);
					expand:SetScript("OnEnter", function(self)
						expand:GetNormalTexture():SetVertexColor(QUEST_HOVER_COLOR.r, QUEST_HOVER_COLOR.g, QUEST_HOVER_COLOR.b);
						QuestBuster_QuestList_RewardTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
						qb.modules.quest_lists:setQuestTooltip(QuestBuster_QuestList_RewardTooltip, quest_id);
						QuestBuster_QuestList_RewardTooltip:Show();
					end);
					expand:SetScript("OnLeave", function(self)
						expand:GetNormalTexture():SetVertexColor(QUEST_COLOR.r, QUEST_COLOR.g, QUEST_COLOR.b);
						QuestBuster_QuestList_RewardTooltip:Hide();
					end);
					expand:SetScript("OnClick", function(self)
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

						local watch_type = C_QuestLog.GetQuestWatchType(quest_id);
						if (watch_type == Enum.QuestWatchType.Manual or (watch_type == Enum.QuestWatchType.Automatic and C_SuperTrack.GetSuperTrackedQuestID() == quest_id)) then
						--if (IsWorldQuestWatched(quest_id)) then
							BonusObjectiveTracker_UntrackWorldQuest(quest_id);
						else
							BonusObjectiveTracker_TrackWorldQuest(quest_id, Enum.QuestWatchType.Manual);
						end
					end);
					
					local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(qb.modules.world_quests.quest_data[quest_id]["type"], false, info.tradeskillLineID);
					_G[expand:GetName() .. "QuestIcon"]:SetAtlas(atlas, true);
					_G[expand:GetName() .. "QuestIcon"]:SetSize(width, 10);
					
					if (TomTom ~= nil) then
						local tomtom = _G[quest_frame:GetName() .. "_TomTom"];
						tomtom:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
							GameTooltip:SetText(QBL["WORLD_QUEST_TOMTOM"] .. title .. "\n" .. qb.modules.world_quests.quest_data[quest_id]["location"]["zone"]);
							GameTooltip:Show();
						end);
						tomtom:SetScript("OnLeave", function(self)
							GameTooltip:Hide();
						end);
						tomtom:SetScript("OnClick", function(self)
							local location_data = qb.modules.world_quests.quest_data[quest_id]["location"];
							TomTom:AddWaypoint(location_data["map_id"], location_data["x"], location_data["y"], {
								title = title,
								persistent = nil,
								minimap = true,
								world = true,
							});
							TomTom:SetClosestWaypoint();
						end);
						quest_frame:SetSize(284, 16);
						expand:SetSize(268, 16);
						tomtom:Show();
					else
						quest_frame:SetSize(284, 16);
						expand:SetSize(284, 16);
						_G[quest_frame:GetName() .. "_TomTom"]:Hide();
					end
					
					qb.modules.quest_lists.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = {
						["quest_id"] = quest_id,
						["quest_name"] = title,
						["frame"] = quest_frame,
					};
				end
				
				local quest_frame = filter_data["quests"][quest_id]["frame"];
				if (not previous_frame) then
					quest_frame:SetPoint("TOPLEFT", filter_data["frame"], "TOPLEFT", 20, -16);
				else
					quest_frame:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0);
				end
				
				local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(quest_id);
				if (minutes_left and minutes_left > 0 and minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
					_G[quest_frame:GetName() .. "_ExpandLabel"]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.a);
				end
				
				if (qb.modules.quest_lists.type_expanded == quest_type and qb.modules.quest_lists.filter_expanded == filter_name) then
					total_bars = total_bars + 1;
					quest_frame:Show();
					previous_frame = quest_frame;
				else
					quest_frame:Hide();
				end
				
				quest_count = quest_count + 1;
			end
		end
	end

	return quest_count, total_bars;
end

function qb.modules.quest_lists:setEmissaryTooltip(emissary_data)
	local faction_name, _, faction_standing = GetFactionInfoByID(emissary_data["faction_id"]);
	if (emissary_data["pending"] ~= nil) then
		GameTooltip:SetText(faction_name .. " - " .. QBL["EMISSARY_PENDING"]);
		GameTooltip:AddLine(emissary_data["pending"]);
	else
		GameTooltip:SetText(faction_name .. " - " .. getglobal("FACTION_STANDING_LABEL" .. faction_standing));
		GameTooltip:AddLine("Completed: " .. emissary_data["completed"] .. "/" .. emissary_data["total"]);
	end
		
	local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(emissary_data["quest_id"]);
	if (minutes_left and minutes_left > 0) then
		local color = NORMAL_FONT_COLOR;
		local time_str;
		if (minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			color = RED_FONT_COLOR;
			time_str = SecondsToTime(minutes_left * 60);
		elseif (minutes_left <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			time_str = SecondsToTime((minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60);
		elseif (minutes_left < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			time_str = D_HOURS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60);
		else
			time_str = D_DAYS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440);
		end
		GameTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(time_str), color:GetRGB());
	end
end

function qb.modules.quest_lists:setQuestTooltip(tooltip, quest_id)
	local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
	local info = C_QuestLog.GetQuestTagInfo(quest_id);
	local rarity = info and info.quality or Enum.WorldQuestQuality.Common;
	local color = WORLD_QUEST_QUALITY_COLORS[rarity];
	tooltip:SetText(title, color.r, color.g, color.b);
	
	if (faction_id) then
		local text = GetFactionInfoByID(faction_id);
		if (text) then
			if (capped) then
				tooltip:AddLine(text, GRAY_FONT_COLOR:GetRGB());
			else
				tooltip:AddLine(text);
			end
		end
	end
	
	if (qb.modules.world_quests.quest_data[quest_id] and qb.modules.world_quests.quest_data[quest_id]["location"]["zone"] ~= "") then
		tooltip:AddLine(QBG_CLR_LIGHTGREEN .. qb.modules.world_quests.quest_data[quest_id]["location"]["zone"]);
	end
	
	local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(quest_id);
	if (minutes_left and minutes_left > 0) then
		local color = NORMAL_FONT_COLOR;
		local time_str;
		if (minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			color = RED_FONT_COLOR;
			time_str = SecondsToTime(minutes_left * 60);
		elseif (minutes_left <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			time_str = SecondsToTime((minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60);
		elseif (minutes_left < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			time_str = D_HOURS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60);
		else
			time_str = D_DAYS:format(math.floor(minutes_left - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440);
		end
		tooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(time_str), color:GetRGB());
	end
	
	if (qb.modules.world_quests.quest_data[quest_id] and qb.modules.world_quests.quest_data[quest_id]["objectives"] > 0) then
		for i=1, qb.modules.world_quests.quest_data[quest_id]["objectives"] do
			local text, _, finished = GetQuestObjectiveInfo(quest_id, i, false);
			if (text and #text > 0) then
				local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				tooltip:AddLine(QUEST_DASH .. text, color.r, color.g, color.b, true);
			end
		end
	end
	
	tooltip:AddLine(QBL["WORLD_QUEST_TRACKING_TOOLTIP"]);
	
	GameTooltip_AddQuestRewardsToTooltip(tooltip, quest_id);
end

function qb.modules.quest_lists:lockFrame()
	if (not qb.settings:get().quest_list_frame.locked) then
		qb.settings:get().quest_list_frame.locked = true;
	else
		qb.settings:get().quest_list_frame.locked = false;
	end
	qb.modules.quest_lists:update();
end

function qb.modules.quest_lists:collapseFrame()
	if (_G["QuestBuster_QuestLists_Frame"]:IsShown()) then
		_G["QuestBuster_QuestLists_Frame"]:Hide();
		qb.settings:get().quest_list_frame.state = "collapsed";
	else
		_G["QuestBuster_QuestLists_Frame"]:Show();
		qb.settings:get().quest_list_frame.state = "expanded";
	end
	qb.modules.quest_lists:update();
end

function qb.modules.quest_lists:closeFrame()
	_G["QuestBuster_QuestLists_MoverFrame"]:Hide();
	_G["QuestBuster_QuestLists_Frame"]:Hide();
	if (not _G["QuestBuster_QuestLists_MoverFrame"]:IsShown()) then
		qb.settings:get().quest_list_frame.show = false;
	end
end

function qb.modules.quest_lists:dragFrame()
	local point, _, relative_point, x, y = _G["QuestBuster_QuestLists_MoverFrame"]:GetPoint();
	qb.settings:get().quest_list_frame.position.point = point;
	qb.settings:get().quest_list_frame.position.relative_point = relative_point;
	qb.settings:get().quest_list_frame.position.x = x;
	qb.settings:get().quest_list_frame.position.y = y;
	qb.modules.quest_lists:updatePosition();
end

function qb.modules.quest_lists:updatePosition()
	local position = qb.settings:get().quest_list_frame.position;
	_G["QuestBuster_QuestLists_MoverFrame"]:ClearAllPoints();
	_G["QuestBuster_QuestLists_MoverFrame"]:SetPoint(position.point, nil, position.relative_point, position.x, position.y);
end

function qb.modules.quest_lists:resetPosition()
	qb.settings:get().quest_list_frame.position = {
		point = "TOPLEFT",
		relative_point = "TOPLEFT",
		x = 490,
		y = -330,
	};
	qb.modules.quest_lists:updatePosition();
end

function QuestBuster_QuestListFrames_Toggle()
	qb.modules.quest_lists:collapseFrame();
end