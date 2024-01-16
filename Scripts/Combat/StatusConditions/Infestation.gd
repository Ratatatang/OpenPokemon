extends StatusCondition

func _init():
	statusName = "Infested"
	activeMessage = "{Pokemon} was hurt by the infestation!"
	startMessage = "{Pokemon} has been afflicted with an infestation!"
	clearMessage = "{Pokemon}'s infestation cleared away!"
	hasStartMessage = true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	if(counter == 5):
		inflicted.clearStatus(self)
		UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
		inflicted.reducePercentHP(12.5)
		return true
		
	elif(counter <= 3):
		counter += 1
		UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
		inflicted.reducePercentHP(12.5)
		return true
		
	else:
		var chance = [true, false].pick_random()
		if(chance):
			counter += 1
			UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
			inflicted.reducePercentHP(12.5)
			return true
			
		else:
			inflicted.clearStatus(self)
			UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
			return true
			
	return false
