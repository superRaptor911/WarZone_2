extends CanvasLayer

var user = null
const JOYSTICK_DEADZONE = 0.4;
var counter : bool = false
var enabled : bool = true

onready var aim = $aim_joy
onready var mov = $mov_joy

var config = {
	j1 = {
		pos = Vector2(96, 452),
		out_size = 200,
		in_size = 160,
		radius = 90
	},
	
	j2 = {
		pos = Vector2(996, 452),
		out_size = 200,
		in_size = 160,
		radius = 90
	}
}

func _ready():
	aim.connect("Joystick_Updated",self,"_on_joy2_move")
	#if not game_states.game_settings.static_dpad:
		#$mov_joy.use_screen_rectangle = true
		#$aim_joy.use_screen_rectangle = true
	mov.modulate.a8 = game_states.game_settings.dpad_transparency
	aim.modulate.a8 = game_states.game_settings.dpad_transparency
	var _config = game_states.load_data("user://controls.dat", false)
	game_states.safe_cpy_dict(config, _config)
	
	$mov_joy.rect_position = Vector2(config.j1.pos[0], config.j1.pos[1])
	$aim_joy.rect_position = Vector2(config.j2.pos[0], config.j2.pos[1])
	$mov_joy.rect_size = Vector2.ONE * config.j1.out_size
	$aim_joy.rect_size = Vector2.ONE * config.j2.out_size
	$mov_joy/Joystick_Ring.rect_size = Vector2.ONE * config.j1.in_size
	$aim_joy/Joystick_Ring.rect_size = Vector2.ONE * config.j2.in_size
	
	$mov_joy.radius = (config.j1.out_size / 2) * (config.j1.radius / 100)
	$aim_joy.radius = (config.j2.out_size / 2) * (config.j2.radius / 100)


func _process(_delta):
	if not (user.alive and enabled):
		return
	if mov.joystick_vector.length() > JOYSTICK_DEADZONE/2 :
		user.movement_vector = - mov.joystick_vector
		counter = true
	if aim.joystick_vector.length() > 0.8:
		user.selected_gun.fireGun()
	if counter:
		counter = false

	
func _on_joy2_move(val):
	if not (user.alive and enabled):
		return
	user.rotation = val.angle() + 1.57
	counter = true
	#user.rpc("sync_vars",user.movement_vector,user.rotation,user.position)
