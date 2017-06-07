local _, qb = ...;

qb.brokers = {};
qb.brokers.frame = CreateFrame("Frame", "QuestBuster_BrokersFrame", UIParent);

function qb.brokers:update()
	qb.brokers.main:QUEST_LOG_UPDATE();
	--qb.brokers.world_quests:QUEST_LOG_UPDATE();
end