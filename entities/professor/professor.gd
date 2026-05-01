extends AnimatableBody3D

const ROTATION_SPEED: float = 2.0

var dialogues: Array[String]
var speaker_name: String
var player_nearby: bool = false
var dialogue_finished: bool = false

@onready var indicator: Node3D = $Indicator
@onready var animation_player: AnimationPlayer = $Prof/AnimationPlayer

func _ready() -> void:
	DialogueManager.question_ended.connect(_on_question_ended)
	animation_player.play("Idle")

func _process(delta: float) -> void:
	indicator.rotate_y(ROTATION_SPEED * delta)

@warning_ignore("unused_parameter")
## Action au signal question_ended
func _on_question_ended(total_score: int, npc: Node):
	if npc == self:
		dialogue_finished = true

## Interaction pour déclencher le dialogue
func _unhandled_input(event):
	if player_nearby and event.is_action_pressed("interagir"): 
		if not dialogue_finished:
			DialogueManager.start_quiz("start", self)
		else:
			DialogueManager.start_quiz("end", self)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		indicator.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		indicator.hide()
