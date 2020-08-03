extends "res://Objects/Models/Model.gd"


func _ready():
	if not game_states.game_settings.particle_effects:
		$skin/CPUParticles2D2.emitting = false

func setSkin(_s_name):
	pass

func rangedAttack():
	if game_states.game_settings.particle_effects:
		$skin/CPUParticles2D.emitting = true
	$AnimationPlayer.play("emit_acid")
