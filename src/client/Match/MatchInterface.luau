local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}

module.defaultSettings = {
	Difficulty = "Normal",
	Size = Vector2.new(15, 8),
	CubeSize = 3,
	CubeOffset = 1,
	InitialPosition = Vector3.zero,
}

module.startSignal = Signal.new()

return module
