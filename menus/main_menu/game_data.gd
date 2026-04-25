extends Node

# Script pour charger et sauvegarder les données et configuration du jeu

const SAVE_PATH = "user://save_game_data.cfg"
var best_score: int = 0
var score: int = 0
var volume_musique: int = 100 # volume musique ambiance
var volume_effets: int = 100
var sensibilite: float = 1 # déplacement de la caméra, multiplié avec le déplacement, default = 1
var luminosite: int = 100

func _ready():
	load_data()

## Sauvegarde des données du jeu à sauvegarder dans un fichier
func save_data():
	var config = ConfigFile.new()
	config.set_value("scores", "best_score", best_score)
	config.set_value("preferences", "musique_ambiance", volume_musique)
	config.set_value("preferences", "effets_sonores", volume_effets)
	config.set_value("preferences", "sensibilite_deplacement", sensibilite)
	config.set_value("preferences", "luminosite", luminosite)
	config.save(SAVE_PATH)
	#print("Enregistré")

## Chargement des données du jeu sauvegardées à partir d'un fichier
func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = config.get_value("scores", "best_score", 0)
		volume_musique = config.get_value("preferences", "musique_ambiance", 100)
		volume_effets = config.get_value("preferences", "effets_sonores", 100)
		sensibilite = config.get_value("preferences", "sensibilite_deplacement", 1)
		luminosite = config.get_value("preferences", "luminosite", 100)

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

## Sauvegarde niveau volume musique ambiante
func submit_musique_ambiance(volume: int):
	if (volume != volume_musique and 0 <= volume and volume <= 100):
		volume_musique = volume

## Sauvegarde niveau volume effets sonores
func submit_effets_sonores(volume: int):
	if (volume !=  volume_effets and 0 <= volume and volume <= 100):
		volume_effets = volume

## Sauvegarde sensibilité souris caméra
func submit_sensibilite_deplacement(sensibilite_nouv: float):
	if (sensibilite_nouv != sensibilite and 0 <= sensibilite_nouv and sensibilite_nouv <= 10):
		sensibilite = sensibilite_nouv

## Sauvegarde niveau de luminosité
func submit_luminosite(value: int):
	if (value != luminosite and 0 <= value and value <= 100):
		luminosite = value
