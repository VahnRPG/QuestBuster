local _, qb = ...;

local MAX_EMISSARY_QUESTS = 3;

qb.quest_lists = {};
qb.quest_lists.frame = CreateFrame("Frame", "QuestBuster_QuestListsFrame", UIParent, SecureFrameTemplate);
qb.quest_lists.frame:RegisterEvent("ADDON_LOADED");
qb.quest_lists.frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit) then
		return qb.quest_lists[event] and qb.quest_lists[event](qb, ...)
	end
end);
qb.quest_lists.frames = {};
qb.quest_lists.type_expanded = "";
qb.quest_lists.filter_expanded = "";

function qb.quest_lists:ADDON_LOADED()
	local frame_backdrop = {
		bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	};
	
	for _, frame_data in pairs(QBG_QUEST_LIST_FRAMES) do
		--build mover frame
		local mover_frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "MoverFrame", frame_data["parent"]);
		mover_frame:SetFrameStrata(frame_data["strata"]);
		mover_frame:SetPoint("CENTER", frame_data["parent"]);
		mover_frame:SetSize(320, 10);
		mover_frame:EnableMouse(true);
		mover_frame:SetMovable(true);
		mover_frame:RegisterForDrag("LeftButton");
		mover_frame:SetScript("OnDragStart", function(self)
			if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].locked) then
				self.dragging = true;
				self:StartMoving();
			end
		end);
		mover_frame:SetScript("OnDragStop", function(self)
			if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].locked) then
				self.dragging = false;
				self:StopMovingOrSizing();
			end
		end);
		mover_frame:SetScript("OnUpdate", function(self)
			if (self.dragging) then
				qb.quest_lists:dragFrame(frame_data["name"]);
			end
		end);
		local mover_frame_name = mover_frame:GetName();
		
		mover_frame.texture = mover_frame:CreateTexture("BACKGROUND");
		mover_frame.texture:SetPoint("TOPLEFT");
		mover_frame.texture:SetSize(320, 16);
		mover_frame.texture:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover");
		
		mover_frame.label = mover_frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		mover_frame.label:SetPoint("CENTER");
		mover_frame.label:SetText("World Quests");
		
		--build mover frame - config button
		mover_frame.config = CreateFrame("Button", mover_frame_name .. "_ConfigMenu", mover_frame);
		mover_frame.config:SetPoint("TOPLEFT", mover_frame_name, "TOPLEFT", 8, 0);
		mover_frame.config:SetSize(16, 16);
		mover_frame.config:SetScript("OnClick", function(self)
			securecall("QuestBuster_Config_Show");
		end);
		
		mover_frame.config.icon = mover_frame.config:CreateTexture("ARTWORK");
		mover_frame.config.icon:SetAllPoints();
		mover_frame.config.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Menu");
		
		--build mover frame - lock button
		mover_frame.lock = CreateFrame("Button", mover_frame_name .. "_LockFrame", mover_frame);
		mover_frame.lock:SetPoint("TOPRIGHT", mover_frame_name, "TOPRIGHT", -32, 0);
		mover_frame.lock:SetSize(16, 16);
		mover_frame.lock:SetScript("OnClick", function(self)
			qb.quest_lists:lockFrame(frame_data["name"]);
		end);
		
		mover_frame.lock.icon = mover_frame.lock:CreateTexture("ARTWORK");
		mover_frame.lock.icon:SetAllPoints();
		mover_frame.lock.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
		
		--build mover frame - collapse button
		mover_frame.collapse = CreateFrame("Button", mover_frame_name .. "_CollapseFrame", mover_frame);
		mover_frame.collapse:SetPoint("TOPLEFT", mover_frame_name .. "_LockFrame", "TOPRIGHT", -2, 0);
		mover_frame.collapse:SetSize(16, 16);
		mover_frame.collapse:SetScript("OnClick", function(self)
			qb.quest_lists:collapseFrame(frame_data["name"]);
		end);
		
		mover_frame.collapse.icon = mover_frame.collapse:CreateTexture("ARTWORK");
		mover_frame.collapse.icon:SetAllPoints();
		mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
		
		--build mover frame - close button
		mover_frame.close = CreateFrame("Button", mover_frame_name .. "_CloseFrame", mover_frame);
		mover_frame.close:SetPoint("TOPLEFT", mover_frame_name .. "_CollapseFrame", "TOPRIGHT", -2, 0);
		mover_frame.close:SetSize(16, 16);
		mover_frame.close:SetScript("OnClick", function(self)
			qb.quest_lists:closeFrame(frame_data["name"]);
		end);
		
		mover_frame.close.icon = mover_frame.close:CreateTexture("ARTWORK");
		mover_frame.close.icon:SetAllPoints();
		mover_frame.close.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Close");
		
		--build base frame
		local frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "Frame", frame_data["parent"], SecureFrameTemplate);
		frame:SetFrameStrata(frame_data["strata"]);
		frame:SetPoint("TOPLEFT", mover_frame_name, "BOTTOMLEFT", 0, 2);
		frame:SetSize(320, 10);
		frame:SetBackdrop(frame_backdrop);
		frame.emissary_frames = {};
		frame.type_frames = {};
		local frame_name = frame:GetName();
		
		--build base frame - emissary buttons
		--[[
		for i=1, MAX_EMISSARY_QUESTS do
			local emissary_frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "Emissary" .. i .. "Frame", frame, SecureFrameTemplate);
			emissary_frame:SetFrameStrata(frame_data["strata"]);
			emissary_frame:SetPoint("TOPRIGHT", frame_name, "TOPLEFT", 0, ((i - 1) * -16) - 5);
			emissary_frame:SetSize(16, 16);
			
			emissary_frame.icon = emissary_frame:CreateTexture("ARTWORK");
			emissary_frame.icon:SetAllPoints();
			emissary_frame.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
			
			frame.emissary_frames[i] = emissary_frame;
		end
		]]--
		
		--save frame
		qb.quest_lists.frames[frame_data["name"]] = {
			["name"] = frame_data["name"],
			["frame"] = frame,
			["mover_frame"] = mover_frame,
			["tooltip"] = frame_data["tooltip"],
		};
		
		qb.quest_lists:updatePosition(frame_data["name"]);
	end
	
	qb.quest_lists.frame:UnregisterEvent("ADDON_LOADED");
