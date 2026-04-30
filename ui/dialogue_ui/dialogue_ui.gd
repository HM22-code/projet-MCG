extends CanvasLayer

@onready var speaker_text: RichTextLabel = $Panel/Background/MarginContainer/VBoxContainer/HBoxContainer/SpeakerText
@onready var resp_container: VBoxContainer = $Panel/Background/MarginContainer/VBoxContainer/HBoxContainer/ResponsesBox


func _ready() -> void:
	# Menu actif en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Connexion aux signaux du DialogManager
	DialogueManager.question_started.connect(on_question_started)
	DialogueManager.answer_given.connect(on_answer_given)
	DialogueManager.question_ended.connect(on_question_ended)
	# Cacher le menu au départ
	$Panel.visible = false
	hide()

## Afficher le menu avec pause du jeu
func show_ui():
	$Panel.visible = true
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Cacher le menu avec pause du jeu
func hide_ui():
	$Panel.visible = false
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Action au signal question_started
func on_question_started(data: Dictionary):
	speaker_text.text = data["text"]
	show_ui()
	# Suppression des anciens bouttons
	for item in resp_container.get_children():
		item.queue_free()
	# Ajout des boutons de réponses
	for response in data.get("responses", []):
		var btn = Button.new()
		btn.text = response["text"]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): action_response(response, btn))
		resp_container.add_child(btn)

@warning_ignore("unused_parameter")
## Action des boutons réponse
func action_response(rep: Dictionary, btn: Button):
	for item in resp_container.get_children():
		item.disabled = true
	DialogueManager.answer(rep)

@warning_ignore("unused_parameter")
## Action au signal answer_given
func on_answer_given(points: int):
	pass

@warning_ignore("unused_parameter")
## Action au signal question_ended
func on_question_ended(total_score: int):
	GameData.add_score(total_score)
	hide_ui()
