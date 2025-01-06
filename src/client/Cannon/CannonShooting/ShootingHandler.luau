local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BallPhysicsInterface = require(ReplicatedStorage.Modules.Ball.BallPhysics.BallPhysicsInterface)
local CreateBall = require(ReplicatedStorage.Modules.Ball.CreateBall)

local ShootingInterface = require(ReplicatedStorage.Modules.Cannon.CannonShooting.ShootingInterface)

local CannonModel = workspace:WaitForChild("Cannon")
local Barrel = CannonModel:WaitForChild("Barrel")

local shootingInterval = 0.5
local shootTick = os.clock()
local shootBool = false

local function shoot()
	local Ball = CreateBall { CFrame = Barrel.Tip.CFrame, Parent = workspace.Debris }

	BallPhysicsInterface.ApplyVelocity:Fire(Ball, Ball.CFrame.LookVector * 80)
end

RunService.RenderStepped:Connect(function()
	if os.clock() > shootTick and shootBool == true then
		shoot()

		shootTick = os.clock() + shootingInterval
	end
end)

ShootingInterface.ShootStart:Connect(function()
	shootBool = true
end)

ShootingInterface.ShootEnd:Connect(function()
	shootBool = false
end)

return 0
