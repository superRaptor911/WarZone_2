extends Sprite

var wpn_name : String    = ""
var user_name : String   = ""
var damage : int         = 0
var rate_of_fire : float = 0
var reload_time : float  = 0
var mag_size : int       = 0
var bullets_in_mag : int = 0
var bullets : int        = 0
var accuracy : float     = 0
var recoil : float       = 0

var is_reloading : bool = false

onready var timer : Timer        = get_node("Timer")
onready var reload_timer : Timer = get_node("reload_timer")

func _ready():
	timer.wait_time = 1.0 / rate_of_fire
	reload_timer.wait_time = reload_time
	reload_timer.connect("Timeout", self, "_on_reload_complete")


func fireGun():
	if !is_reloading && timer.is_stopped():
		timer.start()
		_fire()


func reload():
	if !is_reloading && bullets > 0 && bullets_in_mag != mag_size:
		reload_timer.start()


func _on_reload_complete():
	_reload()


func _reload():
	var decrement = min(mag_size - bullets_in_mag, bullets)
	bullets -= decrement
	bullets_in_mag += decrement


func _fire():
	pass
