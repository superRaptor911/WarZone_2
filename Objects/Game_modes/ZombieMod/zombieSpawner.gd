extends Node2D

export var max_zombies : int = 10
export var frequency : float = 0.25 setget set_frequency
export var activate : bool = false

export var HP : int  = 100
export var speed : int = 80

var zombies_spawned : int = 0
var zombie_index : int = 0
var obj_id = 0
var timer

onready var wait_time : float = 1.0 / frequency 
onready var level = get_tree().get_nodes_in_group("Level")[0]


func set_frequency(f):
	frequency = f
	wait_time = 1 / frequency
	if timer:
		timer.wait_time = wait_time


func _ready():
	if get_tree().is_network_server():
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", self, "_on_Timer_timeout")
		timer.wait_time = wait_time
		obj_id = get_instance_id()
		
		if activate:
			timer.start()


remotesync func P_spawnZombie(_id : String, hp : int, sped : int):
	var zm = game_states.classResource.get("zombie").instance()
	zm.name = _id
	zm.position = position
	zm.HP = hp
	zm.speed = sped
	level.add_child(zm)
	

func activateZ():
	if get_tree().is_network_server() and not activate:
		zombies_spawned = 0
		timer.start()

func deactivateZ():
	if get_tree().is_network_server() and activate:
		timer.stop()

func _on_Timer_timeout():
	if zombies_spawned <= max_zombies:
		var _id = "z" + String(obj_id) + String(zombie_index)
		zombie_index += 1
		zombies_spawned += 1
		timer.start()
		rpc("P_spawnZombie", _id, HP, speed)


