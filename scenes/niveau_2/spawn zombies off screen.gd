extends Node3D

@onready var is_on_screen : bool = true

@export var scene_zombie : PackedScene

@onready var timer = get_node("../Timer")
@onready var notifier = get_node("VisibleOnScreenNotifier3D")

@onready var zombie_count : int = 0
@onready var max_zombie_count : int = 5

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	notifier.screen_entered.connect(_on_visible_on_screen_notifier_3d_screen_entered)
	notifier.screen_exited.connect(_on_visible_on_screen_notifier_3d_screen_exited)
	
	#spawn a few zombies so that the room doesn't start empty
	for n:int in 1:
		spawn_zombie()

func spawn_zombie():
	if zombie_count < max_zombie_count :
		var zombie = scene_zombie.instantiate()
		add_child(zombie)
		var offset = Vector3(randf_range(-1.0, 1.0),0, randf_range(-1.0, 1.0))
		zombie.global_position = global_position + offset
		
		zombie_count += 1

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	is_on_screen = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	is_on_screen = false

func _on_timer_timeout() -> void:
	if ! is_on_screen :
		spawn_zombie()
