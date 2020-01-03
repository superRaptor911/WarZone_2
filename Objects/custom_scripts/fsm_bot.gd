

#Base class for FSM for bots
extends Node
class_name BOT_FSM_STATE

var bot = null
var is_active : bool = false
var state_name : String = "nothing"

#get parent i.e bot
func _ready():
	bot = get_parent()
	if bot:
		if not bot.is_in_group("Bot"):
			print("BOT_FSM_STATE/Error : parent not a bot")
	else:
		print("BOT_FSM_STATE/Error : parent not found")


func startState():
	is_active = true

func stopState():
	is_active = false