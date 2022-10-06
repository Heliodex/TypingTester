local BadgeService = game:GetService "BadgeService"
local Badge = {}
local alreadyAwarded = {}

function Badge:AwardBadge(player, badgeId)
	if table.find(alreadyAwarded, badgeId) then
		return
	end

	local success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)
	if success and badgeInfo.IsEnabled then
		local awarded, errorMessage = pcall(BadgeService.AwardBadge, BadgeService, player.UserId, badgeId)
		if awarded then
			print(badgeInfo.Name, "badge awarded")
			table.insert(alreadyAwarded, badgeId)
		else
			warn("Error while awarding badge:", errorMessage)
		end
	end
end

return Badge
