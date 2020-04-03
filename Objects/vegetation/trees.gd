extends Node2D


var wind_speed : float = 0.035
var max_rotaion : float = 1.0
var times_rotated : float = 0
var Sign = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	times_rotated += delta * Sign
	if times_rotated > 3.14 or times_rotated < 0:
		Sign *= -1
	rotation = interpolate_(-0.3,0.3,times_rotated)

func interpolate_(lval, uval, current_val) -> float:
	
	return lerp(lval,uval,sin(current_val))
	
