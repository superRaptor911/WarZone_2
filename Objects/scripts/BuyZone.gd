extends Area2D

export var team_id = 0

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self , "on_body_exited")
	add_to_group("BuyZone")

# Player entered buy zone
func on_body_entered(body):
	if body.is_in_group("User") and body.team.team_id == team_id:
		body.enteredBuyZone()

# Player exited buy zone
func on_body_exited(body):
	if body.is_in_group("User") and body.team.team_id == team_id:
		body.exitedBuyZone()
