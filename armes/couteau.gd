extends Node3D

# Références aux nœuds
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var hitbox: Area3D = $Hitbox
@onready var collision_shape: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Paramètres du couteau
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 0.5
@export var throw_speed: float = 15.0
@export var throw_gravity: float = 9.8
@export var can_throw: bool = true

# État interne
var is_attacking: bool = false
var is_thrown: bool = false
var throw_velocity: Vector3 = Vector3.ZERO
var original_parent: Node = null

# Attaque en courant
var running_attack_active: bool = false
var running_attack_timer: Timer

# Signal émis quand le couteau touche une cible
signal hit_target(target: Node, damage: float)

func _ready():
	set_process(false)
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	# Création du timer pour l'attaque en courant
	running_attack_timer = Timer.new()
	running_attack_timer.one_shot = true
	running_attack_timer.timeout.connect(_disable_running_attack)
	add_child(running_attack_timer)

# Active la hitbox pendant la course (appelé par le joueur)
func enable_running_attack():
	if is_attacking or is_thrown:
		return
	if running_attack_active:
		return
	running_attack_active = true
	hitbox.monitoring = true
	hitbox.monitorable = true
	running_attack_timer.start(0.2)  # durée du mouvement de bras

func _disable_running_attack():
	running_attack_active = false
	if not is_attacking and not is_thrown:
		hitbox.monitoring = false
		hitbox.monitorable = false

# Attaque au corps à corps
func attack():
	if is_attacking or is_thrown:
		return
	is_attacking = true
	animation_player.play("attack")
	hitbox.monitoring = true
	hitbox.monitorable = true
	await animation_player.animation_finished
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false

# Lancer le couteau
func throw_from(direction: Vector3):
	if not can_throw or is_thrown:
		return

	original_parent = get_parent()

	var saved_pos: Vector3 = global_transform.origin

	reparent(get_tree().root)
	global_transform.origin = saved_pos

	throw_velocity = direction.normalized() * throw_speed
	is_thrown = true

	hitbox.monitoring = true
	hitbox.monitorable = true

	set_process(true)

func _process(delta: float):
	if not is_thrown:
		return

	global_translate(throw_velocity * delta)
	throw_velocity.y -= throw_gravity * delta

	rotate_object_local(Vector3.RIGHT, 10.0 * delta)

	if global_transform.origin.y < 0.3:
		land()

func land():
	is_thrown = false
	throw_velocity = Vector3.ZERO
	set_process(false)
	hitbox.monitoring = false
	hitbox.monitorable = false
	var pos = global_transform.origin
	pos.y = 0.3
	global_transform.origin = pos

# Ramasser le couteau
func pick_up(new_parent: Node):
	if is_thrown:
		return
	reparent(new_parent)
	position = Vector3.ZERO
	rotation = Vector3.ZERO

func _on_hitbox_body_entered(body: Node):
	if not (is_attacking or is_thrown or running_attack_active):
		return
	_deal_damage(body)

func _on_hitbox_area_entered(area: Area3D):
	if not (is_attacking or is_thrown or running_attack_active):
		return
	_deal_damage(area)

func _deal_damage(target: Node):
	if target.is_in_group("player"):
		return
	if target == get_parent():
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		hit_target.emit(target, attack_damage)
		if is_thrown:
			land()
