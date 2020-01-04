extends "res://Objects/custom_scripts/fsm_bot.gd"

signal player_dead
signal player_not_visible

#calling visibility_check every frame is not a good idea.
#so set some interval before calling visibilty checks
var visibility_chk_interval : Timer = Timer.new()

func _ready():
	#setup timer
	state_name = "attack"
	visibility_chk_interval.wait_time = 1.5 + rand_range(0,0.4) 
	visibility_chk_interval.one_shot = false
	visibility_chk_interval.autostart = false
	visibility_chk_interval.connect("timeout",self,"_on_visibility_src_interval")
	add_child(visibility_chk_interval)

func _process(delta):
	if is_active:
		if bot.target and bot.target.alive:
			bot.destination = bot.target.position
			if (bot.position - bot.target.position).length() > bot.attack_radius:
				_charge_towards_player()
			else:
				bot.attack(delta)
		else:
			emit_signal("player_dead")
	pass

func _charge_towards_player():
	bot.movement_vector = bot.target.position - bot.position

func _on_visibility_src_interval():
	if not bot._is_target_visible():
		emit_signal("player_not_visible")
		

func stopState():
	visibility_chk_interval.stop()
	.stopState()

func startState():
	visibility_chk_interval.start()
	.startState()
	pass