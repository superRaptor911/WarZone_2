extends Area2D

var speed : float   = 300
var max_range : int = 500
var penetration_ratio : float = 0.3

var direction : Vector2
var distance : float = 0


func _init(dir : Vector2):
	direction = dir


func _ready():
	_connectSignals()

func _connectSignals():
	pass

func _process(delta):
	position += speed * direction * delta
	distance += speed * delta

	if distance > max_range:
		queue_free()

