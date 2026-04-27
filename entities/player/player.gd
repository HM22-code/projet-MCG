extends CharacterBody3D

const LIFE_POINTS_MAX = 100
var life_points = 100
var SPEED = 5.0 #valeurs différents dans classe enfant player_carS
var JUMP_VELOCITY = 4.5

@onready var score_label: Label = $Camera3D/CanvasLayer/ScoreLabel
@onready var life_bar: ProgressBar = $Camera3D/CanvasLayer/LifeBar

func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Mise à jour affichage pour le joueur
	update_score_label()
	update_life_bar()
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
		
## Mise à jour affichage barre de vie
func update_life_bar():
	if not life_bar:
		return
	life_bar.value = life_points #life points doit être modifié et toujours actuel
	var ratio = get_life_percent()
	var style = life_bar.get_theme_stylebox("fill").duplicate()
	if ratio > 0.5:
		style.bg_color = Color("#8b0000")   # Rouge sang — normal
	elif ratio > 0.25:
		style.bg_color = Color("#5a0000")   # Rouge très sombre — danger
	else:
		style.bg_color = Color("#2a0000")   # Presque noir — critique		
	life_bar.add_theme_stylebox_override("fill", style)
	
	
#prendre dégâts d'ennemies
func take_damage(damage: int):
	life_points = clamp(life_points - damage, 0, LIFE_POINTS_MAX)

## Retourne le percentage de points de la vie
func get_life_percent():
	return life_points / LIFE_POINTS_MAX




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
