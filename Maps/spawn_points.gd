extends Node2D

var no_spawn_points : int = 0
var sp_spawn_count = PoolIntArray()

func _ready():
	no_spawn_points = get_child_count()
	for i in range (0, no_spawn_points):
		sp_spawn_count.append(0)

#GET spawn point with least number of player spawns
func getSpawnPoint() -> Vector2:
	var _min = 0
	var index = 0
	var s_points = get_children()
	
	for i in range(0, no_spawn_points):
		if sp_spawn_count[i] < _min:
			_min = sp_spawn_count[i]
			index = i
	sp_spawn_count[index] += 1
	return s_points[index].position
