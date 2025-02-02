return {
	barCurrentPosition = UDim2.fromScale(0.5, 0.5),
	barSize = UDim2.fromScale(0.3, 0.714),

	pointerNextMove = os.clock(),
	pointerPosition = UDim2.fromScale(0.5, 0.5),

	difficulty = 7,
	progress = 0,

	holdingClick = false,
	reeling = false,
	overPointer = false,
}
