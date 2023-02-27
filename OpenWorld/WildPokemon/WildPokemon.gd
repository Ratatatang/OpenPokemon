extends KinematicBody

var pokemon
export var pokemonName = "Bulbasaur"

export var ACCELERATION = 0.15
export var MAX_SPEED = 0.2
export var FRICTION = 0.1

export var walkSpeed = 5

var velocity = Vector3.ZERO
var state = IDLE

export var currHeight = 0.515
export var lockedHeight = true

enum {
	IDLE,
	WANDER,
	EMOTE
}

onready var wanderController = $WanderController

func _ready():
	wanderController.start_wander_timer(0.1)
	currHeight = global_translation.y
	pokemon = get_node("/root/Master").getPokemon(pokemonName)
	
func _physics_process(delta):
	
	var animVector = velocity.normalized()
	animVector = Vector2(animVector.x, animVector.z)
	$AnimationTree.set("parameters/blend_position", animVector)
	
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector3.ZERO, FRICTION*delta)
			
			if wanderController.get_time_left() == 0.0:
				state = pick_new_state([IDLE, WANDER, EMOTE, EMOTE])
				wanderController.start_wander_timer(rand_range(1.8, 5))
			
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
			$AnimationPlayer.play("emote")
			
			state = IDLE
			wanderController.start_wander_timer(rand_range(2.5, 3))
		
	velocity = move_and_slide(velocity)
	
	if lockedHeight:
		global_translation.y = currHeight

func setSprite(spritePath):
	$Sprite.texture = load(spritePath)
	
func pick_new_state(state_list):
	return state_list[round(rand_range(0, len(state_list)-1))]

