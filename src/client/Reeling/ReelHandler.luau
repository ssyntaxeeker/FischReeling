local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReelInterface = require(ReplicatedStorage.Modules.Reeling.ReelInterface)
local ReelUI = require(ReplicatedStorage.Modules.Reeling.ReelUI)
local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}
module.reelSignal = Signal.new()
module.startHoldClickSignal = Signal.new()
module.stopHoldClickSignal = Signal.new()

local function updateBarPosition(velocity, dt)
	velocity += (ReelInterface.holdingClick and 1 or -1) * 0.015 * dt
	velocity *= 0.98

	local catchBarSize = ReelInterface.barSize.X.Scale / 2
	local barX = math.clamp(ReelInterface.barCurrentPosition.X.Scale + velocity, catchBarSize + 0.01, 1 - catchBarSize - 0.01)

	ReelInterface.barCurrentPosition = UDim2.fromScale(barX, ReelInterface.barCurrentPosition.Y.Scale)

	return velocity
end

local function updatePointer()
	local difficulty = ReelInterface.difficulty or 1
	local minInterval = 1.5 - (difficulty - 1) * 0.12
	local maxInterval = 2 - (difficulty - 1) * 0.16
	local minMoveDistance = 0.05 + (difficulty - 1) * 0.01
	local maxMoveDistance = 0.15 + (difficulty - 1) * 0.05

	if not ReelInterface.pointerNextMove then
		ReelInterface.pointerNextMove = os.clock() + math.random() * (maxInterval - minInterval) + minInterval
	end

	if os.clock() >= ReelInterface.pointerNextMove then
		local currentX = ReelInterface.pointerPosition.X.Scale
		local moveDistance = math.random() * (maxMoveDistance - minMoveDistance) + minMoveDistance
		local direction = math.random() < 0.5 and -1 or 1
		local newX = math.clamp(currentX + direction * moveDistance, 0.1, 0.9)

		ReelInterface.pointerPosition = UDim2.fromScale(newX, ReelInterface.pointerPosition.Y.Scale)
		ReelInterface.pointerNextMove = os.clock() + math.random() * (maxInterval - minInterval) + minInterval
	end
end

local progressAdd = 10
local canFail = false

local function endReeling()
	ReelInterface.reeling = false
end

local function updateProgress(dt)
	ReelInterface.progress = math.clamp(ReelInterface.progress + (ReelInterface.overPointer and 1 or -1) * progressAdd * dt, 0, 100)

	if ReelInterface.progress > 10 then canFail = true end

	if ReelInterface.progress >= 100 then
		print("REEL FINISHED!!")

		endReeling()

		return true
	elseif ReelInterface.progress <= 0 and canFail == true then
		print("REEL FAILED!")

		endReeling()

		return false
	end

	return nil
end

module.reelSignal:Connect(function()
	if ReelInterface.reeling then return end

	local velocity = 0

	ReelInterface.progress = 0
	ReelInterface.barCurrentPosition = UDim2.fromScale(0.5, 0.5)
	ReelInterface.reeling = true

	ReelUI.startUISignal:Fire()

	task.wait(2)

	local updateConnection

	updateConnection = RunService.RenderStepped:Connect(function(dt)
		velocity = updateBarPosition(velocity, dt)
		updatePointer()

		local done = updateProgress(dt)

		if not done then return end

		updateConnection:Disconnect()
		ReelUI.endUISignal:Fire()
	end)
end)

module.startHoldClickSignal:Connect(function()
	ReelInterface.holdingClick = true
end)

module.stopHoldClickSignal:Connect(function()
	ReelInterface.holdingClick = false
end)

return module
