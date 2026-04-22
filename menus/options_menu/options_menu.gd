extends Control
var game_data = preload("res://menus/main_menu/game_data.gd") #Pour enregistrer les preferences

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	# Aller dans le menu principal
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_music_ambiance_value_changed(value: int) -> void:
	#Sauvegarder nouveau volume
	GameData.submit_musique_ambiance(value)


func _on_effets_sonores_value_changed(value: int) -> void:
	#Sauvegarder nouveau volume
	GameData.submit_effets_sonores(value)


func _on_sensibilite_value_changed(value: float) -> void:
	#Sauvegarder nouveau sensibilite
	GameData.submit_sensibilite_deplacement(value)


func _on_luminosite_value_changed(value: int) -> void:
	GameData.sublit_luminosite(value)
