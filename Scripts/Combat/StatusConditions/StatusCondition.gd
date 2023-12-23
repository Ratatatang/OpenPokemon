class_name StatusCondition

var statusName : String
var startMessage : String
var activeMessage : String
var clearMessage : String
var stageTag : String
var iconFrame : int

func _effect_always(pokeNode : battlePlayer, UI):
	return false

func _effect_preMoveUse(pokeNode : battlePlayer, UI):
	return false

func _effect_moveUse(pokeNode : battlePlayer, UI):
	return false

func _effect_moveExectute(pokeNode : battlePlayer, UI):
	return false

func _effect_moveHit(pokeNode : battlePlayer, UI):
	return false

func _effect_afterMoves(pokeNode : battlePlayer, UI):
	return false

func getStatusName() -> String:
	return statusName

func getStartMessage() -> String:
	return startMessage

func getStageTag() -> String:
	return stageTag
