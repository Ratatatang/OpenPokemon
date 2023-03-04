extends KinematicBody

puppet var puppet_pos
puppet var puppet_motion
puppet var puppet_animation

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true
	visible = true
	puppet_pos = global_translation
	puppet_motion = Vector3.ZERO
	puppet_animation = "Idle"

func _physics_process(delta):
	global_translation = puppet_pos
	
	animationTree.set("parameters/Idle/blend_position", puppet_motion)
	animationTree.set("parameters/Run/blend_position", puppet_motion)
	animationTree.set("parameters/Roll/blend_position", puppet_motion)
	
	animationState.travel(puppet_animation)

func set_name(new_name):
	$Name.text = str(new_name)
