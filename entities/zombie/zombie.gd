extends CharacterBody3D

# propriétés constantes du zombie
const SPEED_CHASE   := 3.0    # vitesse de poursuite
const SPEED_WANDER  := 1.2    # vitesse de balade
const DETECT_RANGE  := 10.0   # distance à partir d'où le zombie poursuit le joueur
const LOSE_RANGE    := 14.0   # distance à partir d'où le zombie arrête de poursuivre le joueur
const WANDER_RADIUS := 6.0    # jusqu'où le zombie se balade à partir de son spawn
const WANDER_WAIT_MIN := 1.5  # Secondes minimales où le zombie reste immobile avant de se balader
const WANDER_WAIT_MAX := 3.5  # Secondes maximales où le zombie reste immobile avant de se balader

# états 
enum State { IDLE, WANDER, CHASE }
var state: State = State.IDLE

# variables
var wander_origin   : Vector3   # position au début de la scène
var wander_timer    : float = 0.0
var wander_wait     : float = 0.0
var is_waiting      : bool  = true   # commence par attendre avant de se balader



@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

# fonctions moteurs

func _ready() -> void:
	await get_tree().process_frame  # attend le process de chaque noeud
	player = get_tree().get_first_node_in_group("player")
	wander_origin = global_position
	_pick_wander_wait()  # attendre avant balade

func _physics_process(delta: float) -> void:
	# en action si le noeud player est présent
	if not is_instance_valid(player):
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
			_chase_behaviour()


## exécution une fois à l'entrée au changement d'état
func _enter_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE:
			velocity = Vector3.ZERO
			is_waiting = true
			_pick_wander_wait()

		State.WANDER:
			_pick_wander_destination()

		State.CHASE:
			pass   # pas de changement en entrée


# comportement des états

func _idle_behaviour(delta: float) -> void:
	velocity = Vector3.ZERO
	wander_timer += delta
	if wander_timer >= wander_wait:
		_enter_state(State.WANDER)


func _wander_behaviour(delta: float) -> void:
	if is_waiting:
		# reste immobile entre chaque pas
		velocity = Vector3.ZERO
		wander_timer += delta
		if wander_timer >= wander_wait:
			is_waiting = false
			_pick_wander_destination()
		return

	# bouge vers le prochain point de balade
	var next_point := nav_agent.get_next_path_position()
	velocity = (next_point - global_position).normalized() * SPEED_WANDER

	# si arrivé au point de balade attend avant de choisir un nouveau point de balade
	if nav_agent.is_navigation_finished():
		is_waiting = true
		_pick_wander_wait()


func _chase_behaviour() -> void:
	nav_agent.set_target_position(player.global_position)
	var next_point := nav_agent.get_next_path_position()
	velocity = (next_point - global_position).normalized() * SPEED_CHASE


# fonctions utiles

func _pick_wander_destination() -> void:
	var offset := Vector3(
		randf_range(-WANDER_RADIUS, WANDER_RADIUS),
		0.0,
		randf_range(-WANDER_RADIUS, WANDER_RADIUS)
	)
	nav_agent.set_target_position(wander_origin + offset)


func _pick_wander_wait() -> void:
	wander_timer = 0.0
	wander_wait  = randf_range(WANDER_WAIT_MIN, WANDER_WAIT_MAX)


# fonctions utiles pour les animations

## Retourne le nom de l'état courant
func get_state_name() -> StringName:
	return State.keys()[state]

## Retourne si le zombie est mouvement
func is_moving() -> bool:
	return velocity.length_squared() > 0.01
