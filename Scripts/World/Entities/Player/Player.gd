extends CharacterBody3D

const ACCELERATION = 30
const MAX_SPEED = 0.7
const FRICTION = 40
const ROLL_SPEED = 1.4
signal player_entering_door

var frozen = false

var currentObject = ""

enum stateMachine {
	MOVE,
	ROLL,
	SWIM,
	SWIMDASH,
	FREEZE
}

var state = stateMachine.MOVE
var velocity2D = Vector3.ZERO
var roll_vector = Vector3.BACK
var animVector = Vector2.ZERO
var groundPos = 0.586
var currFloor = 0.586

var world

#puppet var moving = false

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

@onready var rayCast = $RayCast3D

#puppet var puppet_pos = global_position
#puppet var puppet_direction = Vector2.ZERO
#puppet var puppet_animation = "Idle"
#puppet var puppet_velocity = Vector3.ZERO

@onready var camera = load("res://Scenes/World/Entities/Player/3DCamera.tscn")

func _ready():
	#if(get_node("/root/Master").connectedToServer == false):
	add_child(camera.instantiate())
	#if(is_multiplayer_authority() and get_node("/root/Master").connectedToServer == true):
	#	$networkTimer.start()
	
	animationTree.active = true
	visible = true
	
	get_node("/root/Master").checkLoad()
	world = MasterInfo.worldGenNode
	
func _input(event):
	if(event.is_action_pressed("interact")):
		if(rayCast.is_colliding()):
			var collider = rayCast.get_collider().get_parent()
			print(collider.getName())
			if(collider.getType() == "Entity"):
				if(collider.battleable()):
					get_node("/root/Master").initiateCombat(collider.getPokemon())
					collider.battling()
					state = stateMachine.FREEZE
					await SignalManager.combatDone
					state = stateMachine.MOVE

# Matches the state machine to the correct state
func _physics_process(delta):

		if true:
#		if get_node("/root/Master").connectedToServer == false or is_multiplayer_authority():
			if(frozen == true):
				state = stateMachine.FREEZE
			MasterInfo.playerPosition = position
			
			match state:
				stateMachine.MOVE:	
					move_state(delta)
			
				stateMachine.ROLL:
					roll_state(delta)
				
				stateMachine.SWIM:
					swim_state(delta)
					
				stateMachine.FREEZE:
					freeze_state()
				
"""			if Input.is_action_just_pressed("Interact"):
				if($Camera2D/DialogBox.visible != true):
					if($PlayerInteractionBox.get_overlapping_areas() != []):
						if($Camera2D/DialogBox.visible == false):
							var dialog = $PlayerInteractionBox.get_overlapping_areas()[0].interact()
							$Camera2D/DialogBox.start(dialog)
							frozen = true"""
"""		else:			
			if moving == true:
				animationTree.set("parameters/Idle/blend_position", puppet_direction)
				animationTree.set("parameters/Run/blend_position", puppet_direction)
				animationTree.set("parameters/Roll/blend_position", puppet_direction)
	
			animationState.travel(puppet_animation)
			
			if(puppet_velocity != Vector3.ZERO):
				set_velocity(puppet_velocity)
				move_and_slide()
			else:
				global_position = puppet_pos"""
			
# Used for when you move into a door so you can't move. you don't have to unfreeze as this
# player is cleared after they walk into a door 
			
func freeze_state():
	velocity2D = Vector3.ZERO
	animationState.travel("Idle")
	
# State that sets all the animations to the input, and is used when moving

func move_state(delta):
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	currFloor = groundPos
	
	animVector = Vector2(input_vector.x, input_vector.z)
	
	if input_vector != Vector3.ZERO:
		#moving = true
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", animVector)
		animationTree.set("parameters/Run/blend_position", animVector)
		animationTree.set("parameters/Roll/blend_position", animVector)
		
		animationState.travel("Run")
		velocity2D = velocity2D.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
# If the player isn't moving, they are set to be idle

	else:
		#moving = false
		animationState.travel("Idle")
		velocity2D = velocity2D.move_toward(Vector3.ZERO, FRICTION * delta)
	
	if(world.waterTile(position)):
		state = stateMachine.SWIM
	
	elif Input.is_action_just_pressed("roll"):
		state = stateMachine.ROLL
		
	move()

func swim_state(delta):
	
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	currFloor = groundPos-0.06
	
	animVector = Vector2(input_vector.x, input_vector.z)
	
	if input_vector != Vector3.ZERO:
		#moving = true
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", animVector)
		animationTree.set("parameters/Run/blend_position", animVector)
		animationTree.set("parameters/Roll/blend_position", animVector)
		
		animationState.travel("Run")
		velocity2D = velocity2D.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
# If the player isn't moving, they are set to be idle

	else:
		#moving = false
		animationState.travel("Idle")
		velocity2D = velocity2D.move_toward(Vector3.ZERO, FRICTION * delta)
	
	if(world.waterTile(position) == false):
		state = stateMachine.MOVE
		
	move()

func external_set_state(newState):
	if newState == "freeze":
		frozen = true
		state = stateMachine.FREEZE
	else:
		frozen = false
	if newState == "move":
		state = stateMachine.MOVE
	if newState == "roll":
		state = stateMachine.ROLL
	
func roll_state(delta):
	if(world.waterTile(position)):
		state = stateMachine.SWIM
		
	velocity2D = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func roll_animation_finished():
	velocity2D
	state = stateMachine.MOVE

func move():
	set_velocity(velocity2D)
	move_and_slide()
	velocity2D = velocity2D
	position.y = currFloor

# for when you enter a door to emit that signal

func entered_door():
	emit_signal("player_entering_door")

# Moves you to the correct location and direction for when you enter a room
	
func set_spawn(location, direction):
	animationTree.set("parameters/'Idle/blend_position", direction)
	animationTree.set("parameters/Run/blend_position", direction)
	animationTree.set("parameters/Roll/blend_position", direction)
	print(location)
	position = location
	
func camera_set():
	$Camera2D.current = true

"""func set_name(new_name):
	$Name.visible = true
	$Name.text = str(new_name)

func _on_networkTimer_timeout():
	if is_multiplayer_authority():
		rset_unreliable("puppet_pos", global_position)
		rset_unreliable("puppet_direction", animVector)
		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("moving", moving)
		rset_unreliable("puppet_animation", animationState.get_current_node())
		
func startTimer():
	$networkTimer.start()"""
