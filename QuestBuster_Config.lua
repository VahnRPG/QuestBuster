local config_frame_name = "QuestBuster_ConfigFrame";

local SCROLL_FRAME_HEIGHT = 19;
local SCROLL_FRAME_COUNT = 13;

local reward_highlights = {};
local settings_menu, show_minimap_button;
local auto_quest_enabled, auto_quest_details_frame, auto_quest_only_dailies, auto_quest_low_level, auto_quest_repeatable, auto_quest_reward_menu, auto_quest_modifier_menu;
local daily_quest_rewards_frame, daily_quest_rewards_scrollframe, daily_quest_rewards_none_label;
local daily_quest_rewards_scrollframe_buttons = {};
local show_level, show_abandon;

local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
};

local function QuestBuster_Config_DailyQuestRewards_ScrollFrame_Init(self)
	for i=1, SCROLL_FRAME_COUNT do
		local button_frame = CreateFrame("Button", self:GetParent():GetName() .. "Item" .. i, self:GetParent());
		button_frame:SetNormalFontObject("GameFontNormalLeft");
		button_frame:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -SCROLL_FRAME_HEIGHT * (i-1));
		button_frame:SetSize(530, SCROLL_FRAME_HEIGHT);
		daily_quest_rewards_scrollframe_buttons[i] = button_frame;
	end
end

local function QuestBuster_Config_DailyQuestRewards_ScrollFrame_Update(self)
	local offset = FauxScrollFrame_GetOffset(self);
	local rewards = {};
	local count = 0;
	if (QuestBusterOptions[QuestBusterEntry].daily_quest_rewards and next(QuestBusterOptions[QuestBusterEntry].daily_quest_rewards)) then
		for quest_id, reward_data in sortedpairs(QuestBusterOptions[QuestBusterEntry].daily_quest_rewards) do
			count = count + 1;
			table.insert(rewards, reward_data);
		end
	end
	
	if (count > 0) then
		for i=1, SCROLL_FRAME_COUNT do
			local button_frame = daily_quest_rewards_scrollframe_buttons[i];
			local index = offset + i;
			if (rewards[index] and next(rewards[index])) then
				local reward_data = rewards[index];
				
				local quest_text = QBL["CONFIG_TITLE_DAILY_QUEST_ITEM_ERROR"] .. reward_data.quest_id;
				if (reward_data.quest_title ~= nil) then
					quest_text = QBG_CLR_OFFBLUE .. reward_data.quest_title;
				end
				button_frame:SetText(quest_text .. " - " .. reward_data.item_link);

				--[[
				local spell_name = GetSpellInfo(saved_spell_id);
				local item_name,item_link,_,_,_,_,_,_,_,item_texture = GetItemInfo(item_data.item_id);
				SetItemButtonTexture(button_frame, item_texture);
				SetItemButtonCount(button_frame, item_data.total);
				button_frame.spell_id = saved_spell_id;
				button_frame.item_id = item_data.item_id;
				button_frame.item_link = item_link;
				button_frame:SetAttribute("type1", "spell");
				button_frame:SetAttribute("spell1", spell_name);
				button_frame:SetAttribute("item*", ATTRIBUTE_NOOP);
				if (item_data.bag ~= nil and item_data.slot ~= nil) then
					button_frame:SetAttribute("target-bag", item_data.bag);
					button_frame:SetAttribute("target-slot", item_data.slot);
				else
					button_frame:SetAttribute("target-item", item_name);
				end
				button_frame:SetAttribute("ctrl-type2", "function");
				button_frame:SetAttribute("_function", CraftBuster_Buster_Button_Ignore_Item);
				]]--
				button_frame:Show();
			else
				button_frame:Hide();
			end
		end

		FauxScrollFrame_Update(self, count, SCROLL_FRAME_COUNT, SCROLL_FRAME_HEIGHT);
		self:Show();
		daily_quest_rewards_none_label:Hide();
	else
		self:Hide();
		daily_quest_rewards_none_label:Show();
	end
end

