extends Area2D

export var checkPoint_id : int = 0
export var connected_to : Array
export var max_points : float = 5
export var team_id : int = -1

var points = 0.0
#number of units of each team capturing this point
var team_strength = [0,0]

signal checkpoint_captured(id,team_id)


func _on_checkPoint_body_entered(body):
	if body.is_in_group("Unit"):
		team_strength[body.team.team_id] += 1
		


func _on_checkPoint_body_exited(body):
	if body.is_in_group("Unit"):
		team_strength[body.team.team_id] -= 1
		

func _process(delta):
	if team_strength[0] > 0 or team_strength[1] > 0:
		points += (team_strength[1] - team_strength[0]) * delta
		points = clamp(points, -max_points, max_points)
		
		if points == max_points and team_id != 1:
			team_id = 1
			emit_signal("checkpoint_captured",checkPoint_id,team_id)
			var spawn_points = $spawnPoints.get_children()
			for i in spawn_points:
				i.team_id = team_id
			
		elif points == -max_points and team_id != 0:
			team_id = 0
			emit_signal("checkpoint_captured",checkPoint_id,team_id)
			var spawn_points = $spawnPoints.get_children()
			for i in spawn_points:
				i.team_id = team_id

