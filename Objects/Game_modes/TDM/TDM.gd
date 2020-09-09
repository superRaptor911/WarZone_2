#TDM Game mode logic#
#####################
extends CanvasLayer

var end_screen_scn = preload("res://Objects/Game_modes/TDM/endScreen.tscn")

var mode_settings = {
	time_limit = 5,
	max_score = 50
}

var world_size : Vector2

#queue of quake_sounds
var quake_sound_queue  = Array()

# list of player stats
var Players = Array()
# stores the time elapsed.
var time_elapsed  : float = 0

onready var uptime_timer = $top_panel/uptime
onready var timer_label = $top_panel/Label
onready var ct_score_label = $top_panel/ct/Label
onready var t_score_label = $top_panel/t/Label

#Quake sound class holds message that is to be displayed
#and name of the sound that is to be played
class quake_sound:
	var sound_name : String
	var msg : String
	
	#constuctor
	func _init(_msg,_sound_name):
		msg = _msg
		sound_name = _sound_name

#Holds player kill stats for quake sounds
class Player_stats:
	#name of player
	var pname : String
	var kill_streak : int = 0
	var time_since_death : int = 0
	
	#reference variable of quake_sound_queue
	#reference is used because sub class cannot use global variable
	#in parent class
	var quake_sound_q_ref
	
	#Quake sound message format
	#%s will be replaced by player name
	var quake_sounds_format = {
		k3 = "%s did triple kill",
		k5 = "%s is on multi kill",
		k6 = "%s is on a rampage",
		K9 = "%s is dominating",
		k11 = "%s is unstoppable",
		k13 = "%s did mega kill",
		k15 = "%s did ultra kill"
	}
	
	#constuctor
	func _init(Pname : String,qs):
		pname = Pname
		quake_sound_q_ref = qs
	
	#on player killed someone
	func _player_killed_someone(_a, _b, _c):
		kill_streak += 1
		_check_quake_status()
	
	#reset kill streak
	func _player_got_killed():
		kill_streak = 0
	
	#check if player is eligible for quake sounds
	func _check_quake_status():
		if quake_sounds_format.has("k" + String(kill_streak)):
			var msg = quake_sounds_format.get("k" + String(kill_streak)) %pname
			var sound_name = _get_sound_name()
			quake_sound_q_ref.push_back(quake_sound.new(msg,sound_name))
	
	#get quake sound name w.r.t kill streak
	func _get_sound_name() -> String:
		if kill_streak == 3:
			return "triple_kill"
		if kill_streak == 5:
			return "multi_kill"
		if kill_streak == 6:
			return "rampage"
		if kill_streak == 9:
			return "dominating"
		if kill_streak == 11:
			return "unstoppable"
		if kill_streak == 13:
			return "mega_kill"
		if kill_streak == 15:
			return "ultra_kill"
		return ""


func _ready():
	#only server handles quake events and sound
	if get_tree().is_network_server():
		var current_level = get_tree().get_nodes_in_group("Level")[0]
		current_level.connect("player_created", self, "_on_unit_created")
		current_level.connect("bot_created",self,"_on_unit_created")
		$Label/Timer.start()
		uptime_timer.start()
		createBots()


func _process(_delta):
	if get_tree().is_network_server():
		showQuakeKills()


#update time panel every second
func _on_uptime_timeout():
	time_elapsed += 1
	rpc_unreliable("syncTime",time_elapsed)
	
	#end game
	if time_elapsed >= mode_settings.time_limit * 60:
		#var level = get_tree().get_nodes_in_group("Level")[0]
		#level.S_restartLevel()
		rpc("sync_endGame")


