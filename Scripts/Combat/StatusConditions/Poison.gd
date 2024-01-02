extends StatusCondition

func _init():
	statusName = "Poisoned"
	iconFrame = 8
	activeMessage = "{Pokemon} was hurt by the poison!"
	startMessage = "{Pokemon} was poisoned!"
	hasStartMessage = true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
	inflicted.reducePercentHP(12.5)
	return true
