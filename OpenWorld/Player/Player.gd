extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 550
const ROLL_SPEED = 110

signal player_entering_door

var frozen = false

var currentObject = ""

enum stateMachine{
	MOVE,
	ROLL,
	FREEZE
}

var state = stateMachine.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true
	visible = true
	
# Matches the state machine to the correct state

func _process(delta):
	if(frozen == true):
		state = stateMachine.FREEZE
	match state:
		stateMachine.MOVE:	
			move_state(delta)
		
		stateMachine.ROLL:
			roll_state(delta)
			
		stateMachine.FREEZE:
			freeze_state(delta)
			
	if Input.is_action_just_pressed("Interact"):
		if($Camera2D/DialogBox.visible != true):
			if($PlayerInteractionBox.get_overlapping_areas() != []):
				if($Camera2D/DialogBox.visible == false):
					var dialog = $PlayerInteractionBox.get_overlapping_areas()[0].interact()
					$Camera2D/DialogBox.start(dialog)
					frozen = true
			
# Used for when you move into a door so you can't move. you don't have to unfreeze as this
# player is cleared after they walk into a door 
			
func freeze_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Idle")
	
# State that sets all the animations to the input, and is used when moving

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
# If the player isn't moving, they are set to be idle

	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if Input.is_action_just_pressed("Roll"):
		state = stateMachine.ROLL
		
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
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func roll_animation_finished():
	velocity
	state = stateMachine.MOVE

func move():
	velocity = move_and_slide(velocity)

# for when you enter a door to emit that signal

func entered_door():
	emit_signal("player_entering_door")
	
# takes the door you touched and calls its enter door function
	
func _on_DoorBox_area_entered(area):
	frozen = true
	state = stateMachine.FREEZE
	animationPlayer.play("disappear")
	$Camera2D.clear_current()
	area.enter_door()

# Moves you to the correct location and direction for when you enter a room
	
func set_spawn(location, direction):
	animationTree.set("parameters/Idle/blend_position", direction)
	animationTree.set("parameters/Run/blend_position", direction)
	animationTree.set("parameters/Roll/blend_position", direction)
	print(location)
	position = location
	
	
func camera_set():
	$Camera2D.current = true

