extends Node

class_name Team

var level 			= null
var team_id			= 0
var team_name		= ""
var score			= 0
var player_count 	= 0
var alive_players 	= 0
var user_count 		= 0

signal team_eliminated(team)
signal player_count_changed(team)

func _init(id,lvl):
	team_id = id
	level = lvl

func reset():
	alive_players = 0
	player_count = 0

func _ready():
	add_to_group("Team")
	level.connect("player_removed",self,"removePlayer")
	level.connect("bot_removed",self,"removePlayer")


func addPlayer(P):
	player_count += 1
	P.team = self
	P.connect("char_killed",self,"_on_player_killed")
	P.connect("char_born",self,"_on_player_born")
	if P.is_in_group("User"):
		user_count += 1


func removePlayer(plr):
	if plr.team.team_id == team_id:
		plr.disconnect("char_killed",self,"_on_player_killed")
		plr.disconnect("char_born",self,"_on_player_born")
		player_count -= 1
		
		if player_count == 0 and plr.alive:
			emit_signal("team_eliminated",self)
		
		if plr.is_in_group("User"):
			user_count -= 1		
		
		if plr.alive:
			alive_players -= 1
			


func _on_player_killed():
	alive_players -= 1
	emit_signal("player_count_changed", self)
	if alive_players == 0:
		emit_signal("team_eliminated", self)


func _on_player_born():
	alive_players += 1


func addScore(val : int):
	score += val
