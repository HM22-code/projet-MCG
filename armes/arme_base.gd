## arme_base.gd
## Classe parente dont héritent couteau, hache, bâton, etc.
class_name ArmeBase
extends Node3D

# Paramètres communs (configurables dans l'Inspector)
@export var nom_arme: String = "Arme"
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 0.5
@export var can_throw: bool = false

# Références communes (chaque arme doit avoir ces nœuds)
@onready var hitbox: Area3D = $Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# État interne
var is_attacking: bool = false
signal hit_target(target: Node, damage: float)

func _ready():
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)

# ── À SURCHARGER dans les classes filles si besoin ──────────
func attack():
	if is_attacking:
		return
	is_attacking = true
	animation_player.play("attack")
	hitbox.monitoring = true
	hitbox.monitorable = true
	await animation_player.animation_finished
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false

# Appelé quand l'arme est équipée
func on_equip():
	visible = true

# Appelé quand l'arme est rangée
func on_unequip():
	visible = false
	is_attacking = false
	hitbox.monitoring = false
	hitbox.monitorable = false

func _on_hitbox_body_entered(body: Node):
	if not is_attacking:
		return
	_deal_damage(body)

func _deal_damage(target: Node):
	if target == get_parent():
		return
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		hit_target.emit(target, attack_damage)
