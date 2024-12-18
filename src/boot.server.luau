local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Sandwich = require(ReplicatedStorage.Packages.Sandwich)
local Schedules = require(ReplicatedStorage.Shared.Schedules)

Schedules["Boot"] = Sandwich.schedule()

print("INITIALIZING SERVER")
print("-------------------")

for _, module in ServerStorage.Modules:GetDescendants() do
	if not module:IsA("ModuleScript") then continue end

	print("INITIALIZING " .. module.Name)

	require(module)
end

print("-------------------")
print("SERVER INITIALIZED")

Schedules["Boot"].start()
