extends Node

var level : int = 0
var lvl
var zm_spawn_index : int = 0
var number_of_zm : int = 2
var zm_spawn_points
var zombie = preload("res://Objects/Monsters/hunter.tscn")
var zm_id : int = 0
signal Zombies_killed
var time : float = 0

#ready
func _ready():
	lvl = get_parent()
	if not get_tree().is_network_server():
		return
	$update.start()
	$zm_spawn_timer.start()
	zm_spawn_points = get_tree().get_nodes_in_group("zombie_spawn")[0].get_children()

#spawn zombies 
#this function is server only
func _spawn_zombies():
	var rand_index = randi() % zm_spawn_points.size()
	var zm = zombie.instance()
	zm.position = zm_spawn_points[rand_index].position
	zm.set_name("bot" + String(zm_id))
	lvl.add_child(zm)
	zm.target = _get_nearest_player(zm.position)
	$zm_spawn_dl.start()
	var zms = get_tree().get_nodes_in_group("Monster")
	for z in zms:
		zm.add_collision_exception_with(z)
	rpc("_sync_spawn_zombie",zm.position,zm_id)
	zm_id += 1
	
#sync spawn 
#client fn
remote func _sync_spawn_zombie(pos,idx):
	var zm = zombie.instance()
	zm.position = pos
	zm.set_name("bot" + String(idx))
	lvl.add_child(zm)


#check end of level
func _on_zombie_killed():
	var zm_count = get_tree().get_nodes_in_group("Monster").size()
	if zm_count <= 1:
		$zm_spawn_timer.start()
		$msg.show()
		rpc("_sync_msg_panel",true)
		level += 1
		number_of_zm += level*4
		
		
#function to get nearest player
func _get_nearest_player(pos) -> Player:
	var pls = get_tree().get_nodes_in_group("User")
	if pls.size() == 0:
		return null
	var p
	var min_distance : int = 99999
	for pl in pls:
		var dist = (pos - pl.position).length()
		if dist < min_distance:
			min_distance = dist
			p = pl
	return p

#zombie 
func _on_zm_spawn_dl_timeout():
	if zm_spawn_index >= number_of_zm:
		return
	_spawn_zombies()
	zm_spawn_index += 1

func _on_zm_spawn_timer_timeout():
	rpc("_sync_msg_panel",false)
	$msg.hide()
	zm_spawn_index = 0
	_spawn_zombies()


func _on_update_timeout():
	_on_zombie_killed()
	$update.start()

func _process(delta):
	time += delta

func _on_update2_timeout():
	var _min_ : int = time/60.0
	var _sec_ : int = int(time) % 60
	$timer/Panel/Label.text = String(_min_) + " : " + String(_sec_)
	$update2.start()

remote func _sync_msg_panel(val):
	$msg.visible = val
	