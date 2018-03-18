local _, qb = ...;

local MAX_EMISSARY_QUESTS = WorldMapFrame.UIElementsFrame.BountyBoard.minimumTabsToDisplay;
--local MAX_EMISSARY_QUESTS = 3;

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
qb.modules.quest_lists.frame = CreateFrame("Frame", "QuestBuster_ModulesQuestListsFrame", UIParent);
qb.modules.quest_lists.frame:RegisterEvent("ADDON_LOADED");
qb.modules.quest_lists.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.modules.quest_lists[event] and qb.modules.quest_lists[event](qb, ...)
	end
end);
qb.modules.quest_lists.frames = {};
qb.modules.quest_lists.type_expanded = "";
qb.modules.quest_lists.filter_expanded = "";

function qb.modules.quest_lists:ADDON_LOADED()
	local frame_backdrop = {
		bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	};
	
	for frame_id, frame_data in pairs(QBG_QUEST_LIST_FRAMES) do
		--build mover frame
		local mover_frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "MoverFrame", frame_data["parent"]);
		mover_frame:SetFrameStrata(frame_data["strata"]);
		mover_frame:SetPoint("CENTER", frame_data["parent"]);
		mover_frame:SetSize(336, 10);
		mover_frame:RegisterForDrag("LeftButton");
		mover_frame:SetScript("OnDragStart", function(self)
			if (not qb.settings:get().quest_list_frames[frame_data["name"]].locked) then
				self.dragging = true;
				self:StartMoving();
			end
		end);
		mover_frame:SetScript("OnDragStop", function(self)
			if (not qb.settings:get().quest_list_frames[frame_data["name"]].locked) then
				self.dragging = false;
				self:StopMovingOrSizing();
			end
		end);
		mover_frame:SetScript("OnUpdate", function(self)
			if (self.dragging) then
				qb.modules.quest_lists:dragFrame(frame_data["name"]);
			end
		end);
		local mover_frame_name = mover_frame:GetName();
		
		mover_frame.texture = mover_frame:CreateTexture("BACKGROUND");
		mover_frame.texture:SetPoint("TOPLEFT");
		mover_frame.texture:SetSize(336, 16);
		mover_frame.texture:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover");
		
		mover_frame.label = mover_frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		mover_frame.label:SetPoint("CENTER");
		mover_frame.label:SetText(QBL["WORLD_QUEST_HEADER"]);
		
		--build mover frame - config button
		mover_frame.config = CreateFrame("Button", mover_frame_name .. "_ConfigMenu", mover_frame);
		mover_frame.config:SetPoint("TOPLEFT", mover_frame_name, "TOPLEFT", 8, 0);
		mover_frame.config:SetSize(16, 16);
		mover_frame.config:SetScript("OnClick", function(self)
			if (WorldMapFrame:IsShown()) then
				ToggleFrame(WorldMapFrame);
			end
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
			qb.modules.quest_lists:lockFrame(frame_data["name"]);
		end);
		
		mover_frame.lock.icon = mover_frame.lock:CreateTexture("ARTWORK");
		mover_frame.lock.icon:SetAllPoints();
		mover_frame.lock.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
		
		--build mover frame - collapse button
		mover_frame.collapse = CreateFrame("Button", mover_frame_name .. "_CollapseFrame", mover_frame);
		mover_frame.collapse:SetPoint("TOPLEFT", mover_frame_name .. "_LockFrame", "TOPRIGHT", -2, 0);
		mover_frame.collapse:SetSize(16, 16);
		mover_frame.collapse:SetScript("OnClick", function(self)
			qb.modules.quest_lists:collapseFrame(frame_data["name"]);
		end);
		
		mover_frame.collapse.icon = mover_frame.collapse:CreateTexture("ARTWORK");
		mover_frame.collapse.icon:SetAllPoints();
		mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
		
		--build mover frame - close button
		mover_frame.close = CreateFrame("Button", mover_frame_name .. "_CloseFrame", mover_frame);
		mover_frame.close:SetPoint("TOPLEFT", mover_frame_name .. "_CollapseFrame", "TOPRIGHT", -2, 0);
		mover_frame.close:SetSize(16, 16);
		mover_frame.close:SetScript("OnClick", function(self)
			qb.modules.quest_lists:closeFrame(frame_data["name"]);
		end);
		
		mover_frame.close.icon = mover_frame.close:CreateTexture("ARTWORK");
		mover_frame.close.icon:SetAllPoints();
		mover_frame.close.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Close");
		
		--build base frame
		local frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "Frame", frame_data["parent"]);
		frame:SetFrameStrata(frame_data["strata"]);
		frame:SetPoint("TOPLEFT", mover_frame_name, "BOTTOMLEFT", 0, 2);
		frame:SetSize(336, 10);
		frame:SetBackdrop(frame_backdrop);
		frame.emissary_frames = {};
		frame.type_frames = {};
		local frame_name = frame:GetName();
		
		--build base frame - emissary buttons
		for i=1, MAX_EMISSARY_QUESTS do
			local emissary_frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "Emissary" .. i .. "Frame", frame);
			emissary_frame:SetFrameStrata(frame_data["strata"]);
			emissary_frame:SetPoint("TOPRIGHT", frame_name, "TOPLEFT", 0, ((i - 1) * -16) - 5);
			emissary_frame:SetSize(16, 16);
			emissary_frame.emissary_data = {};
			emissary_frame:SetScript("OnEnter", function(self)
				frame_data["tooltip"]:SetOwner(self, "ANCHOR_CURSOR");
				qb.modules.quest_lists:setEmissaryTooltip(frame_data["tooltip"], self.emissary_data);
				frame_data["tooltip"]:Show();
			end);
			emissary_frame:SetScript("OnLeave", function(self)
				frame_data["tooltip"]:Hide();
			end);
			
			emissary_frame.icon = emissary_frame:CreateTexture("ARTWORK");
			emissary_frame.icon:SetAllPoints();

			emissary_frame.check_icon = CreateFrame("Frame", nil, emissary_frame);
			emissary_frame.check_icon:SetPoint("TOPLEFT", emissary_frame, "TOPLEFT", -(emissary_frame:GetWidth() * .25), (emissary_frame:GetHeight() * .25));
			emissary_frame.check_icon:SetSize(emissary_frame:GetWidth() * 1.5, emissary_frame:GetHeight() * 1.5);
			
			emissary_frame.check_icon.icon = emissary_frame.check_icon:CreateTexture("ARTWORK");
			emissary_frame.check_icon.icon:SetAllPoints();
			emissary_frame.check_icon.icon:SetAtlas("worldquest-tracker-checkmark", true);
			
			frame.emissary_frames[i] = emissary_frame;
		end
		
		--save frame
		qb.modules.quest_lists.frames[frame_id] = {
			["name"] = frame_data["name"],
			["frame"] = frame,
			["mover_frame"] = mover_frame,
			["tooltip"] = frame_data["tooltip"],
		};
		
		qb.modules.quest_lists:updatePosition(frame_data["name"]);
	end
	
	qb.modules.quest_lists.frame:UnregisterEvent("ADDON_LOADED");
