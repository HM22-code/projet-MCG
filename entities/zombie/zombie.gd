class_name  Zombie
extends CharacterBody3D

# propriétés constantes du zombie
const SPEED_CHASE   := 3.0    # vitesse de poursuite
const SPEED_WANDER  := 1.2    # vitesse de balade
var DETECT_RANGE  := 10.0   # distance à partir d'où le zombie poursuit le joueur
var LOSE_RANGE    := 14.0   # distance à partir d'où le zombie arrête de poursuivre le joueur
const WANDER_RADIUS := 6.0    # distance jusqu'où le zombie se balade à partir de son spawn
const WANDER_WAIT_MIN := 1.5  # secondes minimales où le zombie reste immobile avant de se balader
const WANDER_WAIT_MAX := 3.5  # secondes maximales où le zombie reste immobile avant de se balader
const ROTATION_SPEED  := 5.0  # vitesse de rotation
const ATTACK_RANGE    := 1.8  # distance à partir d'où le zombie attaque le joueur
const ATTACK_DAMAGE   := 10.0 # valeur d'attaque du zombie
const ACTIVE_RANGE := 50.0    # distance à partir d'où le zombie est actif
const SCORE_VALUE := 10        # valeur score zombie

# états 
enum State { IDLE, WANDER, CHASE, DYING }
var state: State = State.IDLE

# variables
var wander_origin   : Vector3      # position au début de la scène
var wander_timer    : float = 0.0  # temps de balade
var wander_wait     : float = 0.0  # temps d'attente
var is_waiting      : bool  = true # commence par attendre avant de se balader
var current_anim    : String = ""  # animation en cours

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_state : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# fonctions moteurs

func _ready() -> void:
	await get_tree().process_frame  # attend le process de chaque noeud
	player = get_tree().get_first_node_in_group("player")
	add_to_group("zombies")
	wander_origin = global_position
	_pick_wander_wait()  # attendre avant balade

func _physics_process(delta: float) -> void:
	# en action si le noeud player est présent
	if not is_instance_valid(player):
		return
	# en action si le zombie n'est pas trop éloigné du joueur
	if global_position.distance_to(player.global_position) > ACTIVE_RANGE:
		velocity = Vector3.ZERO
		return
	_update_state()
	_execute_state(delta)
	move_and_slide()

# logique des états

## mise à jour des états
func _update_state() -> void:
	var dist := global_position.distance_to(player.global_position)
	match state:
		State.IDLE, State.WANDER:
			if dist <= DETECT_RANGE:
				_enter_state(State.CHASE)
		State.CHASE:
			if dist > LOSE_RANGE:
				_enter_state(State.IDLE)

## exécution des états
func _execute_state(delta: float) -> void:
	match state:
		State.IDLE:
			_idle_behaviour(delta)
		State.WANDER:
			_wander_behaviour(delta)
		State.CHASE:
			_chase_behaviour(delta)
		State.DYING:
			_dying_behaviour()

## exécution une fois à l'entrée au changement d'état
func _enter_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE:
			anim_state.travel("Idle")
			velocity = Vector3.ZERO
			is_waiting = true
			_pick_wander_wait()
		State.WANDER:
			anim_state.travel("Walking")
			_pick_wander_destination()
		State.CHASE:
			anim_state.travel("Running")
		State.DYING:
			anim_state.travel("Dying")

# comportement des états

## Comportement lors de l'état Idle
func _idle_behaviour(delta: float) -> void:
	velocity = Vector3.ZERO
	wander_timer += delta
	if wander_timer >= wander_wait:
		_enter_state(State.WANDER)

## Comportement lors de l'état Wander
func _wander_behaviour(delta: float) -> void:
	if is_waiting:
		# reste immobile entre chaque pas
		anim_state.travel("Idle")
		velocity = Vector3.ZERO
		wander_timer += delta
		if wander_timer >= wander_wait:
			is_waiting = false
			_pick_wander_destination()
		return
	anim_state.travel("Walking")
	# bouge vers le prochain point de balade
	var next_point := nav_agent.get_next_path_position()
	velocity = (next_point - global_position).normalized() * SPEED_WANDER
	_update_rotation_toward_velocity(delta)
	# si arrivé au point de balade attend avant de choisir un nouveau point de balade
	if nav_agent.is_navigation_finished():
		is_waiting = true
		_pick_wander_wait()

## Comportement lors de l'état Chase
func _chase_behaviour(delta) -> void:
	var dist_player := global_position.distance_to(player.global_position)
	# attaque si le joueur est proche
	if dist_player <= ATTACK_RANGE:
		# active deal_damage si joué jusqu'à la bonne keyframe
		anim_state.travel("Attack")
		_update_rotation_toward_player(delta)
		return
	anim_state.travel("Running")
	nav_agent.set_target_position(player.global_position)
	var next_point := nav_agent.get_next_path_position()
	velocity = (next_point - global_position).normalized() * SPEED_CHASE
	_update_rotation_toward_player(delta)

## Comportement lors de l'état Dying
func _dying_behaviour() -> void:
	velocity = Vector3.ZERO

# fonctions utiles

## Lance l'état de mort
func die():
	collision_shape.disabled = true
	GameData.add_score(SCORE_VALUE)
	_enter_state(State.DYING)

## Supprime le zombie à la fin (keyframe) de l'animation Dying
func delete():
	queue_free()

## Inflige des dégats au joueur à l'impact (keyframe) de l'animation Attack
func deal_damage():
	player.take_damage(ATTACK_DAMAGE)

## Sélection aléatoire du prochain points de destination entre les déplacements
func _pick_wander_destination() -> void:
	var offset := Vector3(randf_range(-WANDER_RADIUS, WANDER_RADIUS), 0.0, randf_range(-WANDER_RADIUS, WANDER_RADIUS))
	nav_agent.set_target_position(wander_origin + offset)

## Sélection aléatoire du temps d'attente entre les déplacements
func _pick_wander_wait() -> void:
	wander_timer = 0.0
	wander_wait  = randf_range(WANDER_WAIT_MIN, WANDER_WAIT_MAX)

## Met à jour la rotation en direction du joueur
func _update_rotation_toward_player(delta: float) -> void:
	var dir := player.global_position - global_position
	dir.y = 0.0 # rotation sur l'axe y
	if dir.length_squared() < 0.01:
		return # ne pas tourner si angle trop petit
	var target_angle := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)

## Met à jour la rotation en direction du déplacement
func _update_rotation_toward_velocity(delta: float) -> void:
	if velocity.length_squared() < 0.01:
		return  # ne pas tourner si angle trop petit
	var target_angle := atan2(velocity.x, velocity.z)
	rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)

# fonctions utiles pour les animations

## Retourne le nom de l'état courant
func get_state_name() -> StringName:
	return State.keys()[state]

## Retourne si le zombie est mouvement
func is_moving() -> bool:
	return velocity.length_squared() > 0.01

func _on_area_3d_body_exited(_body: Node3D) -> void:
	self.set_collision_mask_value(3, true)
