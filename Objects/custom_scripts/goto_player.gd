#handles going towards player
extends "res://Objects/custom_scripts/fsm_bot.gd"

#signal target is dead or left the server
signal player_dead
#signal target is visible
signal player_visible
#signal to update target
signal update_target

#last player/target position before calling Astar (get_path())
var last_player_pos : Vector2 = Vector2()
#max postition change before calling astar
var max_pos_deviation : float = 100

#calling visibility_check every frame is not a good idea.
#so set some interval before calling visibilty checks
var visibility_chk_interval : Timer = Timer.new()
#time delay for each Astar calls
var Astar_request_interval : Timer = Timer.new()
#change state to get nearest player delay
#when this timer timeouts the state of bot changes to get nearest player
var update_player_request_delay : Timer = Timer.new()

func _ready():
	#setup timers
	state_name = "gotto"
	visibility_chk_interval.wait_time = 1.5 + rand_range(0,0.4) 
	visibility_chk_interval.one_shot = false
	visibility_chk_interval.autostart = false
	visibility_chk_interval.connect("timeout",self,"_on_visibility_src_interval")
	add_child(visibility_chk_interval)
	
	#setup timers
	Astar_request_interval.wait_time = 0.5 + rand_range(-0.2,1.0)
	Astar_request_interval.one_shot = true
	Astar_request_interval.connect("timeout",self,"_on_Astar_request_interval")
	add_child(Astar_request_interval)
	
	update_player_request_delay.wait_time = 5.0
	update_player_request_delay.one_shot = false
	update_player_request_delay.connect("timeout",self,"_on_update_player_request_delay_timeout")
	add_child(update_player_request_delay)
	pass

#start state
func startState():
	bot.set_path(bot.target.position)
	last_player_pos = bot.target.position
	visibility_chk_interval.start()
	update_player_request_delay.start()
	.startState()
	pass

func stopState():
	visibility_chk_interval.stop()
	Astar_request_interval.stop()
	update_player_request_delay.stop()
	.stopState()

func _process(delta):
	if is_active:
		if bot.target and bot.target.alive:
			_chkPlayerPos()
			bot.follow_path(delta)
		else:
			emit_signal("player_dead")
	pass
	
#call Astar if necessary
func _chkPlayerPos():
	if (last_player_pos - bot.target.position).length() > max_pos_deviation:
		if Astar_request_interval.is_stopped():
			Astar_request_interval.start()

#check player visibility
func _on_visibility_src_interval():
	if bot._is_target_visible():
		emit_signal("player_visible")

#get path to player
func _on_Astar_request_interval():
	if bot.set_path(bot.target.position):
		last_player_pos = bot.target.position
	else:
		Astar_request_interval.start()

func _on_update_player_request_delay_timeout():
	emit_signal("update_target")