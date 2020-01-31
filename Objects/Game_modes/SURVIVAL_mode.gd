extends Node

var level : int = 0
var lvl

#spawn points available to zombies
var zm_spawn_points

#unique zombie id
var zm_id : int = 0
var spawn_texture = preload("res://Sprites/Character/spawn_point.png")
var max_zombie : int = 14

#stores the time elapsed.
var time_elapsed  : float = 0

var zombie_types = {
	necron = preload("res://Objects/Monsters/Necron.tscn"),
	hunter = preload("res://Objects/Monsters/hunter.tscn")
}


var zm_spawn_queue = Array()

#this signal is emited when all zombies are killed
signal zombies_wiped_out
#this signal is emitted when current level is over
signal change_level
#this signal is emitted when spawning process is complete
signal zm_spawn_complete

var hud_message_timer : Timer

#ready
func _ready():
	#potential bug
	lvl = get_parent()
	if get_tree().is_network_server():
		network.connect("server_stopped",self,"_on_server_stopped")
		$chk_zm_count.start()
		#get zm spawn points
		zm_spawn_points = get_tree().get_nodes_in_group("zombie_spawn")[0].get_children()
		connect("change_level",self,"_on_level_complete")
		connect("zombies_wiped_out",self,"_on_zm_wiped_out")
		emit_signal("change_level")
		hud_message_timer = Timer.new()
		hud_message_timer.wait_time = 5.0
		hud_message_timer.one_shot = true
		hud_message_timer.connect("timeout",self,"_on_hud_timeout")
		add_child(hud_message_timer)


#spawn zombies 
#this function is server only
func _spawn_zombies(zm_type):
	var rand_index = randi() % zm_spawn_points.size()
	var zm = zombie_types.get(zm_type).instance()
	zm.position = zm_spawn_points[rand_index].position
	zm.set_name("bot" + String(zm_id))
	lvl.add_child(zm)
	rpc("_sync_spawn_zombie",zm_type,zm.position,zm_id)
	zm_id += 1
	
#sync spawn 
#client fn
remote func _sync_spawn_zombie(zm_type,pos,idx):
	var zm = zombie_types.get(zm_type).instance()
	zm.position = pos
	zm.set_name("bot" + String(idx))
	lvl.add_child(zm)


#check end of level
func _check_zombie_count():
	var zm_count = get_tree().get_nodes_in_group("Monster").size()
	if zm_count <= 0:
		emit_signal("zombies_wiped_out")

#Updates time elapsed
func _on_update2_timeout():
	time_elapsed += 1
	var _min_ : int = time_elapsed/60.0
	var _sec_ : int = int(time_elapsed) % 60
	$timer/Panel/Label.text = String(_min_) + " : " + String(_sec_)
	$update2.start()

remotesync func _sync_msg_panel(val):
	$msg.visible = val

#update spawn queue
func _init_zombie_spawn_q(type,count):
	for i in range(0,count):
		zm_spawn_queue.append(type)
	zm_spawn_queue.shuffle()


#Spawn delay after spawning a zombie
#i.e handles spawn rate
func _on_zm_spawn_dl_timeout():
	#if there's something in queue spawn that and again
	#call this function
	if zm_spawn_queue.size() > 0:
		var zm_count = get_tree().get_nodes_in_group("Monster").size()
		if zm_count < max_zombie:
			_spawn_zombies(zm_spawn_queue.pop_front())
		$zm_spawn_dl.start()
	else:
		emit_signal("zm_spawn_complete")
		


func _on_hud_timeout():
	rpc("_sync_msg_panel",false)

func _on_zm_wiped_out():
	hud_message_timer.start()
	rpc("_sync_msg_panel",true)
	emit_signal("change_level")

func _on_level_complete():
	level += 1
	call("_level_" + String(level))


func _on_chk_zm_count_timeout():
	_check_zombie_count()
	$chk_zm_count.start()

func _on_server_stopped():
	queue_free()

#----------------------------------------------------------------
#LEVELS

func _level_1():
	_init_zombie_spawn_q("necron",2)
	#_init_zombie_spawn_q("hunter",8)
	$zm_spawn_dl.start()


func _level_2():
	_init_zombie_spawn_q("necron",80)
	_init_zombie_spawn_q("hunter",12)
	$zm_spawn_dl.start()
	
func _level_3():
	_init_zombie_spawn_q("necron",100)
	_init_zombie_spawn_q("hunter",10)
	$zm_spawn_dl.start()
