extends "res://entities/player/player.gd"
#Profiter des méthodes de base

func _ready():
	super._ready() #Player readz
	SPEED = 20.0
	JUMP_VELOCITY = 0 #Voiture peut pas sauter
