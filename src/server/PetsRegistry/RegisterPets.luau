local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local PetsData = require(ServerStorage.Modules.PetsRegistry.PetsData)
local Schedules = require(ReplicatedStorage.Shared.Schedules)
local StatesManager = require(ReplicatedStorage.Shared.StatesManager)

local VisualizePet = Net:RemoteEvent("VisualizePet")
local UnVisualizePet = Net:RemoteEvent("UnvisualizePet")

local function initPlayer(player)
	local data = PetsData.GetAllData()
	data[player] = PetsData.DefaultData

	for _player, petData in data do
		VisualizePet:FireAllClients(_player, petData.Pet)
	end

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		StatesManager.ChangeTo(player, "Idle")

		task.delay(7, function()
			StatesManager.ChangeTo(player, "Wander")
		end)

		humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if StatesManager.Has(player, "Wander") then return end

			local magnitude = humanoid.MoveDirection.Magnitude

			if magnitude == 0 then
				StatesManager.ChangeTo(player, "Idle")
			else
				if StatesManager.Has(player, "Walk") then return end

				StatesManager.ChangeTo(player, "Walk")
			end
		end)
	end)
end

local function removePlayer(player)
	UnVisualizePet:FireAllClients(player)
end

local function registerPets()
	for _, player in Players:GetPlayers() do
		initPlayer(player)
	end

	Players.PlayerAdded:Connect(initPlayer)
	Players.PlayerRemoving:Connect(removePlayer)
end

return Schedules["Boot"].job(registerPets)
