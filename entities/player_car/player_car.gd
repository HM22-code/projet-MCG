extends Player

const DELAI = 2 #véhicule n'est pas instanement en vitesse maximale
#ralentir dure également un peu de temp --> DELAI en secondes
var pointer_delai = 0
var last_direction : Vector3 = Vector3(0,0,0)
var front_angle = 60.0

var espacement_roues : float = 2.5
var ANGLE_ROTATION : float = TAU / 1

func _ready():
	#super._ready() #Player ready
	SPEED = 22
	JUMP_VELOCITY = 0 #Voiture ne peut pas sauter
	
func _physics_process(delta: float) -> void:
	# TODO : à modifier avec les signaux pour éviter une mis à jour à chaque frame
	update_score_label()
	update_hp_bar()
	
	var speed : float
	var angle_rotation : float = ANGLE_ROTATION * delta
	
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
		if pointer_delai > 0: #ralentir
			pointer_delai = clamp(pointer_delai - (delta / 2), 0, DELAI)
		var delai_factor = delai_func(pointer_delai)
		
		speed = SPEED * delai_factor #sans delta car appliquer déjà move and slide
		
		if last_direction and delai_factor > 0: #ralentissement
			velocity.x = last_direction.x * speed
			velocity.z = last_direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else :
		#delai au début 0, monte à 1 et reste jusqu'au ralentissement
		if Input.is_action_pressed("haut"): #accélerer
			pointer_delai = clamp(pointer_delai + delta, 0, DELAI)
		elif pointer_delai > 0: #ralentir
			pointer_delai = clamp(pointer_delai - delta, 0, DELAI)
		var delai_factor = delai_func(pointer_delai)
		
		speed = SPEED * delai_factor #sans delta car appliquer déjà move and slide
		
		# Mouvement horizontal
		var input_dir := Input.get_vector("gauche", "droite", "haut", "bas")

		var roue_avant : Vector3 = position + (-transform.basis.z) * espacement_roues/2
		var roue_arriere : Vector3 = position - (-transform.basis.z) * espacement_roues/2
		roue_arriere += (-transform.basis.z) * input_dir.y * speed
		roue_avant += (-transform.basis.z).rotated(Vector3(0,1,0), -input_dir.x * angle_rotation ) * speed
		var nouvelle_direction : Vector3 = (roue_avant - roue_arriere).normalized()
		
		velocity = nouvelle_direction * speed
		#var angleTemp : float = nouvelle_direction.signed_angle_to(Vector3.UP,Vector3(0,1,0))
		#transform.basis = transform.basis.rotated(Vector3(0,1,0), angleTemp ) 
		rotation.y = atan2(-nouvelle_direction.x,-nouvelle_direction.z)
		last_direction = -transform.basis.z
			
	move_and_slide()
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision and global_position.y >= -5:
			var hit = collision.get_collider()
			if hit.is_in_group("zombies") and is_front_hit(hit):
				hit.die() #tuer zombie
				pointer_delai = clamp(pointer_delai - 0.25, 0, DELAI) #ralentir voiture
				

## Fonction pour déterminer si la collision est à l'avant de la voiture
func is_front_hit(zombie: Node3D) -> bool:
	# Direction avant de la voiture
	var car_forward = -transform.basis.z
	# Direction de la voiture vers le zombie 
	var to_zombie = (zombie.global_position - global_position).normalized()
	# Angle entre l'avant de la voiture et le zombie
	var angle = rad_to_deg(car_forward.angle_to(to_zombie))
	return angle <= front_angle
	
func delai_func(x: float) -> float: #smoothstep-function
	var t = clamp(x / DELAI, 0.0, 1.0)
	return snapped(t * t * (3.0 - 2.0 * t), 0.01)



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "GridMap_detection" :
		if !self.get_collision_mask_value(3):
			self.set_collision_mask_value(3, true)
			print("on")
		elif global_position.y > 0.51:
			self.set_collision_mask_value(3, false)
			print("off")
	print(body.name)
