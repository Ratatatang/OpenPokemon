extends Button

signal movePressed(move)

var storedMove

func _on_pressed():
	movePressed.emit(storedMove)

func _physics_process(delta):
	if(storedMove != null):
		if(storedMove.PP[0] <= 0):
			visible = false
