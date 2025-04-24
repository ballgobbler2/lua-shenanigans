local tool = script.Parent
local event = tool.RemoteEvent
local UserInputService = game:GetService("UserInputService")

tool.Equipped:Connect(function(mouse)
	local activeConnection = nil
	mouse.Button1Down:Connect(function()
		
		if mouse.Target and mouse.Target.Locked == false then
			local part = mouse.Target
			local ghostsize = part.Size
			local Ghost = Instance.new("Part")
			local trans = part.Transparency
			local newcframe
			Ghost.Name = "Ghost"
			mouse.TargetFilter = Ghost
			Ghost.Parent = workspace
			Ghost.Position = mouse.Hit.Position
			Ghost.Size = ghostsize
			Ghost.Anchored = true
			Ghost.CanCollide = false
			Ghost.Transparency = 0.7
			Ghost.Material = Enum.Material.Neon
			Ghost.Color = Color3.fromRGB(0, 0, 255)
			local inputConnection = nil
			local Rotat = Vector3.new(0,0,0)
			-- Detect R key
			inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.KeyCode == Enum.KeyCode.R then
					print("R key pressed")
					Rotat = Vector3.new(Rotat.X,Rotat.Y+90,Rotat.Z)
					print(Rotat)
					Ghost.Size = Vector3.new(Ghost.Size.Z,Ghost.Size.Y,Ghost.Size.X)
				end
				if input.KeyCode == Enum.KeyCode.T then
					print("T key pressed")
					Rotat = Vector3.new(Rotat.X+90,Rotat.Y,Rotat.Z)
					print(Rotat)
					Ghost.Size = Vector3.new(Ghost.Size.X,Ghost.Size.Z,Ghost.Size.Y)
				end
				if input.KeyCode == Enum.KeyCode.Y then
					print("T key pressed")
					Rotat = Vector3.new(Rotat.X,Rotat.Y,Rotat.Z+90)
					print(Rotat)
					Ghost.Size = Vector3.new(Ghost.Size.Y,Ghost.Size.X,Ghost.Size.Z)
				end
			end)
			local running = true

			-- Disconnect old connection if still active
			if activeConnection then
				activeConnection:Disconnect()
			end

			-- Connect once
			activeConnection = mouse.Button1Up:Connect(function()
				running = false
				if activeConnection then
					activeConnection:Disconnect()
					activeConnection = nil
				end
				local targ = mouse.Target
				event:FireServer(part, newcframe, targ)
				Ghost:Destroy()
			end)

			-- Update ghost position while holding
			while running and Ghost do
				ghostsize = Ghost.Size
				local target = mouse.Target
				local unitray = mouse.UnitRay
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = {Ghost}
				params.FilterType = Enum.RaycastFilterType.Exclude

				local res = workspace:Raycast(unitray.Origin, unitray.Direction * 1000, params)
				local normal = res.Normal
				local hitpos = res.Position

				Ghost.Rotation = target.Rotation
				local relatednormal = target.CFrame:VectorToObjectSpace(normal)

				-- Apply absolute value to relatednormal (makes sure it’s positive for snap checks)
				relatednormal = Vector3.new(
					math.abs(relatednormal.X),
					math.abs(relatednormal.Y),
					math.abs(relatednormal.Z)
				)

				-- Set snap increment (could be modified as needed)
				local increment = 0.5

				-- Convert hit position to relative space of the target part
				local relativhitpos = target.CFrame:PointToObjectSpace(hitpos)

				-- Apply snapping logic (disable snapping based on normal direction)
				relativhitpos = Vector3.new(
					(math.round(relatednormal.X) ~= 1 and math.floor(relativhitpos.X / increment + 0.5) * increment + (math.round(ghostsize.X/2)-ghostsize.X/2)  or relativhitpos.X),
					(math.round(relatednormal.Y) ~= 1 and math.floor(relativhitpos.Y / increment + 0.5) * increment + (math.round(ghostsize.Y/2)-ghostsize.Y/2)  or relativhitpos.Y),
					(math.round(relatednormal.Z) ~= 1 and math.floor(relativhitpos.Z / increment + 0.5) * increment + (math.round(ghostsize.Z/2)-ghostsize.Z/2)  or relativhitpos.Z)
				)

				-- Convert back to world space
				relativhitpos = target.CFrame:PointToWorldSpace(relativhitpos)
				hitpos = relativhitpos
				local relativeghostsize
				-- Adjust ghost position
				Ghost.Position = hitpos + normal * ((relatednormal * ghostsize).Magnitude) / 2
				newcframe = CFrame.new(Ghost.Position) * CFrame.Angles(
					math.rad(Rotat.X),
					math.rad(Rotat.Y),
					math.rad(Rotat.Z)
				)
				task.wait()
			end
		end
	end)

	-- Optional: Clean up if tool is unequipped
	tool.Unequipped:Connect(function()
		if activeConnection then
			activeConnection:Disconnect()
			activeConnection = nil
		end
		if inputConnection then
			inputConnection:Disconnect()
			inputConnection = nil
		end
	end)
end)