--There's probably a better way to do this but I'm not in the mood to figure it out right now...
local function updateFields()
	show_minimap_button:SetChecked(QuestBusterOptions[QuestBusterEntry].minimap.show);
	for key, value in pairs(QBG_REWARDS) do
		if (key ~= QBT_REWARD_NONE) then
			reward_highlights[key]:SetChecked(QuestBusterOptions[QuestBusterEntry].reward_highlights[key]);
		end
	end
	auto_quest_enabled:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]);
	if (QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]) then
		auto_quest_details_frame:Show();
	else
		auto_quest_details_frame:Hide();
	end
	auto_quest_only_dailies:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["only_dailies"]);
	auto_quest_low_level:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["low_level"]);
	auto_quest_repeatable:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["repeatable"]);
	QuestBuster_Config_DailyQuestRewards_ScrollFrame_Init(daily_quest_rewards_scrollframe);
	QuestBuster_Config_DailyQuestRewards_ScrollFrame_Update(daily_quest_rewards_scrollframe);
end

local config_frame = CreateFrame("Frame", config_frame_name, InterfaceOptionsFramePanelContainer);
config_frame.name = QBG_MOD_NAME;
config_frame:SetScript("OnShow", function(config_frame)
	local count = 0;

	local title_label = config_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title_label:SetPoint("TOPLEFT", 16, -16);
	title_label:SetText(QBG_MOD_NAME .. " v" .. QBG_VERSION);

	local settings_label = config_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	settings_label:SetPoint("TOPLEFT", title_label, "BOTTOMLEFT", 0, -20);
	settings_label:SetText(QBL["CONFIG_SETTINGS_TYPE"]);

	settings_menu = CreateFrame("Frame", config_frame_name .. "SetSettings", config_frame, "UIDropDownMenuTemplate");
	settings_menu:SetPoint("TOPLEFT", settings_label, "TOPRIGHT", 0, 4);
	UIDropDownMenu_Initialize(settings_menu, function()
		local values = { "Global", "Personal" };
		for i, value in pairs(values) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = value;
			info.value = value;
			info.func = function(self)
				UIDropDownMenu_SetSelectedValue(settings_menu, self.value);
				if (self.value == "Personal") then
					QuestBusterOptions.globals[QuestBusterEntry_Personal] = QuestBusterEntry_Personal;
				else
					QuestBusterOptions.globals[QuestBusterEntry_Personal] = "global";
				end
				QuestBusterEntry = QuestBusterOptions.globals[QuestBusterEntry_Personal];
				if (not QuestBusterOptions[QuestBusterEntry]) then
					QuestBuster_InitSettings("character");
				end
				QuestBuster_TitanPanel_Update();
				updateFields();
			end
			UIDropDownMenu_AddButton(info);
		end
	end);
	UIDropDownMenu_JustifyText(settings_menu, "LEFT");
	UIDropDownMenu_SetSelectedValue(settings_menu, ((QuestBusterEntry_Personal == QuestBusterEntry) and "Personal" or "Global"));

	show_minimap_button = CreateFrame("CheckButton", config_frame_name .. "Minimap", config_frame, "InterfaceOptionsCheckButtonTemplate");
	show_minimap_button:SetPoint("TOPLEFT", settings_label, "BOTTOMLEFT", 0, -24);
	_G[show_minimap_button:GetName() .. "Text"]:SetText(QBL["CONFIG_SHOW_MINIMAP"]);
	show_minimap_button:SetChecked(QuestBusterOptions[QuestBusterEntry].minimap.show);
	show_minimap_button:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].minimap.show = self:GetChecked();
		QuestBuster_Minimap_Init();
	end);

	local reward_highlights_label = config_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	reward_highlights_label:SetPoint("TOPLEFT", show_minimap_button, "BOTTOMLEFT", 0, -24);
	reward_highlights_label:SetText(QBL["CONFIG_TITLE_HIGHLIGHT_REWARD"]);

	local count = 0;
	for key, value in sortedpairs(QBG_REWARDS) do
		if (key ~= QBT_REWARD_NONE) then
			local module_data = CraftBuster_Modules[module_id];
			reward_highlights[key] = CreateFrame("CheckButton", config_frame_name .. "HighlightRewards" .. key, config_frame, "InterfaceOptionsCheckButtonTemplate");
			reward_highlights[key]:SetPoint("TOPLEFT", reward_highlights_label, "BOTTOMLEFT", 0, -20 * count);
			_G[reward_highlights[key]:GetName() .. "Text"]:SetText(QBG_REWARDS[key].label);
			reward_highlights[key]:SetChecked(QuestBusterOptions[QuestBusterEntry].reward_highlights[key]);
			reward_highlights[key]:SetScript("OnClick", function(self, button)
				QuestBusterOptions[QuestBusterEntry].reward_highlights[key] = self:GetChecked();
			end);

			count = count + 1;
		end
	end

	config_frame:SetScript("OnShow", nil);
