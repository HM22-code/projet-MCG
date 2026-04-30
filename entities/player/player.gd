class_name Player
extends CharacterBody3D

const HP_MAX = 100.0

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var GRAVITY = 20.0

var hp = HP_MAX

@onready var score_label: Label = $Camera3D/CanvasLayer/ScoreLabel
@onready var hp_bar: ProgressBar = $Camera3D/CanvasLayer/HPProgressBar

func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	# Mise à jour affichage pour le joueur
	# TODO : à modifier avec les signaux pour éviter une mis à jour à chaque frame
	
	update_score_label()
	update_hp_bar()
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


## Mise à jour affichage score
func update_score_label():
		score_label.text = "Score : " + str(GameData.get_score())
		

## Mise à jour barre de vie
func update_hp_bar():
	if not hp_bar:
		return
	hp_bar.value = hp

## Le joueur prend des dégâts
func take_damage(amount: int):
	hp = max(0, hp - amount)
	if hp <= 0:
		# TODO : Game over
		print("Game over")

# fonctions mouvement caméra à la souris

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")

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
