extends CanvasLayer

@onready var score_label = $DeathPanel/VBoxContainer/Score
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeathPanel.visible = false 
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _toggle_death():
	$DeathPanel.visible = true
	score_label.text = "Dernier Score: " + str(GameData.score)
	# Permet d'afficher la souris en mode mort
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#fonctions des boutons
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")
