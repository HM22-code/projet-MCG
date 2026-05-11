extends Player


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

@onready var couteau = find_child("Couteau", true, false)
var running_attack_cooldown: float = 0.0

func _process(delta):
	if running_attack_cooldown > 0:
		running_attack_cooldown -= delta
		
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
	var current_anim = state_machine.get_current_node()
	var is_running = current_anim in ["Running", "RunningBack", "RunningLeft", "RunningRight"]
	if is_running and running_attack_cooldown <= 0:
		couteau.enable_running_attack()   # bien "couteau" et non "knife"
		running_attack_cooldown = 0.4
		
func _on_finish_area_entered(body: Node3D):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/niveau_3/stage_32.tscn")
