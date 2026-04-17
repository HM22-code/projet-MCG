extends Node3D

@export var scene_zombie : PackedScene
@onready var gridmap = get_node("../GridMap")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cells = gridmap.get_used_cells()
	
	if cells.size() > 0 :
	
		for c in cells :
			var library_item = gridmap.get_cell_item(c)
			if library_item == 4 :
				spawn_zombie(c)
		

func spawn_zombie(coord: Vector3i):
	var world_pos = gridmap.map_to_local(coord)
	world_pos = gridmap.to_global(world_pos)
	
	var zombie = scene_zombie.instantiate()
	add_child(zombie)
	zombie.global_position = world_pos
	
