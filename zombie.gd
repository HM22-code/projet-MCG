extends CharacterBody3D

const speed = 3.0
@onready var player = get_node("/root/test/player")
@onready var nav_agent = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	# Recherche du nouveau chemin de nav en fonction de la position de player
	nav_agent.set_target_position(player.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * speed

	move_and_slide()
