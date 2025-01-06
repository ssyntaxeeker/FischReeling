local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sandwich = require(ReplicatedStorage.Packages.Sandwich)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

print("INITIALIZING CLIENT")
print("-------------------")

Schedules["Boot"] = Sandwich.schedule()

for _, module in ReplicatedStorage.Modules:GetDescendants() do
	if not module:IsA("ModuleScript") then continue end

	print("INITIALIZING " .. module.Name)

	require(module)
end

print("-------------------")
print("CLIENT INITIALIZED")

Schedules["Boot"].start()
