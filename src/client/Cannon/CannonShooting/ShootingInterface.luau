local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}

module.ShootStart = Signal.new()
module.ShootEnd = Signal.new()

return module
