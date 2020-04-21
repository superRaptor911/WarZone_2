extends Panel

var player = null

signal remove_panel(panel)

func _ready():
	var level = get_tree().get_nodes_in_group("Level")[0]
	level.connect("player_despawned",self,"_on_player_despawned")
	level.connect("bot_despawned",self,"_on_player_despawned")


func setPlayer(plr):
	player = plr
	player.connect("char_killed",self,"_on_player_killed")
	player.connect("char_born",self,"_on_player_born")
	$name.text = plr.pname
	$team.text = plr.team.team_name
	$doa.text = "Alive"
	if plr.is_in_group("Bot"):
		$type.text = "Bot"
	else:
		$type.text = "Human"

func _on_player_despawned(plr):
	if plr == player:
		emit_signal("remove_panel",self)

func _on_player_killed():
	$doa.text = "Dead"
	$kill.disabled = true

func _on_player_born():
	$doa.text = "Alive"
	$kill.disabled = false


func _on_kill_pressed():
	MusicMan.click()
	player.killChar()


func _on_kick_pressed():
	MusicMan.click()
	if player.is_in_group("User"):
		network.kick_player(int(player.name),"kicked by admin")
	else:
		var lvl = get_tree().get_nodes_in_group("Level")[0]
		lvl.server_kickBot(player)
