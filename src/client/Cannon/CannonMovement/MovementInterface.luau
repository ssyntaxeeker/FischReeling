local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}

module.LeftMovementStart = Signal.new()
module.RightMovementStart = Signal.new()

module.LeftMovementEnd = Signal.new()
module.RightMovementEnd = Signal.new()

module.SetCannon = Signal.new()

return module
