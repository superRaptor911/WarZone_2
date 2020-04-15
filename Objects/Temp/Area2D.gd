extends Area2D

var is_mouse_inside = false
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_mouse_entered():
	is_mouse_inside = true


func _on_Area2D_mouse_exited():
	is_mouse_inside = false
	

func _process(delta):
	if is_mouse_inside and Input.is_mouse_button_pressed(1):
		selected = true
	if selected and not Input.is_mouse_button_pressed(1):
		selected = false
	if selected:
		position = get_global_mouse_position()