end

function qb.modules.quest_lists:update()
	for frame_id, frame_data in pairs(qb.modules.quest_lists.frames) do
		local config = qb.settings:get().quest_list_frames[frame_data["name"]];
		local frame = frame_data["frame"];
		local mover_frame = frame_data["mover_frame"];
		
		if (config.show and qb.modules.world_quests.quests.count > 0) then
			mover_frame:SetParent(QBG_QUEST_LIST_FRAMES[frame_id]["parent"]);
			mover_frame:SetFrameStrata(QBG_QUEST_LIST_FRAMES[frame_id]["strata"]);
			
			frame:SetParent(QBG_QUEST_LIST_FRAMES[frame_id]["parent"]);
			frame:SetFrameStrata(QBG_QUEST_LIST_FRAMES[frame_id]["strata"]);
			
			if (config.state == "expanded") then
				local type_count = 0;
				local type_filter_count = 0;
				local type_filter_quest_count = 0;
				for quest_type, quest_data in qb.omg:sortedpairs(qb.modules.world_quests.quests.quests) do
					if (not frame.type_frames[quest_type]) then
						local type_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", frame);
						type_frame:SetSize(324, 16);
						type_frame.frame_name = type_count;
						
						type_frame.expand = CreateFrame("Button", type_frame:GetName() .. "_ExpandFrame", type_frame);
						type_frame.expand:SetPoint("TOPLEFT", type_frame, "TOPLEFT", 0, 0);
						type_frame.expand:SetSize(324, 16);
						type_frame.expand:SetScript("OnEnter", function(self)
							type_frame.expand.icon:SetVertexColor(QUEST_TYPE_HOVER_COLOR.r, QUEST_TYPE_HOVER_COLOR.g, QUEST_TYPE_HOVER_COLOR.b);
						end);
						type_frame.expand:SetScript("OnLeave", function(self)
							if (qb.modules.quest_lists.type_expanded == quest_type) then
								type_frame.expand.icon:SetVertexColor(QUEST_TYPE_EXPANDED_COLOR.r, QUEST_TYPE_EXPANDED_COLOR.g, QUEST_TYPE_EXPANDED_COLOR.b);
							else
								type_frame.expand.icon:SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
							end
						end);
						type_frame.expand:SetScript("OnClick", function(self)
							if (qb.modules.quest_lists.type_expanded == quest_type) then
								qb.modules.quest_lists.type_expanded = "";
							else
								qb.modules.quest_lists.type_expanded = quest_type;
							end
							qb.modules.quest_lists.filter_expanded = "";
							qb.modules.quest_lists:update();
						end);
						
						type_frame.expand.icon = type_frame.expand:CreateTexture("ARTWORK");
						type_frame.expand.icon:SetPoint("TOPLEFT", type_frame.expand, "TOPLEFT", -2, 0);
						type_frame.expand.icon:SetSize(324, 16);
						type_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Bar");
						type_frame.expand.icon:SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
						
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
							local filter_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .."Frame", frame);
							filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, 0);
							filter_frame:SetSize(304, 16);
							filter_frame.frame_name = type_count .. "_" .. filter_count;
							
							filter_frame.expand = CreateFrame("Button", filter_frame:GetName() .. "_ExpandFrame", type_frame);
							filter_frame.expand:SetPoint("TOPLEFT", filter_frame, "TOPLEFT", -2, 0);
							filter_frame.expand:SetSize(304, 16);
							filter_frame.expand:SetScript("OnEnter", function(self)
								filter_frame.expand.icon:SetVertexColor(FILTER_HOVER_COLOR.r, FILTER_HOVER_COLOR.g, FILTER_HOVER_COLOR.b);
							end);
							filter_frame.expand:SetScript("OnLeave", function(self)
								if (qb.modules.quest_lists.filter_expanded == filter_name) then
									filter_frame.expand.icon:SetVertexColor(FILTER_EXPANDED_COLOR.r, FILTER_EXPANDED_COLOR.g, FILTER_EXPANDED_COLOR.b);
								else
									filter_frame.expand.icon:SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
								end
							end);
							filter_frame.expand:SetScript("OnClick", function(self)
								if (qb.modules.quest_lists.filter_expanded == filter_name) then
									qb.modules.quest_lists.filter_expanded = "";
								else
									qb.modules.quest_lists.filter_expanded = filter_name;
								end
								qb.modules.quest_lists:update();
							end);
							
							filter_frame.expand.icon = filter_frame.expand:CreateTexture("ARTWORK");
							filter_frame.expand.icon:SetAllPoints();
							filter_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Bar");
							filter_frame.expand.icon:SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
							
							filter_frame.expand.label = filter_frame.expand:CreateFontString(nil, "ARTWORK", "GameFontNormal");
							filter_frame.expand.label:SetPoint("CENTER");
							filter_frame.expand.label:SetText(qb.omg:trim(qb.omg:ucwords(filter_name)));
							
							frame.type_frames[quest_type]["filters"][filter_name] = {
								["name"] = filter_name,
								["frame"] = filter_frame,
								["quests"] = {},
							};
						end
						
						local filter_frame = frame.type_frames[quest_type]["filters"][filter_name]["frame"];
						filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, (filters_displayed * -15) - height_padding - 15);
						
						if (frame.type_frames[quest_type]["filters"][filter_name]["quests"] and next(frame.type_frames[quest_type]["filters"][filter_name]["quests"])) then
							for quest_id, quest_data in pairs(frame.type_frames[quest_type]["filters"][filter_name]["quests"]) do
								if (IsQuestFlaggedCompleted(quest_id)) then
									quest_data["frame"]:Hide();
									quest_data["frame"].expand:Hide();
									quest_data["frame"].quest_type:Hide();
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = nil;
								end
							end
						end

						local total_filter_quests = 0;
						local quest_count = 0;
						local quests_displayed = 0;
						if (quest_ids and next(quest_ids)) then
							for _, quest_id in qb.omg:sortedpairs(quest_ids) do
								if (not frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]) then
									local _, _, _, rarity, elite, tradeskill_line = GetQuestTagInfo(quest_id);
									local color = WORLD_QUEST_QUALITY_COLORS[rarity];
									local tradeskill_line_id = tradeskill_line and select(7, GetProfessionInfo(tradeskill_line));
									local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
									
									local tooltip = frame_data["tooltip"];
									local quest_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .. "_" .. quest_count .."Frame", frame);
									quest_frame:SetPoint("TOPLEFT", frame.type_frames[quest_type]["filters"][filter_name]["frame"], "TOPLEFT", 20, (quest_count * -15) - 15);
									quest_frame:SetSize(268, 16);
									quest_frame.frame_name = type_count .. "_" .. filter_count .. "_" .. quest_count;
									
									quest_frame.expand = CreateFrame("Button", quest_frame:GetName() .. "_ExpandFrame", type_frame);
									quest_frame.expand:SetPoint("TOPLEFT", quest_frame, "TOPLEFT", -2, 0);
									quest_frame.expand:SetSize(268, 16);
									quest_frame.expand:SetScript("OnEnter", function(self)
										quest_frame.expand.icon:SetVertexColor(QUEST_HOVER_COLOR.r, QUEST_HOVER_COLOR.g, QUEST_HOVER_COLOR.b);
										tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
										qb.modules.quest_lists:setQuestTooltip(tooltip, quest_id);
										tooltip:Show();
									end);
									quest_frame.expand:SetScript("OnLeave", function(self)
										quest_frame.expand.icon:SetVertexColor(QUEST_COLOR.r, QUEST_COLOR.g, QUEST_COLOR.b);
										tooltip:Hide();
										if (_G["qb.GameTooltip.ItemTooltip"]) then
											_G["qb.GameTooltip.ItemTooltip"]:Hide();
										end
									end);
									quest_frame.expand:SetScript("OnClick", function(self)
										PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
										if (IsWorldQuestWatched(quest_id)) then
											BonusObjectiveTracker_UntrackWorldQuest(quest_id);
										else
											BonusObjectiveTracker_TrackWorldQuest(quest_id);
										end
									end);
									
									quest_frame.expand.icon = quest_frame.expand:CreateTexture("ARTWORK");
									quest_frame.expand.icon:SetAllPoints();
									quest_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_Bar");
									quest_frame.expand.icon:SetVertexColor(QUEST_COLOR.r, QUEST_COLOR.g, QUEST_COLOR.b);
									
									quest_frame.expand.label = quest_frame.expand:CreateFontString(nil, "ARTWORK", "GameFontWhiteTiny");
									quest_frame.expand.label:SetPoint("CENTER");
									quest_frame.expand.label:SetText(title);
									--quest_frame.expand.label:SetTextColor(color.r, color.g, color.b);
									
									quest_frame.quest_type = CreateFrame("Button", quest_frame:GetName() .. "_QuestType", quest_frame.expand);
									quest_frame.quest_type:SetPoint("TOPRIGHT", quest_frame.expand.label, "TOPLEFT", -5, 0);
									quest_frame.quest_type:SetSize(10, 10);
									
									quest_frame.quest_type.icon = quest_frame.quest_type:CreateTexture("ARTWORK");
									quest_frame.quest_type.icon:SetAllPoints();
									if (qb.modules.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PVP) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-pvp-ffa", true);
									elseif (qb.modules.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PET_BATTLE) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-petbattle", true);
									elseif (qb.modules.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskill_line_id]) then
										quest_frame.quest_type.icon:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskill_line_id], true);
									elseif (qb.modules.world_quests.quest_data[quest_id]["type"] == LE_QUEST_TAG_TYPE_DUNGEON) then
										quest_frame.quest_type.icon:SetAtlas("worldquest-icon-dungeon", true);
									else
										quest_frame.quest_type.icon:SetAtlas("worldquest-questmarker-questbang");
									end
									
									if (TomTom ~= nil and TomTom.AddMFWaypoint ~= nil) then
										quest_frame.tomtom = CreateFrame("Button", quest_frame:GetName() .. "_TomTom", quest_frame.expand);
										quest_frame.tomtom:SetPoint("TOPRIGHT", quest_frame.expand, "TOPLEFT", 0, 0);
										quest_frame.tomtom:SetSize(16, 16);
										quest_frame.tomtom:SetScript("OnEnter", function(self)
											tooltip:SetOwner(self, "ANCHOR_CURSOR");
											tooltip:SetText(QBL["WORLD_QUEST_TOMTOM"] .. title .. "\n" .. qb.modules.world_quests.quest_data[quest_id]["location"]["zone"]);
											tooltip:Show();
										end);
										quest_frame.tomtom:SetScript("OnLeave", function(self)
											tooltip:Hide();
										end);
										quest_frame.tomtom:SetScript("OnClick", function(self)
											local location_data = qb.modules.world_quests.quest_data[quest_id]["location"];
											TomTom:AddMFWaypoint(location_data["map_id"], location_data["floor"], location_data["x"], location_data["y"], {
												title = title,
												persistent = nil,
												minimap = true,
												world = true,
											});
											TomTom:SetClosestWaypoint();
										end);
										
										quest_frame.tomtom.icon = quest_frame.tomtom:CreateTexture("ARTWORK");
										quest_frame.tomtom.icon:SetAllPoints();
										quest_frame.tomtom.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_TomTom");
									end

									if (qb.modules.world_quests.quest_data[quest_id]["find_group"]) then
										quest_frame.find_group = CreateFrame("Button", quest_frame:GetName() .. "_FindGroup", quest_frame.expand);
										quest_frame.find_group:SetPoint("TOPLEFT", quest_frame.expand, "TOPRIGHT", 0, 0);
										quest_frame.find_group:SetSize(16, 16);
										quest_frame.find_group:SetScript("OnEnter", function(self)
											tooltip:SetOwner(self, "ANCHOR_CURSOR");
											tooltip:SetText(QBL["WORLD_QUEST_FIND_GROUP"] .. title);
											tooltip:Show();
										end);
										quest_frame.find_group:SetScript("OnLeave", function(self)
											tooltip:Hide();
										end);
										quest_frame.find_group:SetScript("OnClick", function(self)
											LFGListUtil_FindQuestGroup(quest_id);
										end);
									
										quest_frame.find_group.icon = quest_frame.find_group:CreateTexture("ARTWORK");
										quest_frame.find_group.icon:SetAllPoints();
										quest_frame.find_group.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_QuestList_FindGroup");
									end
									
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = {
										["quest_id"] = quest_id,
										["quest_name"] = title,
										["frame"] = quest_frame,
									};
								end
								
								local filter_quest_frame = frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"];
								filter_quest_frame:SetPoint("TOPLEFT", frame.type_frames[quest_type]["filters"][filter_name]["frame"], "TOPLEFT", 20, (quests_displayed * -15) - height_padding - 15);
								
								local minutes_left = C_TaskQuest.GetQuestTimeLeftMinutes(quest_id);
								if (minutes_left and minutes_left > 0 and minutes_left <= WORLD_QUESTS_TIME_CRITICAL_MINUTES) then
									color = RED_FONT_COLOR;
									filter_quest_frame.expand.label:SetTextColor(color.r, color.g, color.b, color.a);
								end
								
								if (qb.modules.quest_lists.filter_expanded == filter_name) then
									filter_quest_frame:Show();
									filter_quest_frame.expand:Show();
									filter_quest_frame.quest_type:Show();
									if (filter_quest_frame.find_group ~= nil) then
										if (config.show_find_group) then
											filter_quest_frame:SetWidth(268);
											filter_quest_frame.expand:SetWidth(268);
											filter_quest_frame.find_group:Show();
										else
											filter_quest_frame:SetWidth(284);
											filter_quest_frame.expand:SetWidth(284);
											filter_quest_frame.find_group:Hide();
										end
									else
										filter_quest_frame:SetWidth(284);
										filter_quest_frame.expand:SetWidth(284);
									end
									quests_displayed = quests_displayed + 1;
								else
									filter_quest_frame:Hide();
									filter_quest_frame.expand:Hide();
									filter_quest_frame.quest_type:Hide();
								end
								
								total_quests = total_quests + 1;
								total_filter_quests = total_filter_quests + 1;
								quest_count = quest_count + 1;
							end
						end
						
						if (total_filter_quests > 0 and qb.modules.quest_lists.type_expanded == quest_type) then
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:SetHeight(10 + (quests_displayed * 15));
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:Show();
							if (qb.modules.quest_lists.filter_expanded == filter_name) then
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetVertexColor(FILTER_EXPANDED_COLOR.r, FILTER_EXPANDED_COLOR.g, FILTER_EXPANDED_COLOR.b);
							else
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetVertexColor(FILTER_COLOR.r, FILTER_COLOR.g, FILTER_COLOR.b);
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
						if (qb.modules.quest_lists.type_expanded == quest_type) then
							frame.type_frames[quest_type]["frame"].expand.icon:SetVertexColor(QUEST_TYPE_EXPANDED_COLOR.r, QUEST_TYPE_EXPANDED_COLOR.g, QUEST_TYPE_EXPANDED_COLOR.b);
						else
							frame.type_frames[quest_type]["frame"].expand.icon:SetVertexColor(QUEST_TYPE_COLOR.r, QUEST_TYPE_COLOR.g, QUEST_TYPE_COLOR.b);
						end
						frame.type_frames[quest_type]["frame"].expand:Show();
					else
						frame.type_frames[quest_type]["frame"]:Hide();
						frame.type_frames[quest_type]["frame"].expand:Hide();
					end
					
					type_count = type_count + 1;
				end

				for i=1, MAX_EMISSARY_QUESTS do
					local emissary_frame = frame.emissary_frames[i];
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

