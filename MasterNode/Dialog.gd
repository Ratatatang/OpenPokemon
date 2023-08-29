extends CanvasLayer

onready var walkie = $Walkie
onready var tween = $Tween

onready var outline = $Walkie/StaticBubble/Outline

var active = false

func _ready():
	active = false
	walkie.position = Vector2(-40, 900)
	visible = false

func _unhandled_input(event):
	if event.is_action_pressed("test2"):
		if(active):
			deactivate()
		else:
			activate()

func activate():
	visible = true
	active = true
	tween.interpolate_property(walkie, "position", walkie.position, $Position2D.position, 0.3, Tween.TRANS_LINEAR)
	tween.start()

func deactivate():
	active = false
	tween.interpolate_property(walkie, "position", walkie.position, Vector2(-40, 900), 0.3, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_completed")
	visible = false
	
