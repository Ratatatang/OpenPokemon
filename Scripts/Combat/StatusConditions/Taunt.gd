extends StatusCondition

func _init():
	statusName = "Taunted"
	activeMessage = "{Pokemon} cannot use {Move} due to the taunt!"
	startMessage = "{Pokemon} fell for the taunt!"
	forbidMoves = ["Status"]
	hasStartMessage = true
