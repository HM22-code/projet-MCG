extends CanvasLayer

func _ready() -> void:
	$PausePanel.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused     = paused
	$PausePanel.visible   = paused
	# Permet d'afficher la souris en mode pause
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# fonctions des boutons

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

# TODO : si on souhaite faire un bouton pour revenir au menu principal
# func _on_main_menu_pressed() -> void:
# 	get_tree().paused = false
# 	get_tree().change_scene_to_file("res://.../main_menu.tscn")