end);
InterfaceOptions_AddCategory(config_frame);

local child_auto_quest_frame = CreateFrame("Frame", config_frame_name .. "AutoQuest", config_frame);
child_auto_quest_frame.name = "Auto Quest";
child_auto_quest_frame.parent = config_frame.name;
child_auto_quest_frame:SetScript("OnShow", function(child_auto_quest_frame)
	local title_label = child_auto_quest_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title_label:SetPoint("TOPLEFT", 16, -16);
	title_label:SetText(QBG_MOD_NAME .. " - " .. child_auto_quest_frame.name);

	auto_quest_enabled = CreateFrame("CheckButton", config_frame_name .. "AutoQuestEnabled", child_auto_quest_frame, "InterfaceOptionsCheckButtonTemplate");
	auto_quest_enabled:SetPoint("TOPLEFT", title_label, "BOTTOMLEFT", 0, -20);
	_G[auto_quest_enabled:GetName() .. "Text"]:SetText(QBL["CONFIG_AUTO_QUEST_ENABLED"]);
	auto_quest_enabled:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]);
	auto_quest_enabled:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"] = self:GetChecked();
		if (self:GetChecked()) then
			auto_quest_details_frame:Show();
		else
			auto_quest_details_frame:Hide();
		end
		QuestBuster_TitanPanel_Update();
	end);

	auto_quest_details_frame = CreateFrame("Frame", config_frame_name .. "AutoQuestDetails", child_auto_quest_frame);
	auto_quest_details_frame:SetPoint("TOPLEFT", auto_quest_enabled, "BOTTOMLEFT", 0, 0);
	auto_quest_details_frame:SetSize(590, 470);
	auto_quest_details_frame:SetBackdrop(backdrop);
	auto_quest_details_frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5);
	auto_quest_details_frame:SetBackdropBorderColor(0.4, 0.4, 0.4);
	if (QuestBusterOptions[QuestBusterEntry].auto_quest["enabled"]) then
		auto_quest_details_frame:Show();
	else
		auto_quest_details_frame:Hide();
	end

	local auto_quest_modifier_label = auto_quest_details_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	auto_quest_modifier_label:SetPoint("TOPLEFT", auto_quest_details_frame, "TOPLEFT", 15, -20);
	auto_quest_modifier_label:SetText(QBL["CONFIG_TITLE_AUTO_QUEST_MODIFIER"]);

	auto_quest_modifier_menu = CreateFrame("Frame", config_frame_name .. "SetModifier", auto_quest_details_frame, "UIDropDownMenuTemplate");
	auto_quest_modifier_menu:SetPoint("TOPLEFT", auto_quest_modifier_label, "TOPRIGHT", 0, 4);
	UIDropDownMenu_Initialize(auto_quest_modifier_menu, function()
		local values = { NONE_KEY, ALT_KEY, CTRL_KEY, SHIFT_KEY };
		for i, value in pairs(values) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = value;
			info.value = value;
			info.func = function(self)
				UIDropDownMenu_SetSelectedValue(auto_quest_modifier_menu, self.value);
				QuestBusterOptions[QuestBusterEntry].auto_quest["modifier"] = self.value;
				QuestBuster_TitanPanel_Update();
			end
			UIDropDownMenu_AddButton(info);
		end
	end);
	UIDropDownMenu_JustifyText(auto_quest_modifier_menu, "LEFT");
	UIDropDownMenu_SetSelectedValue(auto_quest_modifier_menu, QuestBusterOptions[QuestBusterEntry].auto_quest["modifier"]);

	auto_quest_only_dailies = CreateFrame("CheckButton", config_frame_name .. "AutoQuestOnlyDailies", auto_quest_details_frame, "InterfaceOptionsCheckButtonTemplate");
	auto_quest_only_dailies:SetPoint("TOPLEFT", auto_quest_modifier_label, "BOTTOMLEFT", -5, -15);
	_G[auto_quest_only_dailies:GetName() .. "Text"]:SetText(QBL["CONFIG_AUTO_QUEST_ONLY_DAILIES"]);
	auto_quest_only_dailies:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["only_dailies"]);
	auto_quest_only_dailies:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].auto_quest["only_dailies"] = self:GetChecked();
		QuestBuster_TitanPanel_Update();
	end);

	auto_quest_low_level = CreateFrame("CheckButton", config_frame_name .. "AutoQuestLowLevel", auto_quest_details_frame, "InterfaceOptionsCheckButtonTemplate");
	auto_quest_low_level:SetPoint("TOPLEFT", auto_quest_only_dailies, "BOTTOMLEFT", 0, 0);
	_G[auto_quest_low_level:GetName() .. "Text"]:SetText(QBL["CONFIG_AUTO_QUEST_LOW_LEVEL"]);
	auto_quest_low_level:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["low_level"]);
	auto_quest_low_level:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].auto_quest["low_level"] = self:GetChecked();
		QuestBuster_TitanPanel_Update();
	end);

	auto_quest_repeatable = CreateFrame("CheckButton", config_frame_name .. "AutoQuestRepeatable", auto_quest_details_frame, "InterfaceOptionsCheckButtonTemplate");
	auto_quest_repeatable:SetPoint("TOPLEFT", auto_quest_low_level, "BOTTOMLEFT", 0, 0);
	_G[auto_quest_repeatable:GetName() .. "Text"]:SetText(QBL["CONFIG_AUTO_QUEST_REPEATABLE"]);
	auto_quest_repeatable:SetChecked(QuestBusterOptions[QuestBusterEntry].auto_quest["repeatable"]);
	auto_quest_repeatable:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].auto_quest["repeatable"] = self:GetChecked();
		QuestBuster_TitanPanel_Update();
	end);

	local auto_quest_reward_label = auto_quest_details_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	auto_quest_reward_label:SetPoint("TOPLEFT", auto_quest_repeatable, "BOTTOMLEFT", 5, -14);
	auto_quest_reward_label:SetText(QBL["CONFIG_TITLE_AUTO_QUEST_REWARD"]);

	auto_quest_reward_menu = CreateFrame("Frame", config_frame_name .. "SetReward", auto_quest_details_frame, "UIDropDownMenuTemplate");
	auto_quest_reward_menu:SetPoint("TOPLEFT", auto_quest_reward_label, "TOPRIGHT", 0, 4);
	UIDropDownMenu_Initialize(auto_quest_reward_menu, function()
		for key, value in sortedpairs(QBG_REWARDS) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = value.label;
			info.value = key;
			info.func = function(self)
				UIDropDownMenu_SetSelectedValue(auto_quest_reward_menu, self.value);
				QuestBusterOptions[QuestBusterEntry].auto_quest["reward"] = self.value;
			end
			UIDropDownMenu_AddButton(info);
		end
	end);
	UIDropDownMenu_JustifyText(auto_quest_reward_menu, "LEFT");
	UIDropDownMenu_SetSelectedValue(auto_quest_reward_menu, QuestBusterOptions[QuestBusterEntry].auto_quest["reward"]);
	
	local daily_quest_rewards_label = auto_quest_details_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	daily_quest_rewards_label:SetPoint("TOPLEFT", auto_quest_reward_label, "BOTTOMLEFT", 0, -25);
	daily_quest_rewards_label:SetText(QBL["CONFIG_TITLE_DAILY_QUEST_REWARD"]);

	daily_quest_rewards_frame = CreateFrame("Frame", config_frame_name .. "DailyQuestRewards", auto_quest_details_frame);
	daily_quest_rewards_frame:SetPoint("TOPLEFT", daily_quest_rewards_label, "BOTTOMLEFT", 0, -5);
	daily_quest_rewards_frame:SetSize(560, 265);
	daily_quest_rewards_frame:SetBackdrop(backdrop);
	daily_quest_rewards_frame:SetBackdropColor(0.05, 0.05, 0.05, 0.75);
	daily_quest_rewards_frame:SetBackdropBorderColor(0.4, 0.4, 0.4);

	daily_quest_rewards_scrollframe = CreateFrame("ScrollFrame", daily_quest_rewards_frame:GetName() .. "ScrollFrame", daily_quest_rewards_frame, "FauxScrollFrameTemplate");
	daily_quest_rewards_scrollframe:SetSize(530, SCROLL_FRAME_HEIGHT * SCROLL_FRAME_COUNT);
	daily_quest_rewards_scrollframe:SetPoint("TOPLEFT", daily_quest_rewards_frame, "TOPLEFT", 0, -10);
	daily_quest_rewards_scrollframe:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, SCROLL_FRAME_HEIGHT, QuestBuster_Config_DailyQuestRewards_ScrollFrame_Update);
	end);
	QuestBuster_Config_DailyQuestRewards_ScrollFrame_Init(daily_quest_rewards_scrollframe);

	daily_quest_rewards_none_label = daily_quest_rewards_frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	daily_quest_rewards_none_label:SetPoint("CENTER", daily_quest_rewards_frame);
	daily_quest_rewards_none_label:SetText(QBL["CONFIG_TITLE_DAILY_QUEST_NONE"]);

	child_auto_quest_frame:SetScript("OnShow", nil);
