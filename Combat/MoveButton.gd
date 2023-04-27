extends TextureButton

var move
var type
var text

onready var parent = get_parent().get_parent()

signal move

func setButtonInfo(newMove):
	move = newMove
	visible = true
	var type = move.get("Type")
	type.capitalize()
	texture_normal = load("res://Combat/Buttons/"+type+"_Button.png")
	var text = move.get("DisplayName")
	$Label.text = text

func _on_Move_pressed():
	emit_signal("move", move)

func _on_Move_mouse_entered():
	parent.changePPDisplay(move.get("PP"))
