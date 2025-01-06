local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputController = require(ReplicatedStorage.Modules.Inputs.InputManager)
local ShootingInterface = require(ReplicatedStorage.Modules.Cannon.CannonShooting.ShootingInterface)

InputController.addInput("ShootKey", {
	Keys = { Enum.KeyCode.F },
	OnBegan = function()
		ShootingInterface.ShootStart:Fire()
	end,
	OnEnded = function()
		ShootingInterface.ShootEnd:Fire()
	end,
})

return 0
