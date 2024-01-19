extends StatusCondition

func _init():
	statusName = "Bound"
	activeMessage = "{Pokemon} was squeezed by the bind!!"
	startMessage = "{Pokemon} was squeezed by {User}!"
	clearMessage = "{Pokemon} was freed from the bind!"
	hasStartMessage = true

func _effect_onInflicted(inflicted : battlePlayer, opposing : battlePlayer, UI):
	inflicted.trapped = true

func _effect_onClear(inflicted : battlePlayer, opposing : battlePlayer, UI):
	inflicted.trapped = false

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	if(counter == 5):
		inflicted.clearStatus(self)
		UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
		return true
		
	else:
		var chance = [true, false].pick_random()
		if(chance or counter < 4):
			counter += 1
			UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
			inflicted.reducePercentHP(12.5)
			return true
			
		else:
			inflicted.clearStatus(self)
			UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
			return true
			
	return false
