extends "res://Objects/Bots/Zombie.gd"

var custom_model = preload("res://Objects/Models/bull_sqid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	model.queue_free()
	model = custom_model.instance()
	add_child(model)
	model.connect("zm_attk_finished", self, "on_attk_completed")