end);
InterfaceOptions_AddCategory(child_auto_quest_frame);

local child_watch_frame_frame = CreateFrame("Frame", config_frame_name .. "WatchFrame", config_frame);
child_watch_frame_frame.name = "Watch Frame";
child_watch_frame_frame.parent = config_frame.name;
child_watch_frame_frame:SetScript("OnShow", function(child_watch_frame_frame)
	local title_label = child_watch_frame_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title_label:SetPoint("TOPLEFT", 16, -16);
	title_label:SetText(QBG_MOD_NAME .. " - " .. child_watch_frame_frame.name);

	show_level = CreateFrame("CheckButton", config_frame_name .. "ShowLevel", child_watch_frame_frame, "InterfaceOptionsCheckButtonTemplate");
	show_level:SetPoint("TOPLEFT", title_label, "BOTTOMLEFT", 0, -20);
	_G[show_level:GetName() .. "Text"]:SetText(QBL["CONFIG_SHOW_LEVEL"]);
	show_level:SetChecked(QuestBusterOptions[QuestBusterEntry].watch_frame["show_level"]);
	show_level:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].watch_frame["show_level"] = self:GetChecked();
		QuestBuster_WatchFrame_ShowQuestLevel();
	end);

	show_abandon = CreateFrame("CheckButton", config_frame_name .. "ShowAbandon", child_watch_frame_frame, "InterfaceOptionsCheckButtonTemplate");
	show_abandon:SetPoint("TOPLEFT", show_level, "BOTTOMLEFT", 0, 0);
	_G[show_abandon:GetName() .. "Text"]:SetText(QBL["CONFIG_SHOW_ABANDON"]);
	show_abandon:SetChecked(QuestBusterOptions[QuestBusterEntry].watch_frame["show_abandon"]);
	show_abandon:SetScript("OnClick", function(self, button)
		QuestBusterOptions[QuestBusterEntry].watch_frame["show_abandon"] = self:GetChecked();
	end);

	child_watch_frame_frame:SetScript("OnShow", nil);
end);
InterfaceOptions_AddCategory(child_watch_frame_frame);

function QuestBuster_Config_Show()
	InterfaceOptionsFrame_OpenToCategory(config_frame.name);
	InterfaceOptionsFrame_OpenToCategory(config_frame.name);		--hack for patch 5.3

	updateFields();
end