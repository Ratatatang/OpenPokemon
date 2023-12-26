extends StatusCondition

func _init():
	statusName = "Seeded"
	activeMessage = "{Pokemon}'s health was sapped by the Leech Seed!"
	startMessage = "{Pokemon} was seeded!"
	hasStartMessage = true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
	var healAmount = inflicted.reducePercentHP(12.5)
	opposing.heal(healAmount)
	return true
