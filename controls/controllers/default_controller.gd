extends CanvasLayer

var user = null
const JOYSTICK_DEADZONE = 0.4;
var counter : bool = false
var enabled : bool = true

func _ready():
	if not game_states.is_android:
		self.queue_free()
		return
	$aim_joy.connect("Joystick_Updated",self,"_on_joy2_move")
	
	if not game_states.game_settings.static_dpad:
		$mov_joy.use_screen_rectangle = true
		$aim_joy.use_screen_rectangle = true
	$mov_joy.modulate.a8 = game_states.game_settings.dpad_transparency
	$aim_joy.modulate.a8 = game_states.game_settings.dpad_transparency


func _process(delta):
	if not (user.alive and enabled):
		return
	if $mov_joy.joystick_vector.length() > JOYSTICK_DEADZONE/2 :
		user.movement_vector = - $mov_joy.joystick_vector
		if $mov_joy.joystick_vector.length() > 0.85:
			user.useSprint()
		counter = true
	if $aim_joy.joystick_vector.length() > 0.85:
		user.selected_gun.fireGun()
	if counter:
		counter = false

	
func _on_joy2_move(val):
	user.rotation = val.angle() + 1.57
	counter = true
	#user.rpc("sync_vars",user.movement_vector,user.rotation,user.position)
