local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CannonAssets = ReplicatedStorage.Assets.Cannon

local BallAsset = CannonAssets:WaitForChild("Ball")

return function(properties)
	local newBall = BallAsset:Clone()

	for property, newValue in properties do
		newBall[property] = newValue
	end

	return newBall
end
