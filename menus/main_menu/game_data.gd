extends Node

# Script pour charger et sauvegarder les données et configuration du jeu

const SAVE_PATH = "user://save_game_data.cfg"
var best_score: int = 0
var score: int = 0

func _ready():
	load_data()

## Sauvegarde des données du jeu à sauvegarder dans un fichier
func save_data():
	var config = ConfigFile.new()
	config.set_value("scores", "best_score", best_score)
	config.save(SAVE_PATH)

## Chargement des données du jeu sauvegardées à partir d'un fichier
func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = config.get_value("scores", "best_score", 0)

## Intialise le score en début de partie
func init_score():
	score = 0

## Ajout score
func add_score(amount: int):
	score += amount

## Retourne le score
func get_score() -> int:
	return score

## Sauvegarde du score final en fin de partie si le score est plus élévé que le score record
func submit_score(final_score: int):
	if final_score > best_score:
		best_score = final_score
		save_data()
