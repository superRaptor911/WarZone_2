extends CanvasLayer
var user = null
func _ready():
	$joy1.connect("move",self,"_on_joy1_move")

func _on_joy1_move(val):
	if user == null:
		return
	val *= 1/max(abs(val.x),abs(val.y))
	user.movement_vector = val
	user.rotation = val.angle() + 1.57
	user.rpc("sync_vars",user.movement_vector,user.rotation,user.position)