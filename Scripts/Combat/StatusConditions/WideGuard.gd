extends StatusCondition

func _init():
	statusName = "Wide Guarded"
	activeMessage = "{Pokemon} protected itself from wide-ranged attacks!"
	startMessage = "{Pokemon} protected itself from wide-ranged attacks!"
	hasStartMessage = true
	protection = true

func _checkProtection(move):
	if(move.Target == "AllAdjacentFoes"):
		return true
	return false

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	inflicted.clearStatus(self)
