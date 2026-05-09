extends Player


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_animation()

func update_animation():
	if not is_on_floor():
		state_machine.travel("Fall")
	elif direction != Vector3.ZERO:
		if Input.is_action_pressed("haut"):
			state_machine.travel("Running")
		elif Input.is_action_pressed("bas"):
			state_machine.travel("RunningBack")
		elif Input.is_action_pressed("gauche"):
			state_machine.travel("RunningLeft")
		elif Input.is_action_pressed("droite"):
			state_machine.travel("RunningRight")
	else:
		state_machine.travel("Idle")
