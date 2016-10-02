function QuestBuster_Minimap_Update()
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_OnClick(self, button, down)
	if (button == "LeftButton") then
		--ToggleDropDownMenu(1, nil, QuestBuster_MinimapButtonDropDown, "QuestBuster_MinimapButton", 0, -5);
		--PlaySound("igMainMenuOptionCheckBoxOn");
	elseif (button == "RightButton") then
		QuestBuster_Config_Show();
	end
end

function QuestBuster_MinimapDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, QuestBuster_MinimapDropDown_Initialize, "MENU");
	self.noResize = true;
end

function QuestBuster_MinimapDropDownButton_ShowTracking()
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].skills_frame.show) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_ShowWorldMap()
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].worldmap_frame.show) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_ShowGatherer()
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].gather_frame.show) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_ShowZoneNodes()
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].gather_frame.show_zone_nodes) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_ShowSkillUpNodes()
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].gather_frame.show_skill_nodes) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_TrackingIsActive(button)
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].skills_frame.bars[button.arg1]) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_TooltipIsActive(button)
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].modules[button.arg1].show_tooltips) then
		return true;
	end
	return false;
end

function QuestBuster_MinimapDropDownButton_BusterIsActive(button)
	if (QuestBusterEntry ~= nil and QuestBusterOptions[QuestBusterEntry].modules[button.arg1].show_buster) then
		return true;
	end
	return false;
end

function QuestBuster_Minimap_SetShowWorldMapIcons(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].map_icons.show_world_map = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetShowMinimapIcons(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].map_icons.show_mini_map = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetShowTracking(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].skills_frame.show = checked;
	QuestBuster_SkillFrame_Update();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetShowWorldMap(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].worldmap_frame.show = checked;
	QuestBuster_WorldMap_Update();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetShowGatherer(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].gather_frame.show = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetAutoHideGatherer(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].gather_frame.auto_hide = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetShowZoneNodes(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].gather_frame.show_zone_nodes = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetSkillUpNodes(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].gather_frame.show_skill_nodes = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetTracking(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].skills_frame.bars[id] = checked;
	QuestBuster_SkillFrame_Update();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetTooltip(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_tooltips = checked;
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetTrainerMapIcons(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_trainer_map_icons = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetStationMapIcons(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_station_map_icons = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetBuster(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_buster = checked;
	QuestBuster_SkillFrame_Update();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetProfessionWorldMap(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_worldmap_icons = checked;
	QuestBuster_WorldMap_Update();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_Minimap_SetProfessionGather(self, id, unused, checked)
	QuestBusterOptions[QuestBusterEntry].modules[id].show_gather = checked;
	QuestBuster_UpdateZone();
	UIDropDownMenu_Refresh(QuestBuster_MinimapButtonDropDown);
end

function QuestBuster_MinimapDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = QBL["CONFIG_TITLE_TRACK_PROFESSION"];
	info.isTitle = true;
	info.notCheckable = true;
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info);
end

function QuestBuster_Minimap_Init()
	if (QuestBusterOptions[QuestBusterEntry].minimap.show) then
		QuestBuster_MinimapFrame:Show();
	else
		QuestBuster_MinimapFrame:Hide();
	end
	QuestBuster_Minimap_UpdatePosition();
end

function QuestBuster_Minimap_OnEnter()
	GameTooltip:SetOwner(QuestBuster_MinimapFrame, "ANCHOR_LEFT");
	GameTooltip:AddLine(QBG_MOD_COLOR .. QBG_MOD_NAME);
	GameTooltip:AddLine(QBL["MINIMAP_HOVER_LINE1"]);
	--GameTooltip:AddLine(QBL["MINIMAP_HOVER_LINE2"]);
	GameTooltip:AddLine(QBL["MINIMAP_HOVER_LINE3"]);
	GameTooltip:Show();
end

function QuestBuster_Minimap_OnDrag()
	local xpos, ypos = GetCursorPosition();
	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = (xmin - xpos) / UIParent:GetScale() + 80;
	ypos = (ypos / UIParent:GetScale()) - ymin - 80;

	local angle = math.deg(math.atan2(ypos, xpos));
	if (angle < 0) then
		angle = angle + 360;
	end;

	QuestBusterOptions[QuestBusterEntry].minimap.position = angle;
	QuestBuster_Minimap_UpdatePosition();
end

function QuestBuster_Minimap_UpdatePosition()
	local radius = 80;
	local angle = QuestBusterOptions[QuestBusterEntry].minimap.position;

	QuestBuster_MinimapFrame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", (52 - (radius * cos(angle))), ((radius * sin(angle)) - 52));
end

function QuestBuster_Minimap_Toggle()
	if (QuestBuster_MinimapFrame:IsVisible()) then
		QuestBuster_MinimapFrame:Hide();
		QuestBusterOptions[QuestBusterEntry].minimap.show = false;
	else
		QuestBuster_MinimapFrame:Show()
		QuestBusterOptions[QuestBusterEntry].minimap.show = true;
	end
end