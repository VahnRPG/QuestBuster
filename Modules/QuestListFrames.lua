local _, qb = ...;

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

local quest_list_frames = {
	[1] = {
		["name"] = "Default",
		["parent"] = UIParent,
		["strata"] = "LOW",
	},
	[2] = {
		["name"] = "WorldMap",
		["parent"] = WorldMapFrame,
		["strata"] = "FULLSCREEN_DIALOG",
	},
};

function qb.quest_lists:ADDON_LOADED(self, ...)
	local frame_backdrop = {
		bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	};

	for _, frame_data in pairs(quest_list_frames) do
		if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]]) then
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]] = {};
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].show = true;
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].position = {
				point = "TOPLEFT",
				relative_point = "TOPLEFT",
				x = 490,
				y = -330,
			};
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].locked = false;
			QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_data["name"]].state = "expanded";
		end

		--build mover frame
		local mover_frame = CreateFrame("Frame", "QuestBuster_QuestList" .. frame_data["name"] .. "MoverFrame", frame_data["parent"]);
		mover_frame:SetFrameStrata(frame_data["strata"]);
		mover_frame:SetPoint("CENTER", frame_data["parent"]);
		mover_frame:SetSize(320, 10);
		mover_frame:EnableMouse(true);
		mover_frame:SetMovable(true);
		mover_frame:RegisterForDrag("LeftButton");
		mover_frame.frame_name = frame_data["name"];
		mover_frame:SetScript("OnDragStart", function(self)
			if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[self.frame_name].locked) then
				self.dragging = true;
				self:StartMoving();
			end
		end);
		mover_frame:SetScript("OnDragStop", function(self)
			if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[self.frame_name].locked) then
				self.dragging = false;
				self:StopMovingOrSizing();
			end
		end);
		mover_frame:SetScript("OnUpdate", function(self)
			if (self.dragging) then
				qb.quest_lists:drag(self.frame_name);
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
		mover_frame.config.frame_name = frame_data["name"];
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
		mover_frame.lock.frame_name = frame_data["name"];
		mover_frame.lock:SetScript("OnClick", function(self)
			qb.quest_lists:lock(self.frame_name);
		end);
		
		mover_frame.lock.icon = mover_frame.lock:CreateTexture("ARTWORK");
		mover_frame.lock.icon:SetAllPoints();
		mover_frame.lock.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Unlocked");
		
		--build mover frame - collapse button
		mover_frame.collapse = CreateFrame("Button", mover_frame_name .. "_CollapseFrame", mover_frame);
		mover_frame.collapse:SetPoint("TOPLEFT", mover_frame_name .. "_LockFrame", "TOPRIGHT", -2, 0);
		mover_frame.collapse:SetSize(16, 16);
		mover_frame.collapse.frame_name = frame_data["name"];
		mover_frame.collapse:SetScript("OnClick", function(self)
			qb.quest_lists:collapse(self.frame_name);
		end);
		
		mover_frame.collapse.icon = mover_frame.collapse:CreateTexture("ARTWORK");
		mover_frame.collapse.icon:SetAllPoints();
		mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
		
		--build mover frame - close button
		mover_frame.close = CreateFrame("Button", mover_frame_name .. "_CloseFrame", mover_frame);
		mover_frame.close:SetPoint("TOPLEFT", mover_frame_name .. "_CollapseFrame", "TOPRIGHT", -2, 0);
		mover_frame.close:SetSize(16, 16);
		mover_frame.close.frame_name = frame_data["name"];
		mover_frame.close:SetScript("OnClick", function(self)
			qb.quest_lists:close(self.frame_name);
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
		frame.frame_name = frame_data["name"];
		frame.type_frames = {};
		local frame_name = frame:GetName();
		
		--[[
		frame.label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		frame.label:SetPoint("CENTER");
		frame.label:SetText("No World Quests!");
		]]--

		--save frame
		qb.quest_lists.frames[frame_data["name"]] = {
			["name"] = frame_data["name"],
			["frame"] = frame,
			["mover_frame"] = mover_frame,
		};
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
				for quest_type, quest_data in sortedpairs(qb.world_quests.quests.quests) do
					if (not frame.type_frames[quest_type]) then
						local type_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", frame, SecureFrameTemplate);
						if (type_count == 0) then
							type_frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -10);
						else
							type_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. (type_count - 1) .."Frame", "BOTTOMLEFT", 0, -5);
						end
						type_frame:SetSize(320, 10);
						type_frame.frame_name = type_count;
						
						type_frame.label = type_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
						type_frame.label:SetPoint("TOP");
						type_frame.label:SetText(QBL["WORLD_QUEST_" .. string.upper(quest_type)]);
						
						type_frame.expand = CreateFrame("Button", type_frame:GetName() .. "_ExpandFrame", type_frame);
						type_frame.expand:SetPoint("TOPLEFT",  type_frame, "TOPRIGHT", -2, 0);
						type_frame.expand:SetSize(16, 16);
						type_frame.expand.frame_type = quest_type;
						type_frame.expand:SetScript("OnClick", function(self)
							if (qb.quest_lists.type_expanded == self.frame_type) then
								qb.quest_lists.type_expanded = "";
								qb.quest_lists.filter_expanded = "";
							else
								qb.quest_lists.type_expanded = self.frame_type;
							end
							qb.quest_lists:update();
						end);
						
						type_frame.expand.icon = type_frame.expand:CreateTexture("ARTWORK");
						type_frame.expand.icon:SetAllPoints();
						type_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");

						frame.type_frames[quest_type] = {
							["name"] = quest_type,
							["frame"] = type_frame,
							["filters"] = {},
						};
					end

					local type_frame = _G["QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame"];
					if (type_count == 0) then
						type_frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -10);
					else
						type_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. (type_count - 1) .."Frame", "BOTTOMLEFT", 0, -5);
					end
					
					for _, child_frame in pairs(frame.type_frames[quest_type]["filters"]) do
						child_frame["frame"]:Hide();
					end
					
					local total_quests = 0;
					local filter_count = 0;
					local filters_displayed = 0;
					local height_padding = 0;
					for filter_name, quest_ids in sortedpairs(quest_data) do
						if (not frame.type_frames[quest_type]["filters"][filter_name]) then
							local filter_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .."Frame", frame, SecureFrameTemplate);
							filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, 0);
							filter_frame:SetSize(300, 10);
							filter_frame.frame_name = type_count .. "_" .. filter_count;
							
							filter_frame.label = filter_frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall");
							filter_frame.label:SetPoint("TOP");
							filter_frame.label:SetText(string.upper(filter_name));
						
							filter_frame.expand = CreateFrame("Button", filter_frame:GetName() .. "_ExpandFrame", type_frame);
							filter_frame.expand:SetPoint("TOPLEFT",  filter_frame, "TOPRIGHT", -2, 0);
							filter_frame.expand:SetSize(16, 16);
							filter_frame.expand.frame_type = filter_name;
							filter_frame.expand:SetScript("OnClick", function(self)
								if (qb.quest_lists.filter_expanded == self.frame_type) then
									qb.quest_lists.filter_expanded = "";
								else
									qb.quest_lists.filter_expanded = self.frame_type;
								end
								qb.quest_lists:update();
							end);
							
							filter_frame.expand.icon = filter_frame.expand:CreateTexture("ARTWORK");
							filter_frame.expand.icon:SetAllPoints();
							filter_frame.expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");

							frame.type_frames[quest_type]["filters"][filter_name] = {
								["name"] = filter_name,
								["frame"] = filter_frame,
								["quests"] = {},
							};
						end
						
						local filter_frame = _G["QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .."Frame"];
						filter_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "Frame", "TOPLEFT", 20, (filters_displayed * -15) - height_padding - 15);
						
						local total_filter_quests = 0;
						local quest_count = 0;
						local quests_displayed = 0;
						if (quest_ids and next(quest_ids)) then
							for _, quest_id in pairs(quest_ids) do
								local tag_id, tag_name, world_quest_type, rarity, elite, tradeskill_line = GetQuestTagInfo(quest_id);
								local title, faction_id, capped = C_TaskQuest.GetQuestInfoByQuestID(quest_id);
								
								if (not frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]) then
									local quest_frame = CreateFrame("Frame", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .. "_" .. quest_count .."Frame", frame, SecureFrameTemplate);
									quest_frame:SetPoint("TOPLEFT", "QuestBuster_QuestList_" .. frame_data["name"] .. "Type" .. type_count .. "_" .. filter_count .."Frame", "TOPLEFT", 20, (quest_count * -15) - 15);
									quest_frame:SetSize(280, 10);
									quest_frame.frame_name = type_count .. "_" .. filter_count .. "_" .. quest_count;
									
									quest_frame.label = quest_frame:CreateFontString(nil, "ARTWORK", "GameFontWhiteTiny");
									quest_frame.label:SetPoint("TOP");
									quest_frame.label:SetText(title);

									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id] = {
										["name"] = quest_id,
										["frame"] = quest_frame,
									};
								end

								if (qb.quest_lists.filter_expanded == filter_name) then
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"]:Show();
									quests_displayed = quests_displayed + 1;
								else
									frame.type_frames[quest_type]["filters"][filter_name]["quests"][quest_id]["frame"]:Hide();
								end

								--tooltip:AddLine("    - " .. title);
								total_quests = total_quests + 1;
								total_filter_quests = total_filter_quests + 1;
								quest_count = quest_count + 1;
							end
						end
						
						filter_count = filter_count + 1;
						
						--echo("  Here: " .. filter_name .. " - " .. total_filter_quests .. " : " .. frame.type_frames[quest_type]["filters"][filter_name]["frame"]:GetName());
						if (total_filter_quests > 0 and qb.quest_lists.type_expanded == quest_type) then
							if (qb.quest_lists.filter_expanded == filter_name) then
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Expand");
							else
								frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
							end
							frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand:Show();
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:SetHeight(10 + (quests_displayed * 15));
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:Show();
							filters_displayed = filters_displayed + 1;
							height_padding = height_padding + (quests_displayed * 15);
						else
							frame.type_frames[quest_type]["filters"][filter_name]["frame"].expand:Hide();
							frame.type_frames[quest_type]["filters"][filter_name]["frame"]:Hide();
						end
					end
					
					--echo("Here: " .. quest_type .. " - " .. filters_displayed);
					if (total_quests > 0) then
						if (qb.quest_lists.type_expanded == quest_type) then
							frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Expand");
						else
							frame.type_frames[quest_type]["frame"].expand.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
						end
						frame.type_frames[quest_type]["frame"].expand:Show();
						frame.type_frames[quest_type]["frame"]:SetHeight(10 + (filters_displayed * 15) + height_padding);
						frame.type_frames[quest_type]["frame"]:Show();
					else
						frame.type_frames[quest_type]["frame"].expand:Hide();
						frame.type_frames[quest_type]["frame"]:Hide();
					end
					
					type_count = type_count + 1;
				end
				
				mover_frame:Show();
				mover_frame.collapse.icon:SetTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Mover_Collapse");
				if (type_count > 0) then
					frame:SetHeight(15 + (type_count * 15));
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

function qb.quest_lists:lock(frame_name)
	if (not QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked) then
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked = true;
	else
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].locked = false;
	end
	qb.quest_lists:update();
end

function qb.quest_lists:collapse(frame_name)
	if (_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:IsShown()) then
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].state = "collapsed";
	else
		_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Show();
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].state = "expanded";
	end
	qb.quest_lists:update();
end

function qb.quest_lists:close(frame_name)
	_G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:Hide();
	_G["QuestBuster_QuestList" .. frame_name .. "Frame"]:Hide();
	if (not _G["QuestBuster_QuestList" .. frame_name .. "MoverFrame"]:IsShown()) then
		QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].show = false;
	end
end

function qb.quest_lists:drag(frame_name)
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

function qb.quest_lists:resetPosition(frame_name) QuestBuster_WorldQuestsFrame_ResetPosition()
	QuestBusterOptions[QuestBusterEntry].quest_list_frames[frame_name].position = {
		point = "TOPLEFT",
		relative_point = "TOPLEFT",
		x = 490,
		y = -330,
	};
	qb.quest_lists:updatePosition(frame_name);
end

function QuestBuster_QuestListFrames_Toggle()
	qb.quest_lists:collapse("Default");
end