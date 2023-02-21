extends KinematicBody

var pokemon

export var ACCELERATION = 0.15
export var MAX_SPEED = 0.2
export var FRICTION = 0.05

var walkSpeed = 5

var velocity = Vector3.ZERO
var state = IDLE

var currHeight = 0.515
var lockedHeight = true

enum {
	IDLE,
	WANDER,
	EMOTE
}

# Passive Actions List: previous state, idle, wander, emote

onready var wanderController = $WanderController

func _ready():
	wanderController.start_wander_timer(0.1)
	currHeight = global_translation.y

func _physics_process(delta):
	
	$Sprite.animation = "down"
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector3.ZERO, FRICTION*delta)
			
			if wanderController.get_time_left() == 0.0:
				state = pick_new_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
			
		WANDER:
			if wanderController.get_time_left() == 0.0:
				state = pick_new_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
				
			var direction = global_translation.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, MAX_SPEED * delta)
			
			if global_translation.distance_to(wanderController.target_position) <= MAX_SPEED:
				state = IDLE
				wanderController.start_wander_timer(rand_range(1, 3))
			
		EMOTE:
			if wanderController.get_time_left() == 0.0:
				state = pick_new_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1.8, 5))
		
	velocity = move_and_slide(velocity)
	
	if lockedHeight:
		global_translation.y = currHeight

func setSprite(spritePath):
	$Sprite.texture = load(spritePath)
	
func pick_new_state(state_list):
	return state_list[round(rand_range(0, 1))]

