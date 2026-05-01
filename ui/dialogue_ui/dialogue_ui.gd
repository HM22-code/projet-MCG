extends CanvasLayer

@onready var speaker_text: RichTextLabel = $Panel/Background/MarginContainer/VBoxContainer/HBoxContainer/SpeakerText
@onready var resp_container: VBoxContainer = $Panel/Background/MarginContainer/VBoxContainer/HBoxContainer/ResponsesBox
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var is_playing_dialogue = false

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

## Jouer audio à partir d'un texte
func speak(text: String):
	if is_playing_dialogue:
		return
	else:
		is_playing_dialogue = true
		for character in text:
			# Arrêt du son si arrêt dialogue
			if not is_playing_dialogue:
				audio_player.stop()
				return
			# Pause audio au espace vide
			if character == " ":
				await get_tree().create_timer(0.05).timeout
				continue
			# Modification du pitch du son
			audio_player.pitch_scale = randf_range(0.8, 1.4)
			if character in ["a", "e", "i", "o", "u"]:
				audio_player.pitch_scale += 0.2
			audio_player.play()
			await get_tree().create_timer(0.02).timeout
		is_playing_dialogue = false

## Action au signal question_started
func on_question_started(data: Dictionary):
	# Affichage texte
	var text = data["text"]
	speaker_text.text = text
	show_ui()
	speak(text)
	# Suppression des anciens bouttons
	for item in resp_container.get_children():
		item.queue_free()
	# Mélange des réponses
	var responses = data.get("responses", [])
	responses.shuffle()
	# Ajout des boutons de réponses
	for response in responses:
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
	if is_playing_dialogue == true:
		is_playing_dialogue = false

@warning_ignore("unused_parameter")
## Action au signal question_ended
func on_question_ended(total_score: int):
	GameData.add_score(total_score)
	hide_ui()
