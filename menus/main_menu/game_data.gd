extends Node

# Script pour charger et sauvegarder les données et configuration du jeu

const SAVE_PATH = "user://save_game_data.cfg"
var best_score: int = 0

func _ready():
	load_data()

func save_data():
	var config = ConfigFile.new()
	config.set_value("scores", "best_score", best_score)
	config.save(SAVE_PATH)

func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = config.get_value("scores", "best_score", 0)

func submit_score(score: int):
	if score > best_score:
		best_score = score
		save_data()
