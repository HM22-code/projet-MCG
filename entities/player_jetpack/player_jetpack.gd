extends Player

const JETPACK_FORCE = 12.0
const JETPACK_FUEL_MAX = 100.0
const JETPACK_FUEL_DRAIN = 20.0
const JETPACK_FUEL_REGEN = 10.0

var jetpack_fuel = JETPACK_FUEL_MAX
var jetpack_active = false

@onready var fuel_bar: ProgressBar = $SpringArm3D/Camera3D/CanvasLayer/FuelProgressBar
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
	# Activation du jetpack
	var using_jetpack = Input.is_action_pressed("saut") and not is_on_floor() and jetpack_fuel > 0
	# Activation des particules
	if gpu_particles_3d:
		gpu_particles_3d.emitting = using_jetpack
	if using_jetpack:
		jetpack_active = true
		jetpack_fuel -= JETPACK_FUEL_DRAIN * delta
		jetpack_fuel = max(jetpack_fuel, 0.0)
		# Applique la poussée du jetpack
		velocity.y += JETPACK_FORCE * delta
		# Bornes de vitesse verticale
		velocity.y = clamp(velocity.y, -20.0, JETPACK_FORCE)
	else:
		jetpack_active = false
		# Gravité normal quand le jetpack n'est pas actif
		if not is_on_floor():
			velocity += get_gravity() * delta
	# Régénération fuel (énergie) du jetpack au sol
	if is_on_floor():
		jetpack_fuel += JETPACK_FUEL_REGEN * delta
		jetpack_fuel = min(jetpack_fuel, JETPACK_FUEL_MAX)
	# Mise à jour affichage pour le joueur
	# TODO : à modifier avec les signaux pour éviter une mis à jour à chaque frame
	update_hp_bar()
	update_fuel_bar()
	update_score_label()
	# Saut
	if Input.is_action_just_pressed("saut") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Mouvement horizontal
	var input_dir := Input.get_vector("gauche", "droite", "haut", "bas")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	
	move_and_slide()
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

## Retourne le pourcentage de fuel (énergie) du jetpack
func get_fuel_percent() -> float:
	return jetpack_fuel / JETPACK_FUEL_MAX

## Mise à jour affichage fuel (énergie) du jetpack
func update_fuel_bar():
	if not fuel_bar:
		return
	fuel_bar.value = jetpack_fuel
	var style = fuel_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if style:
		if jetpack_fuel > 60:
			style.bg_color = Color.GREEN
		elif jetpack_fuel > 25:
			style.bg_color = Color.ORANGE
		else:
			style.bg_color = Color.RED
