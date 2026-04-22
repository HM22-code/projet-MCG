extends Control

var game_data = preload("res://menus/main_menu/game_data.gd") #Pour enregistrer les preferences

## Aller dans le menu principal
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")

## Sauvegarder nouveau volume
func _on_music_ambiance_value_changed(value: int) -> void:
	GameData.submit_musique_ambiance(value)

## Sauvegarder nouveau volume
func _on_effets_sonores_value_changed(value: int) -> void:
	GameData.submit_effets_sonores(value)

## Sauvegarder nouveau sensibilite
func _on_sensibilite_value_changed(value: float) -> void:
	GameData.submit_sensibilite_deplacement(value)

##Sauvegarder nouveau luminosite
func _on_luminosite_value_changed(value: int) -> void:
	GameData.submit_luminosite(value)
