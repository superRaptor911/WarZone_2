#handles going towards player
extends "res://Objects/custom_scripts/fsm_bot.gd"

#signal target is dead or left the server
signal player_dead
#signal target is visible
signal player_visible

#last player/target position before calling Astar (get_path())
var last_player_pos : Vector2 = Vector2()
#max postition change before calling astar
var max_pos_deviation : float = 100

#calling visibility_check every frame is not a good idea.
#so set some interval before calling visibilty checks
var visibility_chk_interval : Timer = Timer.new()

func _ready():
	#setup timer
	state_name = "gotto"
	visibility_chk_interval.wait_time = 1.5 + rand_range(0,0.4) 
	visibility_chk_interval.one_shot = false
	visibility_chk_interval.autostart = false
	visibility_chk_interval.connect("timeout",self,"_on_visibility_src_interval")
	add_child(visibility_chk_interval)
	pass

#start state
func startState():
	bot.set_path(bot.target.position)
	last_player_pos = bot.target.position
	visibility_chk_interval.start()
	.startState()
	pass

func stopState():
	visibility_chk_interval.stop()
	.stopState()
	print("deactivated goto player")

func _process(delta):
	if is_active:
		if bot.target and bot.alive:
			_chkPlayerPos()
			bot.follow_path(delta)
		else:
			emit_signal("player_dead")
	pass
	
#call Astar if necessary
func _chkPlayerPos():
	if (last_player_pos - bot.target.position).length() > max_pos_deviation:
		if bot.set_path(bot.target.position):
			print("astar")
			last_player_pos = bot.target.position

func _on_visibility_src_interval():
	if bot._is_target_visible():
		print("player visible")
		emit_signal("player_visible")
