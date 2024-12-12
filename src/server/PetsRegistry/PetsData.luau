-- If adding a DataStore feel free to just change the InitData function

local module = {}
local data = {}

module.GetData = function(player)
	return data[player]
end

module.GetAllData = function()
	return data
end

module.DefaultData = { Pet = "Sharkie" }

return module
