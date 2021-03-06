extends HSlider
func _ready():
	_on_damage_value_changed(value)

func _on_damage_value_changed(value):
	$value.text = String(value)
