local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local CubeConfig = require(ReplicatedStorage.Shared.CubeConfig)
local CubeTracker = require(ReplicatedStorage.Shared.CubeTracker)

local touchInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

local function removeCube(cube)
	cube:Destroy()
	CubeTracker[cube] = nil

	TweenService:Create(cube, touchInfo, { Size = Vector3.zero }):Play()
end

local function playTouchedTween(cube)
	local defaultSize = cube.Size

	local tween = TweenService:Create(cube, touchInfo, { Size = defaultSize * 0.75 })
	tween:Play()

	tween.Completed:Connect(function()
		local tween2 = TweenService:Create(cube, touchInfo, { Size = defaultSize })
		tween2:Play()

		tween2.Completed:Wait()

		tween:Destroy()
		tween2:Destroy()
	end)
end

local function changeLevel(cube)
	if not CubeTracker[cube].Durability then CubeTracker[cube].Durability = CubeConfig.Durabilities[CubeTracker[cube].Level] end

	CubeTracker[cube].Durability -= 1

	if CubeTracker[cube].Durability <= 0 then
		CubeTracker[cube].Level -= 1
		CubeTracker[cube].Durability = CubeConfig.Durabilities[CubeTracker[cube].Level]
	end

	if CubeTracker[cube].Level <= 0 then
		removeCube(cube)
		return
	end

	local color = CubeConfig.Colors[CubeTracker[cube].Level]

	local tween = TweenService:Create(cube, touchInfo, { Color = color })
	tween:Play()
end

return function(cube)
	playTouchedTween(cube)
	changeLevel(cube)
end
