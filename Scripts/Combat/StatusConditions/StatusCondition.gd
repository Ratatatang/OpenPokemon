class_name StatusCondition

var statusName : String
var startMessage : String
var activeMessage : String
var clearMessage : String
var stageTag : String
var iconFrame : int
var hasStartMessage : bool = false
var reduceDamage : bool = false

func _effect_always(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func _effect_preMoveUse(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func _effect_moveUse(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func _effect_moveExectute(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func _effect_moveHit(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func _effect_afterMoves(inflicted : battlePlayer, opposing : battlePlayer, UI):
	return false

func getStatusName() -> String:
	return statusName

func getStartMessage() -> String:
	return startMessage

func getStageTag() -> String:
	return stageTag
