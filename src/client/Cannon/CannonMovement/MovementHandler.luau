local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MovementInterface = require(ReplicatedStorage.Modules.Cannon.CannonMovement.MovementInterface)

local CannonModel = workspace:WaitForChild("Cannon")
local Barrel = CannonModel:WaitForChild("Barrel")
local defaultBarrelPivot = Barrel:GetPivot()

local currentAngle = 0
local angleAdder = 0
local angleIncrement = 50
local angleLimit = 45

local function moveCannon()
	Barrel:PivotTo(defaultBarrelPivot * CFrame.Angles(0, math.rad(currentAngle), 0))
end

RunService.RenderStepped:Connect(function(dT)
	currentAngle += angleAdder * dT

	if currentAngle > angleLimit or currentAngle < -angleLimit then currentAngle = currentAngle > 0 and angleLimit or -angleLimit end

	moveCannon()
end)

MovementInterface.LeftMovementStart:Connect(function()
	angleAdder += angleIncrement
end)

MovementInterface.LeftMovementEnd:Connect(function()
	angleAdder -= angleIncrement
end)

MovementInterface.RightMovementStart:Connect(function()
	angleAdder += -angleIncrement
end)

MovementInterface.RightMovementEnd:Connect(function()
	angleAdder -= -angleIncrement
end)

return 0
