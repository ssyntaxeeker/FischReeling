local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetsAnimationAssets = ReplicatedStorage.Assets.PetsAnimations
local PetsFolder = workspace.Pets

local AnimationManager = require(ReplicatedStorage.Shared.AnimationManager)
local Net = require(ReplicatedStorage.Packages.Net)

local UpdatePetsState = Net:RemoteEvent("UpdatePetsState")
local currentStates = {}

local StateFunctions = {
	Walk = function(petModel)
		local PetAnimations = PetsAnimationAssets:FindFirstChild(petModel:GetAttribute("PetName"))

		if not PetAnimations then
			warn(`Could not play Walk State - No animations for pet {petModel.Name}`)
			return
		end

		local WalkAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.Walk)

		for _, animation in petModel.Humanoid.Animator:GetPlayingAnimationTracks() do
			animation:Stop(0.1)
		end

		WalkAnimation:Play(0.1)
	end,
	Wander = function(petModel)
		local PetAnimations = PetsAnimationAssets:FindFirstChild(petModel:GetAttribute("PetName"))

		if not PetAnimations then
			warn(`Could not play Walk State - No animations for pet {petModel.Name}`)
			return
		end

		local WanderAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.Wander)
		local AlertAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.Alert)

		for _, animation in petModel.Humanoid.Animator:GetPlayingAnimationTracks() do
			animation:Stop(0.1)
		end

		AlertAnimation:Play(0.1)
		AlertAnimation.Ended:Wait()

		if not table.find(currentStates, "Wander") then return end

		WanderAnimation:Play()
	end,
	Idle = function(petModel)
		local PetAnimations = PetsAnimationAssets:FindFirstChild(petModel:GetAttribute("PetName"))

		if not PetAnimations then
			warn(`Could not play Walk State - No animations for pet {petModel.Name}`)
			return
		end

		local IdleAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.Idle)

		for _, animation in petModel.Humanoid.Animator:GetPlayingAnimationTracks() do
			animation:Stop(0.1)
		end

		IdleAnimation:Play(0.1)
	end,
	Sleep = function(petModel)
		local PetAnimations = PetsAnimationAssets:FindFirstChild(petModel:GetAttribute("PetName"))

		if not PetAnimations then
			warn(`Could not play Walk State - No animations for pet {petModel.Name}`)
			return
		end

		local LayingAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.LayDown)
		local SleepAnimation = AnimationManager.GetTrack(petModel.Humanoid.Animator, PetAnimations.Sleep)

		for _, animation in petModel.Humanoid.Animator:GetPlayingAnimationTracks() do
			animation:Stop(0.1)
		end

		LayingAnimation:Play(0.1)
		LayingAnimation.Ended:Wait()

		if not table.find(currentStates, "Sleep") then return end

		SleepAnimation:Play()
	end,
}

UpdatePetsState.OnClientEvent:Connect(function(player, newStates)
	local petModel = PetsFolder:FindFirstChild(player.Name)

	if not petModel then
		warn(`No petModel for {player.Name}`)
		return
	end

	currentStates = {}

	for _, state in newStates do
		if not StateFunctions[state] then continue end

		table.insert(currentStates, state)
		StateFunctions[state](petModel)
	end
end)

return 0
