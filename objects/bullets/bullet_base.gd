extends Area2D

var speed : float   = 300
var max_range : int = 500
var damage : float  = 100
var penetration_ratio : float = 0.3

var user_name : String   = ""
var weapon_name : String = ""
var direction : Vector2
var distance : float = 0


func _init(dir : Vector2, dam : float, usr : String, wpn_name : String):
	direction = dir
	damage = dam
	user_name = usr
	weapon_name = wpn_name


func _ready():
	_connectSignals()


func _connectSignals():
	connect("body_entered", self, "_on_body_entered")


func _process(delta):
	position += speed * direction * delta
	distance += speed * delta

	if distance > max_range:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("Destructible"):
		body.takeDamage(damage, penetration_ratio, user_name, weapon_name)
		queue_free()