remotesync func sync_endGame():
	var end_scr = end_screen_scn.instance()
	if get_tree().is_network_server():
		end_scr.connect("ok",self,"restartGameMode")
	add_child(end_scr)
	end_scr.rect_scale = Vector2(0,0)
	$Tween.interpolate_property(get_tree().get_nodes_in_group("Level")[0],"modulate",
		Color8(255,255,255,255),Color8(0,0,0,0),2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.interpolate_property(end_scr,"rect_scale",Vector2(0,0),Vector2(1,1),1,
		Tween.TRANS_QUAD,Tween.EASE_OUT,2)
	$Tween.start()
	$Time_container.hide()


func showQuakeKills():
	if quake_sound_queue.size():
		var is_last_msg :bool = false
		if quake_sound_queue.size() == 1:
			is_last_msg = true
		rpc("syncQuakeKills",quake_sound_queue[0].msg, quake_sound_queue[0].sound_name, is_last_msg)
		quake_sound_queue.erase(quake_sound_queue[0])


remotesync func syncQuakeKills(msg,sound_name,is_last_msg : bool):
	print("called")
	$Label.modulate = Color8(255,255,255,255)
	$Label.text = msg
	$quake_sounds.get_node(sound_name).play()
	if is_last_msg:
		$Tween.interpolate_property($Label,"modulate",Color8(255,255,255,255),Color8(255,255,255,0),5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()  


remotesync func syncTime(time_now):
	var time_limit = game_server.extraServerInfo.time_limit * 60
	var _min_ : int = (time_limit - time_now)/60.0
	var _sec_ : int = int(time_limit - time_now) % 60
	timer_label.text = String(_min_) + " : " + String(_sec_)


func _on_Timer_timeout():
	pass
	#showQuakeKills()

#handle new player
func _on_unit_created(plr):
	#register player with quake sounds
	var p = Player_stats.new(plr.pname,quake_sound_queue)
	plr.connect("char_killed",p,"_player_got_killed")
	plr.connect("char_fraged",p,"_player_killed_someone")
	plr.connect("char_fraged", self, "_on_player_killed_someone")
	Players.push_back(p)
	#connect
	if plr.is_in_group("Bot"):
		plr.connect("bot_killed",self,"_on_bot_killed")
	else:
		plr.connect("player_killed",self,"_on_player_killed")


func _on_player_killed(plr):
	plr.get_node("respawn_timer").start()
	
func _on_bot_killed(bot):
	bot.get_node("respawn_timer").start()

func _on_player_killed_someone(plr_ref, _victim_ref, _wpn_used):
	if plr_ref:
		var f_fire = false
		# Check for friendly fire
		if _victim_ref:
			if plr_ref.team.team_id == _victim_ref.team.team_id:
				f_fire = true
		
		if f_fire:
			plr_ref.team.addScore(-2)
		else:
			plr_ref.team.addScore(2)
		updateScore(plr_ref.team)


func updateScore(team):
	if team.team_id == 0:
		t_score_label.text = String(team.score)
	else:
		ct_score_label.text = String(team.score)
	
	if team.score >= mode_settings.max_score:
		rpc("sync_endGame")

func restartGameMode():
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.S_restartLevel()
	rpc("P_restartGameMode")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	time_elapsed = 0
	createBots()


remotesync func P_restartGameMode():
	var level = get_tree().get_nodes_in_group("Level")[0]
	$Tween.interpolate_property(level,"modulate",Color8(0,0,0,0),Color8(255,255,255,255),
		2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()

func createBots():
	Logger.Log("Creating bots")
	var bots = Array()
	var bot_count = game_server.bot_settings.bot_count
	print("Bot count = ",game_server.bot_settings.bot_count)
	game_server.bot_settings.index = 0
	var ct = false
	var level = get_tree().get_nodes_in_group("Level")[0]
	
	if bot_count > game_states.bot_profiles.bot.size():
		Logger.Log("Not enough bot profiles. Required %d , Got %d" % [bot_count, game_states.bot_profiles.bot.size()])
	
	for i in game_states.bot_profiles.bot:
		i.is_in_use = false
		if game_server.bot_settings.index < bot_count:
			i.is_in_use = true
			var data = level.unit_data_dict.duplicate(true)
			data.pn = i.bot_name
			data.g1 = i.bot_primary_gun
			data.g2 = i.bot_sec_gun
			data.b = true
			data.k = 0
			data.d = 0
			data.scr = 0
			data.pg = i.bot_primary_gun
			data.sg = i.bot_sec_gun
			
			#assign team
			if ct:
				data.tId = 1
				data.s = i.bot_ct_skin
				ct = false
			else:
				data.tId = 0
				data.s = i.bot_t_skin
				ct = true
			
			data.p = level.getSpawnPosition(data.tId)
			#giving unique node name
			data.n = "bot" + String(69 + game_server.bot_settings.index)
			bots.append(data)
			game_server.bot_settings.index += 1
	
	#spawn bot
	for i in bots:
		level.createUnit(i)
		Logger.Log("Created bot [%s] with ID %s" % [i.pn, i.n])
