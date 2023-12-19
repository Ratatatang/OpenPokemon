extends Button

signal movePressed(move)

@export var storedMove : Dictionary

func _on_pressed():
	movePressed.emit(storedMove)
