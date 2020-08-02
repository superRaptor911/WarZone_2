extends "res://Objects/Models/Model.gd"


func setSkin(_s_name):
	pass

func rangedAttack():
	$skin/CPUParticles2D.emitting = true
	$AnimationPlayer.play("emit_acid")
