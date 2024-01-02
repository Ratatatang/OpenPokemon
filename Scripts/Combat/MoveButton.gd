extends Button

signal movePressed(move)

@export var storedMove : Dictionary

func _on_pressed():
	movePressed.emit(storedMove)

func _physics_process(delta):
	if(storedMove.PP[0] <= 0):
		visible = false
