local _, qb = ...;

qb.loot = {};
qb.loot.frame = CreateFrame("Frame", "QuestBuster_LootFrame", UIParent);
qb.loot.frame:RegisterEvent("QUEST_COMPLETE");
qb.loot.frame:RegisterEvent("QUEST_ITEM_UPDATE");
qb.loot.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
qb.loot.frame:SetScript("OnEvent", function(self, event, ...)
	if (QuestBusterInit) then
		return qb.loot[event] and qb.loot[event](qb, ...)
	end
end);

local sparkle_frames = {};

local function highlightRewards()
	for key, reward_data in pairs(QBG_REWARDS) do
		local sparkle_frame = sparkle_frames[key];
		local selected = reward_data.sel_func();
		if (QuestBusterOptions[QuestBusterEntry].reward_highlights[key] and selected and _G["QuestInfoRewardsFrameQuestInfoItem" .. selected .. "IconTexture"] ~= nil) then
			sparkle_frame:ClearAllPoints();
			sparkle_frame:SetAllPoints("QuestInfoRewardsFrameQuestInfoItem" .. selected .. "IconTexture");
			sparkle_frame:Show();
			AnimatedShine_Start(sparkle_frame, reward_data.r, reward_data.g, reward_data.b);
		else
			sparkle_frame:Hide();
			AnimatedShine_Stop(sparkle_frame);
		end
	end
end

local function initRewardAutoSelect()
	if (QuestIsDaily() or QuestIsWeekly()) then
		for i=1, GetNumQuestChoices() do
			local frame = _G["QuestInfoRewardsFrameQuestInfoItem" .. i];
			frame:HookScript("OnEnter",
				function(self, ...)
					--if (self.show_frame ~= nil and self.show_frame ~= true) then
					if (not self.show_frame or self.show_frame ~= true) then		--something weird happening to cause this to duplicate itself
						local choice_id = self:GetID();
						local quest_id = GetQuestID();
						
						GameTooltip:AddLine(" ");
						local reward = QuestBusterOptions[QuestBusterEntry].daily_quest_rewards[quest_id];
						if (reward ~= nil and reward.reward_id == choice_id) then
							GameTooltip:AddLine(QBL["DAILY_QUEST_SELECTED_REWARD"]);
						else
							GameTooltip:AddLine(QBL["DAILY_QUEST_REWARD"]);
						end
						GameTooltip:Show();
						
						self.show_frame = true;
					end
				end
			);
			frame:HookScript("OnLeave",
				function(self, ...)
					self.show_frame = false;
				end
			);
			frame:HookScript("OnClick",
				function(self, button, ...)
					if (button == "LeftButton" and IsControlKeyDown()) then
						local choice_id = self:GetID();
						local quest_id = GetQuestID();
						local item_link = GetQuestItemLink("choice", choice_id);
						local _, _, item_count = GetQuestItemInfo("choice", choice_id);

						local reward = {};
						reward.quest_id = quest_id;
						reward.quest_title = GetTitleText();
						reward.reward_id = choice_id;
						reward.item_link = item_link;
						reward.item_count = item_count;
						QuestBusterOptions[QuestBusterEntry].daily_quest_rewards[quest_id] = reward;
					end
				end
			);
		end
	end
end

function qb.loot:QUEST_COMPLETE()
	highlightRewards();
	initRewardAutoSelect();
end

function qb.loot:QUEST_ITEM_UPDATE()
	highlightRewards();
end

function qb.loot:GET_ITEM_INFO_RECEIVED()
	highlightRewards();
end

local function getBestPriceReward()
	local max_price = 0;
	local selected = nil;
	for i=1, GetNumQuestChoices() do
		local _, _, quantity = GetQuestItemInfo("choice", i);
		if (not quantity) then
			quantity = 1;
		end

		local item_link = GetQuestItemLink("choice", i);
		if (not item_link) then
			return qb.omg:create_timer(1, getBestPriceReward);
		end

		local price = item_link and select(11, GetItemInfo(item_link));
		if (not price) then
			return;
		elseif (price * quantity > max_price) then
			max_price = price * quantity;
			selected = i;
		end
	end

	return selected;
end

local function getUpgrade()
	local selected = nil;
	
	return selected;
end

local function getTransmogItem()
	local selected = nil;
	if (QBG_HAS_MOGIT) then
		local mogit_wishlist = MogIt:GetModule("Wishlist");
		for i=1, GetNumQuestChoices() do
			local item_link = GetQuestItemLink("choice", i);
			if (item_link ~= nil and mogit_wishlist:IsItemInWishlist(item_link)) then
				selected = i;
			end
		end
	end
	
	return selected;
end

QBG_REWARDS[QBT_REWARD_NONE] = { label="None", sel_func=function() end };
QBG_REWARDS[QBT_REWARD_PRICE] = { label="Max Sell Price", sel_func=function() return getBestPriceReward() end, r=0, g=0.55, b=0 };
QBG_REWARDS[QBT_REWARD_UPGRADE] = { label="Upgrade", sel_func=function() return getUpgrade() end, r=0.96, g=1, b=0.55 };
if (QBG_HAS_MOGIT) then
	QBG_REWARDS[QBT_REWARD_TRANSMOG] = { label="Transmog", sel_func=function() return getTransmogItem() end, r=0.55, g=0, b=0.55 };
end
QBG_REWARDS[QBT_REWARD_AUTOSELECT] = { label="Auto Selected", sel_func=function() end, r=0.55, g=0.55, b=0 };

local function createSparkle(key, parent)
	local frame = CreateFrame("Frame", "QuestBuster_Loot_Reward" .. key, parent);
	local child_frame = CreateFrame("Frame", "QuestBuster_Loot_Reward" .. key .. "Shine", frame, "AnimatedShineTemplate");
	child_frame:ClearAllPoints();
	child_frame:SetAllPoints("QuestBuster_Loot_Reward" .. key);
	child_frame:Show();

	return frame;
end

if (QuestFrameRewardPanel:IsVisible()) then
	highlightRewards();
end

for key, value in pairs(QBG_REWARDS) do
	sparkle_frames[key] = createSparkle(key, QuestRewardScrollChildFrame);
	sparkle_frames[key]:Hide();
end