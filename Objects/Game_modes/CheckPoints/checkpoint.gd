extends Area2D

export var id = 0
export var max_points = 100
export var holding_team = 0

const update_frames = 5


var value = 0
var units_in_chkPt = Array()
var frame = 0

onready var is_server = get_tree().is_network_server()

signal team_captured_point(point)
signal local_player_entered(point)
signal local_player_exited


func _ready():
	# value for T = max_points, CT = 0
	value = max_points - max_points * holding_team
	on_new_team_captured()


func _on_checkpoint_body_entered(body):
	if body.is_in_group("Unit"):
		units_in_chkPt.append(body)
		if body.is_in_group("User") and body.is_network_master():
			emit_signal("local_player_entered", self)
			


func _on_checkpoint_body_exited(body):
	if body.is_in_group("Unit"):
		units_in_chkPt.erase(body)
		if body.is_in_group("User") and body.is_network_master():
			emit_signal("local_player_exited")


func _process(_delta):
	# Update every "update_frame"
	frame += 1
	if frame > update_frames and is_server:
		frame = 0
		# Change value
		for i in units_in_chkPt:
			if i.alive:
				# +1 for every Terrorist, -1 for CT
				value += (1 - 2 * i.team.team_id)
		value = clamp(value, 0, max_points)
		rpc("P_sync_value", value)


remotesync func P_sync_value(val):
	value = val
	if value == 0 or value == max_points:
		var new_holding_team = (max_points - value) / max_points
		if holding_team != new_holding_team:
			holding_team = new_holding_team
			emit_signal("team_captured_point", self)
			on_new_team_captured()



func on_new_team_captured():
	if holding_team == 1:
		$Sprite.modulate = Color8(17,64, 194)
	else:
		$Sprite.modulate = Color8(201, 55, 31)
