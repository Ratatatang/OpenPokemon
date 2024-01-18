extends StatusCondition

func _init():
	statusName = "Protected"
	activeMessage = "{Pokemon} protected itself!"
	startMessage = "{Pokemon} protected itself!"
	hasStartMessage = true
	protection = true

func _checkProtection(move):
	return true

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	inflicted.clearStatus(self)
