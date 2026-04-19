extends Control

# Script pour charger les niveaux du dossier scènes dans une liste sélectable

var level_paths = []
@onready var item_list: ItemList = $VBoxContainer/LevelItemList

func _ready():
	_scan_levels("res://scenes/")

## Alimente ItemList de fichiers scènes (.tscn) à partir d'un dossier
func _scan_levels(folder: String):
	var dir = DirAccess.open(folder)
	if dir && item_list != null:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if dir.current_is_dir() and not file.begins_with("."):
				# recherche recursive dans les dossiers
				_scan_levels(folder + file + "/")
			elif file.ends_with(".tscn"):
				var full_path = folder + file
				level_paths.append(full_path)
				item_list.add_item(str(file.get_basename()), null, true)
			file = dir.get_next()
		dir.list_dir_end()

func _on_item_list_item_activated(index):
	get_tree().change_scene_to_file(level_paths[index])
