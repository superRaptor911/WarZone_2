extends CanvasLayer

signal teamSelected(selected_team)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_A_pressed():
	emit_signal("teamSelected","A")


func _on_B_pressed():
	emit_signal("teamSelected","B")

