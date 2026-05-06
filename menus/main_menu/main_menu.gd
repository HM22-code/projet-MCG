extends Control

@onready var control_visible = false

func _ready():
	$Panel/BestScoreLabel.text = "Meilleur Score : " + str(GameData.best_score)
	$Panel/control.visible = false
	

func _on_start_button_pressed() -> void:
	# TODO : Changer vers niveau 1
	get_tree().change_scene_to_file("res://scenes/test.tscn")

func _on_options_button_pressed() -> void:
	pass # TODO : Changer vers menu options
	get_tree().change_scene_to_file("res://menus/options_menu/options_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_control_button_pressed() -> void:
	control_visible = not control_visible
	$Panel/control.visible = control_visible
