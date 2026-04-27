extends "res://entities/player/player.gd"
#Profiter des méthodes de base

func _ready():
	super._ready() #Player readz
	var speed = 20.0
	var jump_velocity = 0 #Voiture peut pas sauter
