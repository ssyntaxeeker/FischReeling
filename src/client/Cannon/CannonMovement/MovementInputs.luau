local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputController = require(ReplicatedStorage.Modules.Inputs.InputManager)
local MovementInterface = require(ReplicatedStorage.Modules.Cannon.CannonMovement.MovementInterface)

InputController.addInput("LeftKey", {
	Keys = { Enum.KeyCode.E },
	OnBegan = function()
		MovementInterface.LeftMovementStart:Fire()
	end,
	OnEnded = function()
		MovementInterface.LeftMovementEnd:Fire()
	end,
})

InputController.addInput("RightKey", {
	Keys = { Enum.KeyCode.R },
	OnBegan = function()
		MovementInterface.RightMovementStart:Fire()
	end,
	OnEnded = function()
		MovementInterface.RightMovementEnd:Fire()
	end,
})

return 0
