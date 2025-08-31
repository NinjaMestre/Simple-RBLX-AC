local module = {}
local ACSettings = require(script.Parent.ACSettings)

function module.alert(player, cheatName)
	player:SetAttribute("ACDetections", player:GetAttribute("ACDetections") + 1)
	print(player.Name.." - "..cheatName.." detected: "..player:GetAttribute("ACDetections").."/"..ACSettings.DetectionsToKick.." detections")
end

return module
