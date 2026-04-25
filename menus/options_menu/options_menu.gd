extends Control

var game_data = preload("res://menus/main_menu/game_data.gd") #Pour enregistrer les preferences

#Noeuds de la scène
var luminosite
var sensibilite
var effets_sonores
var musique_ambiance
#Affichage de données
var label_luminosite
var label_sensibilite
var label_effets
var label_ambiance

func _ready() -> void:
	#Récupérer les noeuds
	luminosite = get_node("Panel/VBoxContainer/HBoxContainer4/Luminosite")
	sensibilite = get_node("Panel/VBoxContainer/HBoxContainer3/Sensibilite")
	effets_sonores = get_node("Panel/VBoxContainer/HBoxContainer/EffetsSonores")
	musique_ambiance = get_node("Panel/VBoxContainer/HBoxContainer2/MusicAmbiance")
	#Mettre les préférences actuels en charge
	GameData.load_data()
	luminosite.set_value_no_signal(GameData.luminosite)
	set_slider_sensibilite(GameData.sensibilite)
	effets_sonores.set_value_no_signal(GameData.volume_effets)
	musique_ambiance.set_value_no_signal(GameData.volume_musique)
	
	#Actualiser affichage
	label_luminosite = get_node("Panel/VBoxContainer/HBoxContainer4/label_luminosite")
	label_sensibilite = get_node("Panel/VBoxContainer/HBoxContainer3/label_sensibilite")
	label_effets = get_node("Panel/VBoxContainer/HBoxContainer/label_effets")
	label_ambiance = get_node("Panel/VBoxContainer/HBoxContainer2/label_ambiance")
	label_luminosite.set_text(str(GameData.luminosite))
	label_sensibilite.set_text(str(GameData.sensibilite))
	label_effets.set_text(str(GameData.volume_effets))
	label_ambiance.set_text(str(GameData.volume_musique))

## Aller dans le menu principal
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")

## Sauvegarder nouveau volume
func _on_music_ambiance_value_changed(value: int) -> void:
	GameData.submit_musique_ambiance(value)
	label_ambiance.set_text(str(value))

## Sauvegarder nouveau volume
func _on_effets_sonores_value_changed(value: int) -> void:
	GameData.submit_effets_sonores(value)
	label_effets.set_text(str(value))

## Sauvegarder nouveau sensibilite
func _on_sensibilite_value_changed(value: float) -> void:
	#Recalculation entre 0 et 10
	if value != 0:
		value = value / 10 if value <= 10 else value - 10
	GameData.submit_sensibilite_deplacement(value)
	label_sensibilite.set_text(str(value))

##Sauvegarder nouveau luminosite
func _on_luminosite_value_changed(value: int) -> void:
	GameData.submit_luminosite(value)
	label_luminosite.set_text(str(value))

#save_data() trop coûteux pour value_changed
func _on_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameData.save_data()
		
func set_slider_sensibilite(value: float) -> void:
	#Recalculation entre 0 et 20
	#print(value)
	value = value * 10 if value <= 1 else value + 10
	sensibilite.set_value_no_signal(value)