end

function qb.quest_lists:update()
	for _, frame_data in pairs(qb.quest_lists.frames) do
		local config = QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]];
		local frame = frame_data["frame"];
		local mover_frame = frame_data["mover_frame"];
		
		if (config.show and qb.world_quests.quests.count > 0) then
			if (config.state == "expanded") then
				local type_count = 0;
				local type_filter_count = 0;
				local type_filter_quest_count = 0;
				for quest_type, quest_data in qb.omg:sortedpairs(qb.world_quests.quests.quests) do
					if (not frame.type_frames[quest_type]) then
						local type_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", frame, SecureFrameTemplate);
						type_frame:SetSize(308, 16);
						type_frame.frame_name = type_count;
						
						type_frame.expand = CreateFrame("Button", type_frame:GetName() .. "_ExpandFrame", type_frame);
						type_frame.expand:SetPoint("TOPLEFT", type_frame, "TOPLEFT", 0, 0);
						type_frame.expand:SetSize(308, 16);
						type_frame.expand:SetScript("OnEnter", function(self)
							frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type_Hover");
						end);
						type_frame.expand:SetScript("OnLeave", function(self)
							if (qb.quest_lists.type_expanded == quest_type) then
								frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type_Expanded");
							else
								frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type");
							end
						end);
						type_frame.expand:SetScript("OnClick", function(self)
							if (qb.quest_lists.type_expanded == quest_type) then
								qb.quest_lists.type_expanded = "";
							else
								qb.quest_lists.type_expanded = quest_type;
							end
							qb.quest_lists.filter_expanded = "";
							qb.quest_lists:update();
						end);
						
						type_frame.expand.icon = type_frame.expand:CreateTexture("ARTWORK");
						type_frame.expand.icon:SetPoint("TOPLEFT", type_frame.expand, "TOPLEFT", -2, 0);
						type_frame.expand.icon:SetSize(308, 16);
						type_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type");
						
						type_frame.expand.label = type_frame.expand:CreateFontString(nil, "ARTWORK", "GameFontNormal");
						type_frame.expand.label:SetPoint("CENTER");
						type_frame.expand.label:SetText(QBL["WORLD_QUEST_" .. string.upper(quest_type)]);
						
						frame.type_frames[quest_type] = {
							["name"] = quest_type,
							["frame"] = type_frame,
							["filters"] = {},
						};
					end
					
					local type_frame = frame.type_frames[quest_type]["frame"];
					if (type_count == 0) then
						type_frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -6);
					else
						type_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. (type_count - 1) .."Frame", "BOTTOMLEFT", 0, 4);
					end
					
					for _, child_frame in pairs(frame.type_frames[quest_type]["filters"]) do
						child_frame["frame"]:Hide();
					end
					
					local total_quests = 0;
					local filter_count = 0;
					local filters_displayed = 0;
					local height_padding = 0;
					for filter_name, quest_ids in qb.omg:sortedpairs(quest_data) do
						if (not frame.type_frames[quest_type]["filters"][filter_name]) then
							local filter_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .."Frame", frame, SecureFrameTemplate);
							filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, 0);
							filter_frame:SetSize(288, 16);
							filter_frame.frame_name = type_count .. "_" .. filter_count;
						
							filter_frame.expand = CreateFrame("Button", filter_frame:GetName() .. "_ExpandFrame", type_frame);
							filter_frame.expand:SetPoint("TOPLEFT", filter_frame, "TOPLEFT", -2, 0);
							filter_frame.expand:SetSize(288, 16);
							filter_frame.expand:SetScript("OnEnter", function(self)
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter_Hover");
							end);
							filter_frame.expand:SetScript("OnLeave", function(self)
								if (qb.quest_lists.filter_expanded == filter_name) then
									frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter_Expanded");
								else
									frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter");
								end
							end);
							filter_frame.expand:SetScript("OnClick", function(self)
								if (qb.quest_lists.filter_expanded == filter_name) then
									qb.quest_lists.filter_expanded = "";
								else
									qb.quest_lists.filter_expanded = filter_name;
								end
								qb.quest_lists:update();
							end);
							
							filter_frame.expand.icon = filter_frame.expand:CreateTexture("ARTWORK");
							filter_frame.expand.icon:SetAllPoints();
							filter_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter");
							
							filter_frame.expand.label = filter_frame.expand:CreateFontString(nil, "ARTWORK", "GameFontNormal");
							filter_frame.expand.label:SetPoint("CENTER");
							filter_frame.expand.label:SetText(qb.omg:ucwords(filter_name));
							
							frame.type_frames[quest_type]["filters"][filter_name] = {
								["name"] = filter_name,
								["frame"] = filter_frame,
								["quests"] = {},
							};
						end
						
						local filter_frame = frame.type_frames[quest_type]["filters"][filter_name]["frame"];
						filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, (filters_displayed * -15) - height_padding - 15);
						
						local total_filter_quests = 0;
						local quest_count = 0;
						local quests_displayed = 0;
						if (quest_ids and next(quest_ids)) then
							for _, quest_id in pairs(quest_ids) do
								if (not frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]) then
									local tag_id, tag_name, world_quest_type, rarity, elite, tradeskill_line = GetQuestTagInfo(quest_id);
									local tradeskill_line_id = tradeskill_line and select(7, GetProfessionInfo(tradeskill_line));
									local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
									
									local tooltip = frame_data["tooltip"];
									local quest_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .. "_" .. quest_count .."Frame", frame, SecureFrameTemplate);
									quest_frame:SetPoint("TOPLEFT", frame.type_frames[quest_type]["filters"][filter_name]["frame"], "TOPLEFT", 20, (quest_count * -15) - 15);
									quest_frame:SetSize(268, 10);
									quest_frame.frame_name = type_count .. "_" .. filter_count .. "_" .. quest_count;
									
									quest_frame.expand = CreateFrame("Button", quest_frame:GetName() .. "_ExpandFrame", type_frame);
									quest_frame.expand:SetPoint("TOPLEFT", quest_frame, "TOPLEFT", -2, 0);
									quest_frame.expand:SetSize(268, 16);
									quest_frame.expand:SetScript("OnEnter", function(self)
										frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Quest_Hover");
										tooltip:SetOwner(self, "ANCHOR_CURSOR");
										qb.quest_lists:setQuestTooltip(tooltip, quest_id);
										tooltip:Show();
									end);
									quest_frame.expand:SetScript("OnLeave", function(self)
										frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Quest");
										tooltip:Hide();
										if (_G["qb.GameTooltip.ItemTooltip"]) then
											_G["qb.GameTooltip.ItemTooltip"]:Hide();
										end
									end);
									quest_frame.expand:SetScript("OnClick", function(self)
										PlaySound("igMainMenuOptionCheckBoxOn");
										if (IsWorldQuestWatched(quest_id)) then
											BonusObjectiveTracker_UntrackWorldQuest(quest_id);
										else
											BonusObjectiveTracker_TrackWorldQuest(quest_id);
										end
									end);
									
									quest_frame.expand.icon = quest_frame.expand:CreateTexture("ARTWORK");
									quest_frame.expand.icon:SetAllPoints();
									quest_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Quest");
									
									quest_frame.expand.label = quest_frame.expand:CreateFontString(nil, "ARTWORK", "GameFontWhiteTiny");
									quest_frame.expand.label:SetPoint("CENTER");
									quest_frame.expand.label:SetText(title);
									
									quest_frame.quest_type = CreateFrame("Button", quest_frame:GetName() .. "_QuestType", quest_frame.expand);
									quest_frame.quest_type:SetPoint("TOPRIGHT", quest_frame.expand.label, "TOPLEFT", -5, 0);
									quest_frame.quest_type:SetSize(10, 10);
									
									quest_frame.quest_type.icon = quest_frame.quest_type:CreateTexture("ARTWORK");
									quest_frame.quest_type.icon:SetAllPoints();
									if (qb.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PVP) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-pvp-ffa", true);
									elseif (qb.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PET_BATTLE) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-petbattle", true);
									elseif (qb.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskill_line_id]) then
										quest_frame.quest_type.icon:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskill_line_id], true);
									elseif (qb.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_DUNGEON) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-dungeon", true);
									else
										quest_frame.quest_type.icon:SetAtlas("worldquest-questmarker-questbang");
									end
									
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = {
										["name"] = quest_id,
										["frame"] = quest_frame,
									};
								end
								
								local filter_quest_frame = frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"];
								filter_quest_frame:SetPoint("TOPLEFT", frame.type_frames[quest_type]["filters"][filter_name]["frame"], "TOPLEFT", 20, (quests_displayed * -15) - height_padding - 15);
								
								local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(quest_id);
								if (timeLeftMinutes and timeLeftMinutes > 0) then
									local color = HIGHLIGHT_FONT_COLOR;
									if ( timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
										color = RED_FONT_COLOR;
									end
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].expand.label:SetTextColor(color.r, color.g, color.b, color.a);
								end
								
								if (qb.quest_lists.filter_expanded == filter_name) then
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"]:Show();
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].expand:Show();
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].quest_type:Show();
									quests_displayed = quests_displayed + 1;
								else
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"]:Hide();
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].expand:Hide();
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"].quest_type:Hide();
								end
								
								total_quests = total_quests + 1;
								total_filter_quests = total_filter_quests + 1;
								quest_count = quest_count + 1;
							end
						end
						
						if (total_filter_quests > 0 and qb.quest_lists.type_expanded == quest_type) then
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:SetHeight(10 + (quests_displayed * 15));
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:Show();
							if (qb.quest_lists.filter_expanded == filter_name) then
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter_Expanded");
							else
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Filter");
							end
							frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand:Show();
							filters_displayed = filters_displayed + 1;
							height_padding = height_padding + (quests_displayed * 15);
						else
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:Hide();
							frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand:Hide();
						end
						
						filter_count = filter_count + 1;
						type_filter_quest_count = type_filter_quest_count + quests_displayed;
					end
					
					type_filter_count = type_filter_count + filters_displayed;
					
					if (total_quests > 0) then
						frame.type_frames[quest_type]["frame"]:SetHeight(20 + (filters_displayed * 15) + height_padding);
						frame.type_frames[quest_type]["frame"]:Show();
						if (qb.quest_lists.type_expanded == quest_type) then
							frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type_Expanded");
						else
							frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Type");
						end
						frame.type_frames[quest_type]["frame"].expand:Show();
					else
						frame.type_frames[quest_type]["frame"]:Hide();
						frame.type_frames[quest_type]["frame"].expand:Hide();
					end
					
					type_count = type_count + 1;
				end
				
				mover_frame:Show();
				mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
				if (type_count > 0 or type_filter_count > 0 or type_filter_quest_count > 0) then
					frame:SetHeight(16 + (type_count * 15) + (type_filter_count * 15) + (type_filter_quest_count * 15));
					frame:Show();
				else
					frame:SetHeight(28);
					frame:Show();
				end
			else
				mover_frame:Show();
				mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Expand");
				frame:Hide();
			end
			
			if (not config.locked) then
				mover_frame.lock.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
			else
				mover_frame.lock.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Locked");
			end
		else
			mover_frame:Hide();
			frame:Hide();
		end
	end
