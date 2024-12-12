local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

local module = {}
local states = {}

local UpdatePetsState = Net:RemoteEvent("UpdatePetsState")

function module.Get(player: Player): { string? }
	if not states[player] then states[player] = {} end

	local humanoidStates = states[player]

	return humanoidStates
end

function module.Has(player: Player, state: string): boolean
	if not states[player] then states[player] = {} end

	local humanoidStates = states[player]
	local stateIndex = table.find(humanoidStates, state)

	return if stateIndex == nil then false else true
end

function module.Add(player: Player, state: string)
	if not states[player] then states[player] = {} end
	if table.find(states[player], state) then return end

	table.insert(states[player], state)
	UpdatePetsState:FireAllClients(player, module.Get(player))
end

function module.ChangeTo(player: Player, state: string)
	states[player] = {}

	table.insert(states[player], state)
	UpdatePetsState:FireAllClients(player, module.Get(player))
end

function module.Del(player: Player, state: string)
	if not states[player] then
		states[player] = {}
		return
	end

	table.remove(states[player], table.find(states[player], state) or 0)
	UpdatePetsState:FireAllClients(player, module.Get(player))
end

return module
