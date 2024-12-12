local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetsAssets = ReplicatedStorage.Assets.Pets
local PetsFolder = workspace.Pets

local Net = require(ReplicatedStorage.Packages.Net)

local VisualizePet = Net:RemoteEvent("VisualizePet")
local UnVisualizePet = Net:RemoteEvent("UnvisualizePet")
local UpdatePetsState = Net:RemoteEvent("UpdatePetsState")

local currentStates = {}
local petPositions = {}
local petRotations = {}

local startTime = os.clock()
local comingBack = false
local comingBackTask

local function getPetGroundPosition(position, petModel)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { petModel, Players[petModel.Name].Character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local rayOrigin = position + Vector3.new(0, 5, 0)
	local rayDirection = Vector3.new(0, -20, 0)
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		return raycastResult.Position
	else
		return position
	end
end

local function calculateDesiredPosition(hrp, petModel)
	local offsetX = math.sin(tick() * 2) * 2.2
	local offsetZ = math.cos(tick() * 1.5) * 1.2

	local desiredPosition = hrp.Position + hrp.CFrame.LookVector * -7
	desiredPosition += Vector3.new(offsetX, 0, offsetZ)
	desiredPosition = getPetGroundPosition(desiredPosition, petModel)
	local petSize = petModel:GetExtentsSize()
	return desiredPosition + Vector3.new(0, (petSize.Y / 2) - 0.1, 0)
end

local function movePetToPosition(petModel, currentPosition, desiredPosition, currentRotation)
	local newPetPosition = currentPosition:Lerp(desiredPosition, 0.095)

	local lookDirection = (desiredPosition - newPetPosition).Unit
	local desiredRotation = CFrame.new(Vector3.zero, lookDirection)
	local smoothedRotation = currentRotation:Lerp(desiredRotation, 0.12)

	local targetCFrame = CFrame.new(newPetPosition) * smoothedRotation
	targetCFrame *= CFrame.Angles(0, math.rad(-90), 0)
	petModel:PivotTo(targetCFrame)

	return newPetPosition, smoothedRotation
end

local function isPetBehindPlayer(hrp, currentPosition)
	local playerForwardVector = hrp.CFrame.LookVector
	local toPetVector = (currentPosition - hrp.Position).Unit
	return playerForwardVector:Dot(toPetVector) < 0
end

local currentOffsetX = 0
local currentOffsetZ = 0
local targetOffsetX = 0
local targetOffsetZ = 0
local directionChangeTimer = 0

local function getSmoothRandomOffsets()
	directionChangeTimer -= RunService.Heartbeat:Wait()

	if directionChangeTimer <= 0 then
		targetOffsetX = math.random() * 2 - 1
		targetOffsetZ = math.random() * 2 - 1
		directionChangeTimer = math.random(2, 5)
	end

	currentOffsetX = currentOffsetX + (targetOffsetX - currentOffsetX) * 0.1
	currentOffsetZ = currentOffsetZ + (targetOffsetZ - currentOffsetZ) * 0.1

	return currentOffsetX, currentOffsetZ
end

local function getWanderPosition(hrp, petModel, maxDistance)
	local petPosition = petModel.PrimaryPart.Position
	local hrpPosition = hrp.Position

	local offsetX, offsetZ = getSmoothRandomOffsets()

	comingBack = if (hrpPosition - petPosition).Magnitude >= maxDistance then true else comingBack
	local offset

	if comingBack == true then
		offset = (hrpPosition - petPosition).Unit

		if not comingBackTask then comingBackTask = task.delay(3, function()
			comingBack = false
			comingBackTask = nil
		end) end
	else
		offset = Vector3.new(offsetX, 0, offsetZ)
	end

	local desiredPosition = petPosition
	desiredPosition += offset
	desiredPosition = getPetGroundPosition(desiredPosition, petModel)

	local petSize = petModel:GetExtentsSize()

	return desiredPosition + Vector3.new(0, (petSize.Y / 2) - 0.1, 0)
end

local function wanderAroundPet(petModel, currentPosition, currentRotation, hrp, maxDistance)
	local desiredPosition = getWanderPosition(hrp, petModel, maxDistance)

	local newPetPosition, smoothedRotation = movePetToPosition(petModel, currentPosition, desiredPosition, currentRotation)

	return newPetPosition, smoothedRotation
end

local function handleWanderState(petModel, currentPosition, currentRotation, hrp)
	local shouldTakeBreak = math.random() > 0.95
	if shouldTakeBreak then
		return currentPosition, currentRotation
	else
		return wanderAroundPet(petModel, currentPosition, currentRotation, hrp, 60)
	end
end

VisualizePet.OnClientEvent:Connect(function(player, petName)
	local petModel = PetsAssets:FindFirstChild(petName)
	local character = player.Character or player.CharacterAdded:Wait()
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if not petModel then
		warn(`Couldn't find pet model {petName} for {player.Name}`)
		return
	end

	petModel = petModel:Clone()
	petModel.Name = player.Name
	petModel.Parent = PetsFolder

	petModel:PivotTo(CFrame.new(calculateDesiredPosition(HumanoidRootPart, petModel)))
	startTime = os.clock()

	petPositions[player] = petModel:GetPivot().Position
end)

UnVisualizePet.OnClientEvent:Connect(function(player)
	local petModel = PetsFolder:FindFirstChild(player.Name)
	if petModel then petModel:Destroy() end
	petPositions[player] = nil
end)

UpdatePetsState.OnClientEvent:Connect(function(player, states)
	currentStates[player] = states
end)

RunService.RenderStepped:Connect(function(_)
	for _, player in Players:GetPlayers() do
		local character = player.Character

		if not character then continue end
		if not character:FindFirstChild("HumanoidRootPart") then continue end

		local hrp = character.HumanoidRootPart

		if not currentStates[player] then continue end
		if not PetsFolder:FindFirstChild(player.Name) then continue end

		local petModel = PetsFolder[player.Name]

		if table.find(currentStates[player], "Walk") or os.clock() - startTime <= 4 then
			local currentPosition = petPositions[player] or petModel:GetPivot().Position
			local currentRotation = petRotations[player] or CFrame.new(Vector3.zero, Vector3.new(1, 0, 0))
			local desiredPosition = calculateDesiredPosition(hrp, petModel)

			if not isPetBehindPlayer(hrp, currentPosition) then
				local avoidSide = math.random() > 0.5 and 1 or -1
				desiredPosition += hrp.CFrame.RightVector * avoidSide * 2
			end

			local distanceToPlayer = (desiredPosition - currentPosition).Magnitude
			if distanceToPlayer > 15 then desiredPosition = currentPosition:Lerp(desiredPosition, 0.2) end

			local newPetPosition, newRotation = movePetToPosition(petModel, currentPosition, desiredPosition, currentRotation)

			petPositions[player] = newPetPosition
			petRotations[player] = newRotation
		elseif table.find(currentStates[player], "Wander") then
			local playingAnimations = petModel.Humanoid.Animator:GetPlayingAnimationTracks()

			for _, track in playingAnimations do
				if track.Animation.Name == "Alert" then return end
			end

			local currentPosition = petPositions[player] or petModel:GetPivot().Position
			local currentRotation = petRotations[player] or CFrame.new(Vector3.zero, Vector3.new(1, 0, 0))

			local newPetPosition, newRotation = handleWanderState(petModel, currentPosition, currentRotation, hrp)

			petPositions[player] = newPetPosition
			petRotations[player] = newRotation
		end
	end
end)

return 0
