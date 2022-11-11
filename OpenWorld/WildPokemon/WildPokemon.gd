extends Node2D

var walkSpeed = 0.5

var walkDown = [0, 1, 2, 3]
var walkUp = [12, 13, 14, 15]
var walkRight = [8, 9, 10, 11]
var walkLeft = [4, 5, 6, 7]

var currDirection = directions.DOWN

enum directions{
	DOWN,
	UP,
	RIGHT,
	LEFT
}

func _ready():
	loopAnimation()
	
func setSprite(spritePath):
	$Sprite.texture = load(spritePath)

func loopAnimation():
	while(true):
		for i in range(4):
			match currDirection:
				directions.DOWN:
					$Sprite.frame = walkDown[i]
				directions.UP:
					$Sprite.frame = walkUp[i]
				directions.RIGHT:
					$Sprite.frame = walkRight[i]
				directions.LEFT:
					$Sprite.frame = walkLeft[i]
			$Timer.wait_time = walkSpeed
			$Timer.start()
			yield($Timer, "timeout")
