local _, qb = ...;

qb.minimap = {};
qb.minimap.frame = CreateFrame("Frame", "QuestBuster_MinimapFrame", Minimap);
qb.minimap.frame:SetFrameStrata("LOW");
qb.minimap.frame:SetPoint("TOPLEFT", Minimap, "RIGHT");
qb.minimap.frame:SetSize(32, 32);
qb.minimap.frame:EnableMouse(true);
qb.minimap.frame:RegisterEvent("ADDON_LOADED");
qb.minimap.frame:SetScript("OnEvent", function(self, event, ...)
	if (qb.settings.init) then
		return qb.minimap[event] and qb.minimap[event](cb, ...)
	end
end);

--<Frame name="QuestBuster_MinimapFrame" parent="Minimap" enableMouse="true" hidden="false" frameStrata="LOW">
qb.minimap.frame.button = CreateFrame("Button", qb.minimap.frame:GetName() .. "_Button", qb.minimap.frame);
qb.minimap.frame.button:SetPoint("TOPLEFT", qb.minimap.frame, "TOPLEFT");
qb.minimap.frame.button:SetSize(32, 32);
qb.minimap.frame.button:SetNormalTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Minimap_ButtonUp");
qb.minimap.frame.button:SetPushedTexture("Interface\\AddOns\\QuestBuster\\Images\\QuestBuster_Minimap_ButtonDown");
qb.minimap.frame.button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD");
qb.minimap.frame.button:RegisterForDrag("LeftButton");
qb.minimap.frame.button:RegisterForClicks("RightButtonDown");
qb.minimap.frame.button:SetScript("OnDragStart", function(self)
	self.dragging = true;
	self:StartMoving();
end);
qb.minimap.frame.button:SetScript("OnDragStop", function(self)
	self.dragging = false;
	self:StopMovingOrSizing();
end);
qb.minimap.frame.button:SetScript("OnUpdate", function(self)
	if (self.dragging) then
		qb.minimap:dragFrame();
	end
end);
qb.minimap.frame.button:SetScript("OnEnter", function(self, button, down)
	GameTooltip:SetOwner(qb.minimap.frame, "ANCHOR_LEFT");
	GameTooltip:AddLine(QBG_MOD_COLOR .. QBG_MOD_NAME);
	GameTooltip:AddLine(QBL["MINIMAP_HOVER_LINE1"]);
	GameTooltip:AddLine(QBL["MINIMAP_HOVER_LINE2"]);
	GameTooltip:Show();
end);
qb.minimap.frame.button:SetScript("OnLeave", function(self, button, down)
	GameTooltip:Hide();
end);
qb.minimap.frame.button:SetScript("OnClick", function(self, button, down)
	if (button == "RightButton") then
		QuestBuster_Config_Show();
	end
end);

function qb.minimap:ADDON_LOADED()
	qb.minimap:update();

	qb.minimap.frame:UnregisterEvent("ADDON_LOADED");
end

function qb.minimap:update()
	if (qb.settings:get().minimap.show) then
		qb.minimap.frame:Show();
	else
		qb.minimap.frame:Hide();
	end
	qb.minimap:updatePosition();
end

function qb.minimap:dragFrame()
	local xpos, ypos = GetCursorPosition();
	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = (xmin - xpos) / UIParent:GetScale() + 80;
	ypos = (ypos / UIParent:GetScale()) - ymin - 80;

	local angle = math.deg(math.atan2(ypos, xpos));
	if (angle < 0) then
		angle = angle + 360;
	end;

	qb.settings:get().minimap.position = angle;
	qb.minimap:updatePosition();
end

function qb.minimap:updatePosition()
	local radius = 80;
	local angle = qb.settings:get().minimap.position;
	
	qb.minimap.frame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", (52 - (radius * cos(angle))), ((radius * sin(angle)) - 52));
end