function qb.modules.quest_lists:setEmissaryTooltip(tooltip, emissary_data)
	local faction_name, _, faction_standing = GetFactionInfoByID(emissary_data["faction_id"]);
	if (emissary_data["pending"] ~= nil) then
		tooltip:SetText(faction_name .. " - " .. QBL["EMISSARY_PENDING"]);
		tooltip:AddLine(emissary_data["pending"]);
	else
		tooltip:SetText(faction_name .. " - " .. getglobal("FACTION_STANDING_LABEL" .. faction_standing));
		tooltip:AddLine("Completed: " .. emissary_data["completed"] .. "/" .. emissary_data["total"]);
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
		tooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(time_str), color:GetRGB());
	end
end

function qb.modules.quest_lists:setQuestTooltip(tooltip, quest_id)
	local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
	local _, _, _, rarity = GetQuestTagInfo(quest_id);
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
	
	if (GetQuestLogRewardXP(quest_id) > 0 or GetNumQuestLogRewardCurrencies(quest_id) > 0 or GetNumQuestLogRewards(quest_id) > 0 or GetQuestLogRewardMoney(quest_id) > 0 or GetQuestLogRewardArtifactXP(quest_id) > 0) then
		tooltip:AddLine(" ");
		tooltip:AddLine(QUEST_REWARDS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		local found = false;

		-- experience
		local experience = GetQuestLogRewardXP(quest_id);
		if (experience > 0) then
			tooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(experience), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			found = true;
		end

		-- money
		local money = GetQuestLogRewardMoney(quest_id);
		if (money > 0) then
			SetTooltipMoney(tooltip, money, nil);
			found = true;
		end	
		local artifact_experience = GetQuestLogRewardArtifactXP(quest_id);
		if (artifact_experience > 0) then
			tooltip:AddLine(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifact_experience), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			found = true;
		end

		-- currency		
		local currencies = GetNumQuestLogRewardCurrencies(quest_id);
		for i=1, currencies do
			local name, texture, num_items = GetQuestLogRewardCurrencyInfo(i, quest_id);
			local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(texture, num_items, name);
			tooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			found = true;
		end
		
		-- items
		local rewards = GetNumQuestLogRewards(quest_id);
		if (rewards > 0) then
			if (found) then
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
			if (not EmbeddedItemTooltip_SetItemByQuestReward(item_frame, 1, quest_id)) then
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

function qb.modules.quest_lists:lockFrame(frame_name)
	if (not qb.settings:get().quest_list_frames[frame_name].locked) then
		qb.settings:get().quest_list_frames[frame_name].locked = true;
	else
		qb.settings:get().quest_list_frames[frame_name].locked = false;
	end
	qb.modules.quest_lists:update();
end

function qb.modules.quest_lists:collapseFrame(frame_name)
	if (_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:IsShown()) then
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
		qb.settings:get().quest_list_frames[frame_name].state = "collapsed";
	else
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Show();
		qb.settings:get().quest_list_frames[frame_name].state = "expanded";
	end
	qb.modules.quest_lists:update();
end

function qb.modules.quest_lists:closeFrame(frame_name)
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:Hide();
	_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
	if (not _G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:IsShown()) then
		qb.settings:get().quest_list_frames[frame_name].show = false;
	end
end

function qb.modules.quest_lists:dragFrame(frame_name)
	local point, _, relative_point, x, y = _G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:GetPoint();
	qb.settings:get().quest_list_frames[frame_name].position.point = point;
	qb.settings:get().quest_list_frames[frame_name].position.relative_point = relative_point;
	qb.settings:get().quest_list_frames[frame_name].position.x = x;
	qb.settings:get().quest_list_frames[frame_name].position.y = y;
	qb.modules.quest_lists:updatePosition(frame_name);
end

function qb.modules.quest_lists:updatePosition(frame_name)
	local position = qb.settings:get().quest_list_frames[frame_name].position;
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:ClearAllPoints();
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:SetPoint(position.point, nil, position.relative_point, position.x, position.y);
end

function qb.modules.quest_lists:resetPosition(frame_name)
	qb.settings:get().quest_list_frames[frame_name].position = {
		point = "TOPLEFT",
		relative_point = "TOPLEFT",
		x = 490,
		y = -330,
	};
	qb.modules.quest_lists:updatePosition(frame_name);
end

function QuestBuster_QuestListFrames_Toggle()
	qb.modules.quest_lists:collapseFrame("Default");
end

function QuestBuster_QuestListFrames_ToggleSize()
	for frame_id, frame_data in pairs(qb.modules.quest_lists.frames) do
		local config = qb.settings:get().quest_list_frames[frame_data["name"]];
		local frame = frame_data["frame"];
		local mover_frame = frame_data["mover_frame"];
		
		if (config.show and qb.modules.world_quests.quests.count > 0) then
			mover_frame:SetParent(QBG_QUEST_LIST_FRAMES[frame_id]["parent"]);
			mover_frame:SetFrameStrata(QBG_QUEST_LIST_FRAMES[frame_id]["strata"]);

			frame:SetParent(QBG_QUEST_LIST_FRAMES[frame_id]["parent"]);
			frame:SetFrameStrata(QBG_QUEST_LIST_FRAMES[frame_id]["strata"]);
		end
	end
end

hooksecurefunc("WorldMap_ToggleSizeUp", QuestBuster_QuestListFrames_ToggleSize);
hooksecurefunc("WorldMap_ToggleSizeDown", QuestBuster_QuestListFrames_ToggleSize);