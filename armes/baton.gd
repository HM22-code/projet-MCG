## baton.gd
## Hérite de ArmeBase — longue portée + attaque chargée
extends ArmeBase

@export var charge_damage_multiplier: float = 2.5  # Dégâts si attaque chargée
@export var charge_time: float = 1.0               # Durée pour charger

var is_charging: bool = false
var charge_timer: float = 0.0
var charge_ready: bool = false

func _ready():
	super._ready()
	nom_arme = "Bâton"
	set_process(false)

# Surcharge : attaque rapide normale
func attack():
	if is_attacking or is_charging:
		return
	is_attacking = true
	animation_player.play("attack_sweep")  # Animation balayage
	hitbox.monitoring = true
	hitbox.monitorable = true
	await animation_player.animation_finished
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false

# Attaque chargée (appelée depuis joueur.gd avec hold)
func start_charge():
	if is_attacking or is_charging:
		return
	is_charging = true
	charge_timer = 0.0
	charge_ready = false
	animation_player.play("charge")        # Animation de charge
	set_process(true)

func release_charge():
	if not is_charging:
		return
	is_charging = false
	set_process(false)
	if charge_ready:
		_attack_charged()
	else:
		# Charge annulée, pas d'attaque
		animation_player.stop()

func _attack_charged():
	is_attacking = true
	animation_player.play("attack_charged")
	hitbox.monitoring = true
	hitbox.monitorable = true
	# Stocker le multiplicateur temporairement
	var original_damage = attack_damage
	attack_damage *= charge_damage_multiplier
	await animation_player.animation_finished
	attack_damage = original_damage         # Restaurer
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false

func _process(delta: float):
	if not is_charging:
		return
	charge_timer += delta
	if charge_timer >= charge_time and not charge_ready:
		charge_ready = true
		# Feedback visuel : effet brillant (à connecter dans la scène)
		print("Bâton chargé ! Relâchez pour frapper fort.")

func on_unequip():
	super.on_unequip()
	# Annuler la charge si on change d'arme
	if is_charging:
		is_charging = false
		charge_ready = false
		set_process(false)
