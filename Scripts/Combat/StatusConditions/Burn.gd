extends StatusCondition

func _init():
	iconFrame = 3
	activeMessage = "{Pokemon} was hurt by the burn!"

func _effect_afterMoves(pokeNode : battlePlayer, UI):
	UI.setDialog(activeMessage.format({"Pokemon":pokeNode.getName()}))
	pokeNode.reducePercentHP(6.25)
	return true
