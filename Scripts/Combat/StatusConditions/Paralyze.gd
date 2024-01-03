extends StatusCondition

func _init():
	statusName = "Paralyzed"
	iconFrame = 4
	activeMessage = "{Pokémon} is paralyzed, so it may be unable to move!"
	startMessage = "{Pokémon} couldn't move because it's paralyzed!"
	hasStartMessage = true

func _effect_preMoveUse(inflicted : battlePlayer, opposing : battlePlayer, UI):
	inflicted.skipMove = true
	UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
	return true
