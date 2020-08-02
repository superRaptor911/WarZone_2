extends "res://Objects/Models/Model.gd"

onready var cannon_1 = $skin/CPUParticles2D
onready var cannon_2 = $skin/CPUParticles2D2

func setSkin(_s_name):
	pass

func rangedAttack():
	cannon_1.emitting = true
	cannon_2.emitting = true
	
