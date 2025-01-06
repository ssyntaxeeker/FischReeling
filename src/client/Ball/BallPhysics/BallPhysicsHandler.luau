local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BallModules = ReplicatedStorage.Modules.Ball

local BallPhysicsInterface = require(BallModules.BallPhysics.BallPhysicsInterface)
local BreakCube = require(ReplicatedStorage.Modules.Cubes.BreakCube)

local ballVelocities = {}
local defaultDecay = 10
local reboundKinecticMultiplier = 0.98

local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = { workspace.Borders, workspace.Cubes }
rayParams.FilterType = Enum.RaycastFilterType.Include

RunService.PreSimulation:Connect(function(dT)
	for ball, velocity in ballVelocities do
		local rate = defaultDecay * dT

		ballVelocities[ball] -= velocity.Unit * rate

		if not ball then continue end

		repeat
			task.wait()

			if not ball then return end

			local ray = workspace:Raycast(ball.Position, ballVelocities[ball] * dT, rayParams)

			if ray and ray.Instance then
				local norm = ray.Normal
				norm = Vector3.new(norm.X, 0, norm.Z).Unit

				ballVelocities[ball] = (ballVelocities[ball] - (2 * ballVelocities[ball]:Dot(norm) * norm)) * reboundKinecticMultiplier

				if ray.Instance:FindFirstAncestor("Cubes") then
					BreakCube(ray.Instance)

					ballVelocities[ball] = nil
					ball:Destroy()
					ball = nil
				end
			end

		until not ray or not ray.Instance

		ball.Position += ballVelocities[ball] * dT
	end
end)

BallPhysicsInterface.ApplyVelocity:Connect(function(ball, velocity)
	ballVelocities[ball] = velocity
end)

return 0
