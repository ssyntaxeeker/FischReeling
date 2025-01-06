local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CubeHighlightAsset = ReplicatedStorage.Assets.CubeHighlight

return function(cubes)
	local newHighlight = CubeHighlightAsset:Clone()
	newHighlight.Parent = cubes
end
