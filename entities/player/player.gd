class_name Player
extends CharacterBody3D


const HP_MAX = 100.0

var SPEED = 5.0 * 60
var JUMP_VELOCITY = 4.5
var hp = HP_MAX
var direction = Vector3.ZERO

@onready var score_label: Label = $SpringArm3D/Camera3D/CanvasLayer/ScoreLabel
@onready var hp_bar: ProgressBar = $SpringArm3D/Camera3D/CanvasLayer/HPProgressBar
#pour afficher après le mort
@onready var death_screen = get_node("../DeathScreen")


func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Mise à jour affichage pour le joueur
	# TODO : à modifier avec les signaux pour éviter une mis à jour à chaque frame
	update_score_label()
	update_hp_bar()
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
	
	for i:int in get_slide_collision_count() :
		var c : KinematicCollision3D = get_slide_collision(i)
		if c.get_collider() is RigidBody3D :
			c.get_collider().apply_central_impulse(-c.get_normal() * 0.5)
			
	

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
		# Game over
		death_screen._toggle_death()
		GameData.submit_score(GameData.get_score()) #sauvegarder score si le meilleur
		GameData.init_score() #reset le score

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
