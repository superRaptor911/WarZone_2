extends Area2D

export var team_id = 0

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self , "on_body_exited")

# Player entered buy zone
func on_body_entered(body):
	if body.is_in_group("User"):
		body.enteredBuyZone()

# Player exited buy zone
func on_body_exited(body):
	if body.is_in_group("User"):
		body.exitedBuyZone()
