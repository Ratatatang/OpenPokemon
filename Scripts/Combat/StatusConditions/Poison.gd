extends StatusCondition

func _init():
	statusName = "Poison"
	iconFrame = 3
	activeMessage = "{Pokemon} was hurt by the poison!"
	startMessage = "{Pokemon} was poisoned!"
	hasStartMessage = true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
	inflicted.reducePercentHP(12.5
	)
	return true
