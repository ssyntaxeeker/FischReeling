local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AddHighlightToCube = require(ReplicatedStorage.Modules.Cubes.AddHighlightToCubes)
local Constants = require(ReplicatedStorage.Shared.Constants)
local CreateCube = require(ReplicatedStorage.Modules.Cubes.CreateCube)
local MatchInterface = require(ReplicatedStorage.Modules.Match.MatchInterface)

local function ReconcileSettings(currentSettings)
	if not currentSettings then currentSettings = {} end

	for setting, value in MatchInterface.defaultSettings do
		if currentSettings[setting] then continue end

		currentSettings[setting] = value
	end

	return currentSettings
end

local BARRIER_OFFSET = Constants.BARRIER_OFFSET
local BARRIER_THICKNESS = Constants.BARRIER_THICKNESS

local function CreateBarriers(cubeModel, cubeSize)
	local barriersModel = Instance.new("Model")
	barriersModel.Name = "Barriers"
	barriersModel.Parent = workspace.Borders

	local extentsSize = cubeModel:GetExtentsSize()
	local modelCFrame = cubeModel:GetModelCFrame()

	local halfExtents = extentsSize / 2

	local positionsAndOrientations = {
		{
			position = modelCFrame.Position + Vector3.new(0, 0, halfExtents.Z + BARRIER_OFFSET),
			size = Vector3.new(extentsSize.X + 2 * BARRIER_THICKNESS, cubeSize, BARRIER_THICKNESS),
			color = Color3.new(1),
		}, -- Front
		{
			position = modelCFrame.Position - Vector3.new(0, 0, halfExtents.Z + BARRIER_OFFSET),
			size = Vector3.new(extentsSize.X + 2 * BARRIER_THICKNESS, cubeSize, BARRIER_THICKNESS),
			color = Color3.new(0, 1),
		}, -- Back
		{
			position = modelCFrame.Position + Vector3.new(halfExtents.X + BARRIER_OFFSET, 0, 0),
			size = Vector3.new(BARRIER_THICKNESS, cubeSize, extentsSize.Z + 2 * BARRIER_THICKNESS),
			color = Color3.new(0, 0, 1),
		}, -- Right
		{
			position = modelCFrame.Position - Vector3.new(halfExtents.X + BARRIER_OFFSET, 0, 0),
			size = Vector3.new(BARRIER_THICKNESS, cubeSize, extentsSize.Z + 2 * BARRIER_THICKNESS),
			color = Color3.new(1, 1, 1),
		}, -- Left
	}

	for _, data in positionsAndOrientations do
		local barrier = Instance.new("Part")
		barrier.Size = data.size
		barrier.CFrame = CFrame.new(data.position)
		barrier.Color = data.color
		barrier.Anchored = true
		barrier.Parent = barriersModel
	end
end

MatchInterface.startSignal:Connect(function(matchSettings)
	matchSettings = ReconcileSettings(matchSettings)

	matchSettings.Model = Instance.new("Model")
	matchSettings.Model.Parent = workspace.Cubes

	for x = 0, matchSettings.Size.X - 1 do
		for z = 0, matchSettings.Size.Y - 1 do
			local cubeSize = matchSettings.CubeSize
			local cubeOffset = matchSettings.CubeOffset

			local initPos = matchSettings.InitialPosition
			local position = initPos + Vector3.new((x * cubeSize) + (x * cubeOffset), cubeSize, (z * cubeSize) + (z * cubeOffset))

			local cube = CreateCube { Position = position, Size = cubeSize }
			cube.Parent = matchSettings.Model
		end
	end

	AddHighlightToCube(matchSettings.Model)
	CreateBarriers(matchSettings.Model, matchSettings.CubeSize)
end)

task.delay(0.5, function()
	MatchInterface.startSignal:Fire()
end)

return 0
