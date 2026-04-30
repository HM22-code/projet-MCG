extends Node

signal question_started(data: Dictionary)
signal answer_given(points: int)
signal question_ended(total_score: int)

const QUESTION_NUMBER = 3

var questions: Dictionary = {}
var questions_size: int
var questions_selected: Array
var current_node: String = ""
var total_score: int = 0

func _ready():
	var file = FileAccess.open("res://ui/dialogue_ui/dialogue_data.json", FileAccess.READ)
	questions = JSON.parse_string(file.get_as_text())
	questions_size = questions.size() - 2

## Démarrage dialogue avec questions
func start_quiz(start_node: String):
	total_score = 0
	current_node = start_node
	if  start_node == "end":
		questions_selected.append("stop")
	else:
		select_questions()
	emit_signal("question_started", questions[start_node])

## Sélection de questions aléatoires différentes
func select_questions():
	var s = questions_selected.size()
	while s <= (QUESTION_NUMBER - 1):
		var id: String = str(randi_range(1,questions_size))
		if not(questions_selected.has(id)):
			questions_selected.append(id)
		s = questions_selected.size()
	questions_selected.append("end")
	questions_selected.append("stop")

## Calcul score question et redirection prochaine question
func answer(response: Dictionary):
	var pts = response.get("points", 0)
	var next = questions_selected.pop_front()
	total_score += pts
	emit_signal("answer_given", pts)
	await get_tree().create_timer(0.3).timeout
	if next == null:
		go_to("stop")
	else:
		go_to(next)

## Redirection prochaine question ou fin dialogue si "stop"
func go_to(node_id: String):
	if node_id == "stop" or not questions.has(node_id):
		emit_signal("question_ended", total_score)
		return
	if questions[node_id]["responses"].is_empty():
		emit_signal("question_ended", total_score)
		return
	current_node = node_id
	emit_signal("question_started", questions[node_id])
