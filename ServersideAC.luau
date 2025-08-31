local RunService = game:GetService("RunService")
local ACSettings = require(script.ACSettings)
local ACAlert = require(script.ACAlert)
local speedToMagnitudeMultiplier = 0.1

game.Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("ACDetections", 0)
	player.AttributeChanged:Connect(function(attribute)
		if attribute == "ACDetections" and player:GetAttribute("ACDetections") >= ACSettings.DetectionsToKick then
			player:Kick("Anticheat Kick")
		end
	end)
	
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {character}
		params.FilterType = Enum.RaycastFilterType.Exclude		
		
		RunService.Stepped:Connect(function()
			character:SetAttribute("SteppedPosition", character:GetPivot().Position)
		end)
		RunService.Heartbeat:Connect(function()
			local steppedPosition = character:GetAttribute("SteppedPosition")
			local currentPosition = character:GetPivot().Position
			
			-- Speedhack and Teleport detection
			local moved = (currentPosition * Vector3.new(1, 0, 1) - steppedPosition * Vector3.new(1, 0, 1)).Magnitude
			if moved > ACSettings.MaxWalkSpeed * speedToMagnitudeMultiplier and ACSettings.DetectSpeedhackAndTeleport then
				ACAlert.alert(player, "Speedhack")
				character:MoveTo(steppedPosition)
			end
			
			-- Noclip detection
			local ray = workspace:Raycast(steppedPosition, currentPosition - steppedPosition, params)
			if ray and ray.Instance:IsA("BasePart") and ray.Instance.CanCollide and ACSettings.DetectNoclip then
				ACAlert.alert(player, "Noclip")
				character:MoveTo(steppedPosition)
			end
		end)
		
		-- Infinite Jump detection
		humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Jumping and humanoid.FloorMaterial == Enum.Material.Air and ACSettings.DetectInfiniteJump then
				ACAlert.alert(player, "Infinite Jump")
				character:MoveTo(character:GetAttribute("SteppedPosition"))
			end
		end)
	end)
end)
