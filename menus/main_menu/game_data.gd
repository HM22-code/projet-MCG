extends Node

# Script pour charger et sauvegarder les données et configuration du jeu

const SAVE_PATH = "user://save_game_data.cfg"
var best_score: int = 0
var volume_musique: int = 100 #volume musique ambiance
var volume_effets: int = 100
var sensibilite: float = 1 #sensibilité du déplacement de la caméra
#Multiplié avec le déplacement, default = 1


func _ready():
	load_data()

func save_data():
	var config = ConfigFile.new()
	config.set_value("scores", "best_score", best_score)
	config.set_value("preferences", "musique_ambiance", volume_musique)
	config.set_value("preferences", "effets_sonores", volume_effets)
	config.set_value("preferences", "sensibilite_deplacement", sensibilite)
	config.save(SAVE_PATH)

func load_data():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = config.get_value("scores", "best_score", 0)
		volume_musique = config.get_value("preferences", "musique_ambiance", 100)
		volume_effets = config.get_value("preferences", "effets_sonores", 100)
		sensibilite = config.get_value("preferences", "sensibilite_deplacement", 1)
		

func submit_score(score: int):
	if score > best_score:
		best_score = score
		save_data()
		
func submit_musique_ambiance(volume: int):
	if (volume != volume_musique and 0 <= volume and volume <= 100):
		volume_musique = volume
		save_data()

func submit_effets_sonores(volume: int):
	if (volume !=  volume_effets and 0 <= volume and volume <= 100):
		volume_effets = volume_effets
		save_data()
		
func submit_sensibilite_deplacement(sensibilite_nouv: float):
	if (sensibilite_nouv != sensibilite and 0 < sensibilite_nouv and sensibilite_nouv < 10):
		sensibilite = sensibilite_nouv
		save_data()
