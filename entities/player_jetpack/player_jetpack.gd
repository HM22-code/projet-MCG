extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const JETPACK_FORCE = 12.0
const JETPACK_FUEL_MAX = 100.0
const JETPACK_FUEL_DRAIN = 20.0
const JETPACK_FUEL_REGEN = 10.0

var jetpack_fuel = 100.0
var jetpack_active = false

@onready var progress_bar: ProgressBar = $Camera3D/CanvasLayer/FuelProgressBar
@onready var gpu_particles_3d: GPUParticles3D = $MeshInstance3D2/GPUParticles3D
@onready var score_label: Label = $Camera3D/CanvasLayer/ScoreLabel

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")

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
	update_fuel_bar()
	update_score_label()
	# Saut
	if Input.is_action_just_pressed("saut") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Mouvement horizontal
	var input_dir := Input.get_vector("gauche", "droite", "haut", "bas")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

## Retourne le pourcentage de fuel (énergie) du jetpack
func get_fuel_percent() -> float:
	return jetpack_fuel / JETPACK_FUEL_MAX

## Mise à jour affichage fuel (énergie) du jetpack
func update_fuel_bar():
	if not progress_bar:
		return
	progress_bar.value = jetpack_fuel
	var style = progress_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if style:
		if jetpack_fuel > 60:
			style.bg_color = Color.GREEN
		elif jetpack_fuel > 25:
			style.bg_color = Color.ORANGE
		else:
			style.bg_color = Color.RED

## Mise à jour affichage score
func update_score_label():
		score_label.text = "Score : " + str(GameData.get_score())


# fonctions mouvement caméra à la souris

var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input :
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		transform.basis = transform.basis.rotated(Vector3(0,1,0), _rotation_input)

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var MOUSE_SENSITIVITY : float = 0.005 

func _update_camera(delta):
	
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0
