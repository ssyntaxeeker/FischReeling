local module = {}
local tracks = {}

local function LoadAnimation(animator: Animator, animation: Animation): AnimationTrack?
	local animationName = animation.Name

	tracks[animator] = tracks[animator] or {}

	if not animation then
		warn(`Couldn't load {animationName} - Animation 404`)
		return
	end

	tracks[animator][animation] = animator:LoadAnimation(animation)

	return tracks[animator][animation]
end

function module.GetTrack(animator: Animator, animation: Animation): AnimationTrack?
	local animationName = animation.Name

	if not tracks[animator] then tracks[animator] = {} end

	tracks[animator][animation] = tracks[animator][animation] or LoadAnimation(animator, animation)

	local track = tracks[animator][animation]

	if not track then
		warn(`Couldn't load {animationName} - Animation 404`)
		return
	end

	return track
end

return module
