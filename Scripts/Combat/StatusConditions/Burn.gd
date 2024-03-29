extends StatusCondition

func _init():
	statusName = "Burned"
	iconFrame = 3
	activeMessage = "{Pokemon} was hurt by the burn!"
	startMessage = "{Pokemon} was burned!"
	hasStartMessage = true
	reduceDamage = true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
	inflicted.reducePercentHP(6.25)
	return true
