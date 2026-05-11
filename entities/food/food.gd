extends AnimatableBody3D

const AMPLITUDE = 0.2
const FREQUENCE = 8
const SCORE_VALUE = 10

var base_y: float
var time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_y = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	position.y = base_y + AMPLITUDE * sin(FREQUENCE * time_elapsed)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.heal_damage(20)
		if GameData:
			GameData.add_score(SCORE_VALUE)
		self.queue_free()
