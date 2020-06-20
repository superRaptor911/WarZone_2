extends Node2D

export var max_zombies : int = 10
export var frequency : float = 2.0

var zombies_spawned : int = 0
var zombie_index : int = 0
var obj_id = 0

onready var wait_time : float = 1.0 / frequency 
onready var timer = $Timer
onready var level = get_tree().get_nodes_in_group("Level")[0]


func _ready():
	if get_tree().is_network_server():
		timer.wait_time = wait_time
		timer.start()
		obj_id = get_instance_id()
		


remotesync func P_spawnZombie(_id : String):
	var zm = game_states.classResource.get("zombie").instance()
	zm.name = _id
	zm.position = position
	level.add_child(zm)
	


func _on_Timer_timeout():
	if zombies_spawned <= max_zombies:
		var _id = "z" + String(obj_id) + String(zombie_index)
		zombie_index += 1
		zombies_spawned += 1
		timer.start()
		rpc("P_spawnZombie", _id)


