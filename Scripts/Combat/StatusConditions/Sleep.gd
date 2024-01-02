extends StatusCondition

func _init():
	statusName = "Sleeping"
	iconFrame = 1
	activeMessage = "{Pokemon} is fast asleep."
	startMessage = "{Pokemon} fell asleep!"
	clearMessage = "{Pokemon} woke up!"
	hasStartMessage = true

func _effect_preMoveUse(inflicted : battlePlayer, opposing : battlePlayer, UI):
	if(inflicted.sleepCounter == 3):
		inflicted.clearStatus(self)
		UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
		return true
		
	elif(inflicted.sleepCounter == 0):
		inflicted.sleepCounter += 1
		inflicted.skipMove = true
		UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
		return true
		
	else:
		var chance = [true, false].pick_random()
		if(chance):
			inflicted.sleepCounter += 1
			inflicted.skipMove = true
			UI.setDialog(activeMessage.format({"Pokemon":inflicted.getName()}))
			return true
			
		else:
			inflicted.clearStatus(self)
			UI.setDialog(clearMessage.format({"Pokemon":inflicted.getName()}))
			return true
			
	return false
