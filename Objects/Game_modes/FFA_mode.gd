extends CanvasLayer

var scoreBoard = preload("res://Objects/Game_modes/FFA/FFAScoreBoard.tscn").instance()

#Quake sound class holds message that is to be displayed
#and name of the sound that is to be played
class quake_sound:
	var sound_name : String
	var msg : String
	
	#constuctor
	func _init(_msg,_sound_name):
		msg = _msg
		sound_name = _sound_name

#queue of quake_sounds
var quake_sound_queue  = Array()

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
	func _player_killed_someone():
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
			return "ulta_kill"
		return ""

#list of player stats
var Players = Array()

#stores the time elapsed.
var time_elapsed  : float = 0

#update time panel every second
func _on_uptime_timeout():
	time_elapsed += 1
	var _min_ : int = time_elapsed/60.0
	var _sec_ : int = int(time_elapsed) % 60
	$Time_container/panel/Label.text = String(_min_) + " : " + String(_sec_)


func _ready():
	#only server handles quake events and sound
	if get_tree().is_network_server():
		var plz = get_tree().get_nodes_in_group("User")
		for plr in plz:
			var p = Player_stats.new(plr.name,quake_sound_queue)
			plr.connect("char_killed",p,"_player_got_killed")
			plr.connect("char_killed_someone",p,"_player_killed_someone")
			Players.push_back(p)
		$Label/Timer.start()

func _process(delta):
	if get_tree().is_network_server():
		showQuakeKills()

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
	

func _on_Timer_timeout():
	pass
	#showQuakeKills()
