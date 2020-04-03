extends "res://Objects/Character.gd"

class_name Monster

export var rotational_speed : float = 2
export var main_destination : Vector2
export var damage : float = 10
export var attack_radius : float = 10
export var pname : String = "monster"

var path_array : PoolVector2Array 
var nav : Navigation2D
var current_node : int = 0
var destination : Vector2
var current_destination : Vector2
var initial_position : Vector2
var at_dest : bool = true
var char_array : Array
var nav_ready : bool = false
var target = null
var target_lost : bool = true



func _ready():
	var navs = get_tree().get_nodes_in_group("Nav")
	for n in navs:
		nav = n
	initial_position = position
	current_destination = main_destination


func _process(delta):
	handle_rotation(delta)


func follow_path(delt):
	if path_array.size() == 0 or path_array.size() <= current_node:
		at_dest = true
		return
	var delta : Vector2 = path_array[current_node] - position
	if delta.length() < speed * delt:
		position = path_array[current_node]
		current_node += 1
		return
	delta /delta.length()
	movement_vector = delta.normalized()
	destination = path_array[current_node]
	

func set_path(dest :Vector2) -> bool :
	if not nav :
		print("error nov not set")
		return false
	nav_ready = game_states.is_Astar_ready()
	if not nav_ready:
		return false
	
	path_array = nav.get_simple_path(position,dest)
	current_node = 0
	at_dest = false
	return true
	
func _get_nearest_player() :
	target = null
	var pls = get_tree().get_nodes_in_group("User")
	var min_distance : int = 99999
	for pl in pls:
		if pl.alive:
			var dist = (position - pl.position).length()
			if dist < min_distance:
				min_distance = dist
				target = pl

#checks visibility of player/target
func _is_target_visible() ->bool:
	if not target:
		return false
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, target.global_position,[self], collision_mask)
	if result:
		if result.collider.is_in_group("User"):
			return true
		return false
	return false

#This Function Rotates Bot with a constatant Rotational speed
func handle_rotation(delta : float):
	var dest_angle : float = (destination - position).angle() + 1.57
	#Tolerance
	if abs(dest_angle - rotation) <= 0.1:
		return
	#make angles in range (0,2pi)
	if dest_angle < 0 :
		dest_angle += 6.28
	if rotation < 0:
		rotation += 6.28
	if rotation > 6.28:
		rotation -= 6.28
		
	var aba : float = dest_angle - rotation
	if abs(aba) <= 6.28 - abs(aba) :
		rotation += sign(aba) * rotational_speed * delta
	else:
		rotation += -sign(aba) * rotational_speed * delta

func _on_Vision_body_entered(body):
	if body.is_in_group("Actor"):
		char_array.push_back(body)

func _on_Vision_body_exited(body):
	if body.is_in_group("Actor"):
		char_array.erase(body)
