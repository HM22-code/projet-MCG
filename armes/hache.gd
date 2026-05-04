## hache.gd
## Hérite de ArmeBase — attaque large en arc + lancer lent et puissant
extends ArmeBase

@export var throw_speed: float = 8.0       # Plus lente que le couteau
@export var throw_gravity: float = 12.0    # Tombe plus vite (plus lourde)
@export var throw_return: bool = false     # Futur : hache qui revient

var is_thrown: bool = false
var throw_velocity: Vector3 = Vector3.ZERO
var original_parent: Node = null

func _ready():
	super._ready()  # Appelle _ready() de ArmeBase
	nom_arme = "Hache"
	set_process(false)

# Surcharge : attaque en arc (animation + hitbox plus longue)
func attack():
	if is_attacking or is_thrown:
		return
	is_attacking = true
	animation_player.play("attack_arc")   # Animation propre à la hache
	hitbox.monitoring = true
	hitbox.monitorable = true
	# La hache garde la hitbox active plus longtemps (coup large)
	await get_tree().create_timer(0.4).timeout
	hitbox.monitoring = false
	hitbox.monitorable = false
	await animation_player.animation_finished
	is_attacking = false

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
	# La hache tourne sur elle-même (axe différent du couteau)
	rotate_object_local(Vector3.FORWARD, 8.0 * delta)
	if global_transform.origin.y < 0.3:
		_land()

func _land():
	is_thrown = false
	throw_velocity = Vector3.ZERO
	set_process(false)
	hitbox.monitoring = false
	hitbox.monitorable = false
	var pos = global_transform.origin
	pos.y = 0.3
	global_transform.origin = pos

func _deal_damage(target: Node):
	if target == get_parent():
		return
	if target.has_method("take_damage"):
		# La hache fait +50% de dégâts si lancée
		var dmg = attack_damage * (1.5 if is_thrown else 1.0)
		target.take_damage(dmg)
		hit_target.emit(target, dmg)
		if is_thrown:
			_land()