end

function qb.quest_lists:setQuestTooltip(tooltip, questID)
	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID);
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questID);
	local color = WORLD_QUEST_QUALITY_COLORS[rarity];
	tooltip:SetText(title, color.r, color.g, color.b);
	
	if ( factionID ) then
		local factionName = GetFactionInfoByID(factionID);
		if ( factionName ) then
			if (capped) then
				tooltip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB());
			else
				tooltip:AddLine(factionName);
			end
		end
	end

	if (qb.world_quests.quest_data[questID] and qb.world_quests.quest_data[questID]["zone"] ~= "") then
		tooltip:AddLine(QBG_CLR_LIGHTGREEN .. qb.world_quests.quest_data[questID]["zone"]);
	end
	
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
	if (timeLeftMinutes and timeLeftMinutes > 0) then
		local color = NORMAL_FONT_COLOR;
		local timeString;
		if ( timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
			color = RED_FONT_COLOR;
			timeString = SecondsToTime(timeLeftMinutes * 60);
		elseif (timeLeftMinutes <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			timeString = SecondsToTime((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60);
		elseif (timeLeftMinutes < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
			timeString = D_HOURS:format(math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60);
		else
			timeString = D_DAYS:format(math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440);
		end
		tooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), color:GetRGB());
	end
	
	if (qb.world_quests.quest_data[questID] and qb.world_quests.quest_data[questID]["objectives"] > 0) then
		for objectiveIndex = 1, qb.world_quests.quest_data[questID]["objectives"] do
			local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false);
			if ( objectiveText and #objectiveText > 0 ) then
				local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				tooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
			end
		end
	end
	
	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 ) then
		tooltip:AddLine(" ");
		tooltip:AddLine(QUEST_REWARDS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		local hasAnySingleLineRewards = false;
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			tooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- money
		local money = GetQuestLogRewardMoney(questID);
		if ( money > 0 ) then
			SetTooltipMoney(tooltip, money, nil);
			hasAnySingleLineRewards = true;
		end	
		local artifactXP = GetQuestLogRewardArtifactXP(questID);
		if ( artifactXP > 0 ) then
			tooltip:AddLine(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- currency		
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(texture, numItems, name);
			tooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		
		-- items
		local numQuestRewards = GetNumQuestLogRewards(questID);
		if numQuestRewards > 0 then
			if ( hasAnySingleLineRewards ) then
				tooltip:AddLine(" ");
			end
			
			local item_frame = {};
			if (tooltip == WorldMapTooltip) then
				item_frame = WorldMapTooltip.ItemTooltip;
			elseif (tooltip == GameTooltip) then
				if (not _G["qb.GameTooltip.ItemTooltip"]) then
					local frame = CreateFrame("Frame", "qb.GameTooltip.ItemTooltip", GameTooltip, "EmbeddedItemTooltip");
					frame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", 10, 8);
					frame:SetSize(100, 100);
					frame:SetAttribute("yspacing", 13);
					frame:Hide();
					frame.Tooltip.shoppingTooltips = { };
				end
				item_frame = _G["qb.GameTooltip.ItemTooltip"];
			end
			if not EmbeddedItemTooltip_SetItemByQuestReward(item_frame, 1, questID) then
				tooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			end
			if (_G["qb.GameTooltip.ItemTooltip"]) then
				GameTooltip_InsertFrame(GameTooltip, _G["qb.GameTooltip.ItemTooltip"]);
			end
		end
	end
	
	tooltip:AddLine(" ");
	tooltip:AddLine(QBL["WORLD_QUEST_TRACKING_TOOLTIP"]);
end

function qb.quest_lists:lockFrame(frame_name)
	if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked) then
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked = true;
	else
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked = false;
	end
	qb.quest_lists:update();
end

function qb.quest_lists:collapseFrame(frame_name)
	if (_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:IsShown()) then
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].state = "collapsed";
	else
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Show();
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].state = "expanded";
	end
	qb.quest_lists:update();
end

function qb.quest_lists:closeFrame(frame_name)
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:Hide();
	_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
	if (not _G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:IsShown()) then
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].show = false;
	end
end

function qb.quest_lists:dragFrame(frame_name)
	local point, _, relative_point, x, y = _G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:GetPoint();
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position.point = point;
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position.relative_point = relative_point;
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position.x = x;
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position.y = y;
	qb.quest_lists:updatePosition(frame_name);
end

function qb.quest_lists:updatePosition(frame_name)
	local position = QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position;
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:ClearAllPoints();
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:SetPoint(position.point, nil, position.relative_point, position.x, position.y);
end

function qb.quest_lists:resetPosition(frame_name)
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position = {
		point = "TOPLEFT",
		relative_point = "TOPLEFT",
		x = 490,
		y = -330,
	};
	qb.quest_lists:updatePosition(frame_name);
end

function QuestBuster_QuestListFrames_Toggle()
	qb.quest_lists:collapseFrame("Default");
end