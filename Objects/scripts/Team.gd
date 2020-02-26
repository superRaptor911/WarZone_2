extends Node

class_name Team

var team_name : String = ""
var score : int = 0

class player:
	var pname : String = "player"
	var kills = 0
	var deaths = 0
	var score = 0
	

var team_members = Array()

func _ready():
	add_to_group("Team")

func getPlayer(player_name):
	for p in team_members:
		if p.pname == player_name:
			return p
	return null

func addPlayer(P):
	var pdata = player.new()
	P.team = self
	pdata.pname = P.pname
	team_members.append(pdata)

func updateTeam(player_data):
	var P = getPlayer(player_data.pname)
	P.kills = player_data.kills
	P.deaths = player_data.deaths
	P.score = player_data.score
	print("update team called")
