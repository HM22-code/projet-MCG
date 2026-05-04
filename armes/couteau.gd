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

# Signal émis quand le couteau touche une cible
signal hit_target(target: Node, damage: float)

func _ready():
	set_process(false)
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)

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

	# Sauvegarder la position globale AVANT le reparent
	var saved_pos: Vector3 = global_transform.origin

	# Détacher du joueur et attacher à la scène racine
	reparent(get_tree().root)
	global_transform.origin = saved_pos

	throw_velocity = direction.normalized() * throw_speed
	is_thrown = true

	# Activer la hitbox pendant le vol
	hitbox.monitoring = true
	hitbox.monitorable = true

	set_process(true)

func _process(delta: float):
	if not is_thrown:
		return

	# Mouvement + gravité simulés
	global_translate(throw_velocity * delta)
	throw_velocity.y -= throw_gravity * delta

	# Rotation sur l'axe de déplacement (effet visuel)
	rotate_object_local(Vector3.RIGHT, 10.0 * delta)

	# Atterrissage si le couteau touche le sol
	if global_transform.origin.y < 0.3:
		land()

func land():
	is_thrown = false
	throw_velocity = Vector3.ZERO  # IMPORTANT : reset de la vélocité
	set_process(false)
	hitbox.monitoring = false
	hitbox.monitorable = false
	# Optionnel : snap au sol
	var pos = global_transform.origin
	pos.y = 0.3
	global_transform.origin = pos

# Ramasser le couteau (à appeler depuis le joueur)
func pick_up(new_parent: Node):
	if is_thrown:
		return
	reparent(new_parent)
	position = Vector3.ZERO
	rotation = Vector3.ZERO

func _on_hitbox_body_entered(body: Node):
	if not is_attacking and not is_thrown:
		return
	_deal_damage(body)

func _on_hitbox_area_entered(area: Area3D):
	if not is_attacking and not is_thrown:
		return
	_deal_damage(area)

func _deal_damage(target: Node):
	if target == get_parent():  # Ne pas se blesser soi-même
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		hit_target.emit(target, attack_damage)
		if is_thrown:
			land()
