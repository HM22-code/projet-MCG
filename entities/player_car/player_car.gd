extends Player

const DELAI = 5 #véhicule n'est pas instanement en vitesse maximale
#ralentir dure également un peu de temp
var pointer_delai = 0
var last_direction

func _ready():
	super._ready() #Player ready
	SPEED = 20.0
	JUMP_VELOCITY = 0 #Voiture ne peut pas sauter
	
func _physics_process(delta: float) -> void:
	# TODO : à modifier avec les signaux pour éviter une mis à jour à chaque frame
	update_score_label()
	update_hp_bar()
	
	#delai au début 0, monte à 1 et reste jusqu'au ralentissement
	if Input.is_action_pressed("haut"): #accélerer
		pointer_delai = clamp(pointer_delai + delta, 0, DELAI)
	elif pointer_delai > 0: #ralentir
		pointer_delai = clamp(pointer_delai - delta * 2, 0, DELAI)
	var delai_factor = delai_func(pointer_delai)
	print(delai_factor)
	#print(last_direction)
	
	# Mouvement horizontal
	var input_dir := Input.get_vector("gauche", "droite", "haut", "bas")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction: #mouvement normale + accéleration
		last_direction = direction
		velocity.x = direction.x * SPEED * delai_factor
		velocity.z = direction.z * SPEED * delai_factor
	elif last_direction and delai_factor > 0: #ralentissement
		velocity.x = direction.x * SPEED * delai_factor
		velocity.z = direction.z * SPEED * delai_factor
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delai_factor)
		velocity.z = move_toward(velocity.z, 0, SPEED * delai_factor)
	move_and_slide()
	
	
func delai_func(x: float) -> float: #smoothstep-function
	var t = clamp(x / DELAI, 0.0, 1.0)
	return snapped(t * t * (3.0 - 2.0 * t), 0.01)
