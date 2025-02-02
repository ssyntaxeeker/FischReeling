local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local UIAssets = ReplicatedStorage.Assets.UI

local ReelInterface = require(ReplicatedStorage.Modules.Reeling.ReelInterface)
local Signal = require(ReplicatedStorage.Packages.Signal)

local module = {}
module.startUISignal = Signal.new()
module.endUISignal = Signal.new()

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local ReelingUI = UIAssets.ReelingUI:Clone()
ReelingUI.Parent = playerGui

local renderStepped

local mouseHeldColor = Color3.new(0.407843, 0.454902, 0.560784)
local mouseDefaultColor = Color3.new(1, 1, 1)

local function createPointerTween(pointer)
	local duration = 0.9 - (ReelInterface.difficulty - 1) * 0.05
	local pointerInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	local tween = TweenService:Create(pointer, pointerInfo, { Position = ReelInterface.pointerPosition })
	tween:Play()

	tween.Completed:Connect(function()
		tween:Destroy()
	end)
end

local function isOverlappingX(A, B)
	local absPosAx = A.AbsolutePosition.X

	local aEdge1 = absPosAx
	local aEdge2 = absPosAx + A.AbsoluteSize.X

	local bCenter = B.AbsolutePosition.X

	return bCenter >= aEdge1 and bCenter <= aEdge2
end

module.startUISignal:Connect(function()
	if renderStepped then renderStepped:Disconnect() end

	local catchBar = ReelingUI.ReelBar.CatchBar
	local pointer = ReelingUI.ReelBar.Pointer
	local mouseImage = ReelingUI.ReelBar.Click
	local progressBar = ReelingUI.FillUpBar.Background.Bar

	catchBar.Size = ReelInterface.barSize

	renderStepped = RunService.RenderStepped:Connect(function()
		catchBar.Position = ReelInterface.barCurrentPosition
		progressBar.Size = UDim2.fromScale(math.clamp(ReelInterface.progress / 100, 0, 1), progressBar.Size.Y.Scale)

		mouseImage.ImageColor3 = if ReelInterface.holdingClick then mouseHeldColor else mouseDefaultColor

		createPointerTween(pointer)

		ReelInterface.overPointer = isOverlappingX(catchBar, pointer)
	end)
end)

module.endUISignal:Connect(function()
	if not renderStepped then return end

	renderStepped:Disconnect()
end)

return module
