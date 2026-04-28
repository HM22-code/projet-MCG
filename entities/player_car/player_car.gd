extends Player

const DELAI = 3
var pointer_delai = 0

func _ready():
	super._ready() #Player ready
	SPEED = 20.0
	JUMP_VELOCITY = 0 #Voiture ne peut pas sauter
	
func _physics_process(delta: float) -> void:
	# Mouvement horizontal
	var input_dir := Input.get_vector("gauche", "droite", "haut", "bas")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		pointer_delai = clamp(pointer_delai + delta, 0, DELAI)
		velocity.x = direction.x * SPEED * delai_func(pointer_delai)
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func delai_func(x: float) -> float: #smoothstep-function
	var t = clamp(x / DELAI, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
