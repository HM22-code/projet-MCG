extends Zombie

func _ready() -> void:
	super._ready() #avoir tous les actions normales
	#modifier quelques valeurs pour stage 1 car on est plus vite
	DETECT_RANGE  = 30.0   # distance à partir d'où le zombie poursuit le joueur
	LOSE_RANGE    = 35.0   # distance à partir d'où le zombie arrête de poursuivre le joueur
