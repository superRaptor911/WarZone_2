extends Node

class_name Team

var team_id : String = "A"
var team_name : String = ""
var score : int = 0


func _init(id):
	team_id = id

func _ready():
	add_to_group("Team")


func addPlayer(P):
	P.team = self
	


