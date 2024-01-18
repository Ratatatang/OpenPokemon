extends StatusCondition

func _init():
	statusName = "Paralyzed"
	iconFrame = 4
	activeMessage = "{Pokemon} couldn't move because it's paralyzed!"
	startMessage = "{Pokemon} is paralyzed, so it may be unable to move!"
	hasStartMessage = true
	reduceSpeed = true

func _effect_preMoveUse(inflicted : battlePlayer, opposing : battlePlayer, UI):
	if([true, false, false, false].pick_random()):
		inflicted.skipMove = true
		UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
		return true
	return false
