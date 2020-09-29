extends Area2D

export var max_points = 100
export var holding_team = 0

var value = 0
var units_in_chkPt = Array()
var frame = 0
const update_frames = 5

signal team_captured_point(point)

func _ready():
	# value for T = max_points, CT = 0
	value = max_points - max_points * holding_team


func _on_checkpoint_body_entered(body):
	if body.is_in_group("Unit"):
		units_in_chkPt.append(body)


func _on_checkpoint_body_exited(body):
	if body.is_in_group("Unit"):
		units_in_chkPt.erase(body)


func _process(_delta):
	# Update every "update_frame"
	frame += 1
	if frame > update_frames:
		frame = 0
		# Change value
		for i in units_in_chkPt:
			if i.alive:
				# +1 for every Terrorist, -1 for CT
				value += (1 - 2 * i.team.team_id)
		value = clamp(value, 0, max_points)
		if value == 0 or value == max_points:
			var new_holding_team = (max_points - value) / max_points
			if holding_team != new_holding_team:
				holding_team = new_holding_team
				emit_signal("team_captured_point", self)
