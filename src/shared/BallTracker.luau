local cache = {}
local module = {}

module.add = function(uuid, ball)
	cache[uuid] = ball
end

module.get = function(uuid)
	return cache[uuid]
end

return module
