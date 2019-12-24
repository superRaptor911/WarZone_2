extends Sprite


func _ready():
	if not game_states.game_settings.lighting_effects:
		queue_free()

