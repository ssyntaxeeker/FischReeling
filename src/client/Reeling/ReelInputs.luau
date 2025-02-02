local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputManager = require(ReplicatedStorage.Modules.Inputs.InputManager)
local ReelHandler = require(ReplicatedStorage.Modules.Reeling.ReelHandler)

InputManager.addInput("HoldClickReeling", {
	Keys = { Enum.UserInputType.MouseButton1 },
	OnBegan = function()
		ReelHandler.startHoldClickSignal:Fire()
	end,
	OnEnded = function()
		ReelHandler.stopHoldClickSignal:Fire()
	end,
})

ReelHandler.reelSignal:Fire()

return 0
