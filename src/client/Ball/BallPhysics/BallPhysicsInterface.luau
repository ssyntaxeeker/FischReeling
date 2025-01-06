local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}

module.ApplyVelocity = Signal.new()

return module
