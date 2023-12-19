extends CharacterBody3D
class_name WildPokemon

var pokemonData
@export var pokemonName = "Bulbasaur"

@export var ACCELERATION = 0.15
@export var MAX_SPEED = 0.2
@export var FRICTION = 0.1

@export var walkSpeed = 5

var velocity2D = Vector3.ZERO
var state = WANDER

var currHeight = 0.515
var lockedHeight = true

var canEmote = true

enum {
	IDLE,
	WANDER,
	EMOTE,
}

@onready var wanderController = $WanderController

var runReady = true

"""puppet var puppet_pos = global_position
puppet var puppet_direction = Vector2.ZERO
puppet var puppet_animation = "down"
puppet var puppet_velocity = Vector3.ZERO"""

var animVector = Vector2.ZERO

func _ready():
	wanderController.start_wander_timer(0.1)
	currHeight = global_position.y
	pokemonData = MasterInfo.getPokemon(pokemonName)
	
	if(pokemonData.has("Acceleration")):
		ACCELERATION = pokemonData.get("Acceleration")
	if(pokemonData.has("Max Speed")):
		MAX_SPEED = pokemonData.get("Max Speed")
	if(pokemonData.has("Friction")):
		FRICTION = pokemonData.get("Friction")
	if(pokemonData.has("Walk Speed")):
		walkSpeed = pokemonData.get("Walk Speed")
	
func _physics_process(delta):
	if true:
#	if get_node("/root/Master").connectedToServer == false or is_multiplayer_authority():
		if(state != IDLE and state != EMOTE):
			animVector = velocity2D.normalized()
			animVector = Vector2(animVector.x, animVector.z)
			$AnimationTree.set("parameters/blend_position", animVector)
	
	
		match state:
			IDLE:
				velocity2D = velocity2D.move_toward(Vector3.ZERO, FRICTION*delta)
			
				if wanderController.get_time_left() == 0.0:
					var options = [IDLE, WANDER]
					if(canEmote):
						options.append(EMOTE)
					state = pick_new_state(options)
					wanderController.start_wander_timer(randf_range(1.8, 3.5))
			
			WANDER:
				if wanderController.get_time_left() == 0.0:
					state = pick_new_state([IDLE, WANDER])
					wanderController.start_wander_timer(randf_range(1, 3))
				
				var direction = global_position.direction_to(wanderController.target_position)
				velocity2D = velocity2D.move_toward(direction * MAX_SPEED, MAX_SPEED * delta)
			
				if global_position.distance_to(wanderController.target_position) <= MAX_SPEED:
					state = IDLE
					wanderController.start_wander_timer(randf_range(1, 3))
			
			EMOTE:
				if(!canEmote):
					state = pick_new_state([IDLE, WANDER])
				else:
					$AnimationPlayer.play("emote")
			
					state = IDLE
					wanderController.start_wander_timer(randf_range(1, 3))
					wanderController.start_emote_timer(randf_range(1, 2.5))
		
		set_velocity(velocity2D)
		move_and_slide()
		velocity2D = velocity2D
	
#		if lockedHeight:
#			global_position.y = currHeight
"""	else:
		
		$AnimationTree.set("parameters/blend_position", puppet_direction)
		
		$AnimationPlayer.play(puppet_animation)
			
		if(puppet_velocity != Vector3.ZERO):
			set_velocity(puppet_velocity)
			move_and_slide()
			global_position.y = currHeight
		else:
			global_position = puppet_pos"""

func setSprite(spritePath):
	$Sprite2D.texture = load(spritePath)
	
func pick_new_state(state_list):
	return state_list[round(randf_range(0, len(state_list)-1))]

"""func _on_networkTimer_timeout():
	if is_multiplayer_authority():
		rset_unreliable("puppet_pos", global_position)
		rset_unreliable("puppet_direction", animVector)
		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("puppet_animation", $AnimationPlayer.current_animation)

func startTimer():
	$networkTimer.start()"""


func _on_emote_timer_timeout():
	canEmote = true
