extends KinematicBody2D

onready var sprite = $Sprite
onready var timer = $Timer

func _physics_process(delta):
	position = Vector2(position.x+3, position.y)

func _on_Timer_timeout():
	if(sprite.frame != 11):
		$Sprite.frame += 1
	else:
		$Sprite.frame = 8

func setSprite(spritePath):
	sprite.texture = load(spritePath)

