local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CubeConfig = require(ReplicatedStorage.Shared.CubeConfig)
local CubeTracker = require(ReplicatedStorage.Shared.CubeTracker)

local CubeAsset = ReplicatedStorage.Assets.Cube

return function(cubeSettings)
	local position = cubeSettings.Position
	local size = cubeSettings.Size

	local newCube = CubeAsset:Clone()
	newCube.Position = position
	newCube.Size = Vector3.one * size

	CubeTracker[newCube] = { Level = math.random(1, 3) }
	newCube.Color = CubeConfig.Colors[CubeTracker[newCube].Level]

	return newCube
end
