extends KinematicBody

var pokemon

export var ACCELERATION = 30
export var MAX_SPEED = 1
export var FRICTION = 40

var walkSpeed = 5

var velocity = Vector3.ZERO
var currDirection = directions.DOWN
var state = actionStates.IDLE

enum directions{
	DOWN,
	UP,
	RIGHT,
	LEFT
}

enum actionStates{
	IDLE,
	WANDER,
	EMOTE
}

var actions = [state, actionStates.IDLE, actionStates.WANDER, actionStates.EMOTE]
# Passive Actions List: previous state, idle, wander, emote


func _process(delta):
	
	state = actions[round(rand_range(0, 3))]
	
	match currDirection:
		directions.UP:
			$Sprite.animation = "up"
			
		directions.DOWN:
			$Sprite.animation = "down"
			
		directions.LEFT:
			$Sprite.animation = "left"
			
		directions.RIGHT:
			$Sprite.animation = "right"
	
	match state:
		actionStates.IDLE:
			velocity = velocity.move_toward(Vector3.ZERO, FRICTION*delta)
			
		actionStates.WANDER:
			pass
			
		actionStates.EMOTE:
			pass

func setSprite(spritePath):
	$Sprite.texture = load(spritePath)

