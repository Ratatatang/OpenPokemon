extends TextureProgressBar

@onready var greenBar = load("res://Assets/Combat/GreenHealth.png")
@onready var yellowBar = load("res://Assets/Combat/YellowHealth.png")
@onready var redBar = load("res://Assets/Combat/RedHealth.png")

func _process(delta):
	if(value > 500):
		texture_progress = greenBar
	elif(value < 500 and value > 200):
		texture_progress = yellowBar
	else:
		texture_progress = redBar
