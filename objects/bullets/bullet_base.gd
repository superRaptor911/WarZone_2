# Base class for bullets
extends Area2D

export var type : String      = "_9mm_fmj" # Bullet name
var speed : float             = 300        # Projectile speed
var max_range : int           = 500        # Projectile range
var penetration_ratio : float = 0.3        # How much damage to armoured targets

var user_name : String   = ""  # name of user who fired this bullet
var damage : float		 = 100 # Damage, inherited from gun
var weapon_name : String = ""  # name of the weapon it's fired from
var direction : Vector2        # Direction it's moving
var distance : float	 = 0   # Distance covered


# Init with values from gun
func init(dir : Vector2, dam : float, usr : String, wpn_name : String):
	direction = dir
	damage = dam
	user_name = usr
	weapon_name = wpn_name


func _ready():
	_connectSignals()
	_setupStats()


# Load bullet stats from resources script
func _setupStats():
	var resource = get_tree().root.get_node("Resources")
	var stats = resource.bullet_stats.get(type)
	speed             = stats.speed
	max_range         = stats.max_range
	penetration_ratio = stats.penetration_ratio


# Connect body entered signal
func _connectSignals():
	connect("body_entered", self, "_on_body_entered")


# Move 
func _process(delta):
	position += speed * direction * delta
	distance += speed * delta
	# free on out of range
	if distance > max_range:
		queue_free()


# When hits a body
func _on_body_entered(body):
	if body.is_in_group("Destructible"):
		body.takeDamage(damage, penetration_ratio, user_name, weapon_name)
		queue_free()
