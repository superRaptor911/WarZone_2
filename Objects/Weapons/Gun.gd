class_name Gun
extends Node2D

export var gun_type : String = "pistol"
export var gun_name : String = "null"
export var damage : float = 18
export var clip_size : int = 10
export var gun_rating : int = 0
export var rate_of_fire : float = 4
export var reload_time : float = 1.0
export var zoom_range : PoolRealArray = [0.5, 0.7]
export var recoil_factor : float = 0.2
export var spread : float = 2
export var gun_portrait : Texture = preload("res://Sprites/Weapons/gun_p.png")
export var gun_d_img : Texture
export var wpn_cost : int = 500

var rounds_left = 0
var clip_count : int = 4

var _zoom_index : int = 0
var _ready_to_fire : bool = true
var user_id : String = ""
var is_reloading : bool = false
var _max_ray_distance : float = 200
var _ray_dest : Vector2
var _use_laser_sight : bool = false
var _has_extended_mag : bool = false
var _muzzle_frame_id : int = 0
var _recoil = 0

#used to render projectile tracers
var fired = false

onready var _fire_delay = 1.0 / rate_of_fire
onready var muzzle = $Muzzle
onready var raycast_2D = $RayCast2D
onready var level = get_tree().get_nodes_in_group("Level")[0]
onready var fire_sfx = $fire

var shell_scn = preload("res://Objects/Weapons/Shell.tscn")

signal gun_fired
signal gun_reloading
signal gun_reloaded


func _ready():
	#convert to radians
	spread = spread * PI / 180
	$Reload_time.wait_time = reload_time
	if rounds_left == 0:
		reload()



#Try to fire gun
func fireGun():
	if _ready_to_fire:
		if clip_count <= 0 and rounds_left <= 0:
			$clipOut.play()
			_ready_to_fire = false
			$Timer.start(_fire_delay)
		elif rounds_left > 0:
			_shoot()
		elif rounds_left <= 0:
			reload()


#create projectile
remotesync func P_gunFired(_cast_to):
	#show muzzle flash for 3 frames
	muzzle.get_node("muzzle_flash").show()
	_muzzle_frame_id = 3
	fire_sfx.play()
	# Shell effects
	if game_states.game_settings.particle_effects:
		var shell = shell_scn.instance()
		shell.global_position = (muzzle.global_position + global_position) / 2
		shell.global_rotation = global_rotation
		level.add_child(shell)
	
	#render tracers
	fired = true
	_ray_dest = _cast_to
	update()
	emit_signal("gun_fired")


#server only method
remotesync func S_gunFired():
	var error_angle = rand_range(-spread - _recoil * 0.01,spread + _recoil * 0.01)
	var cast_to = Vector2(0,-750).rotated(global_rotation + error_angle) + global_position
	_recoil += recoil_factor
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, cast_to, [self])
	if result:
		cast_to = result.position
		if result.collider.is_in_group("Damageable"):
			result.collider.takeDamage(damage,gun_name,user_id)
	$recoil_reset.start()
	rpc("P_gunFired",cast_to)


#shoot weapon
func _shoot():
	rpc_id(1,"S_gunFired")
	_ready_to_fire = false
	$Timer.start(1 / rate_of_fire)
	rounds_left -= 1


func _on_Timer_timeout():
	_ready_to_fire = true


#do reloading
func reload():
	if clip_count > 0 and not is_reloading:
		$reload.play()
		$Reload_time.start()
		is_reloading = true
		emit_signal("gun_reloading")


#reload weapon
func _on_Reload_time_timeout():
	clip_count -= 1
	rounds_left = clip_size
	is_reloading = false
	emit_signal("gun_reloaded")

func _process(_delta):
	if _muzzle_frame_id != 0:
		# warning-ignore:narrowing_conversion
		_muzzle_frame_id = max(_muzzle_frame_id - 1,0)
		update()
		#hide muzzle flash
		if _muzzle_frame_id == 1:
			muzzle.get_node("muzzle_flash").hide()
			fired = false

	#draw laser
	if _use_laser_sight:
		update()
		_ray_dest = raycast_2D.cast_to.rotated(global_rotation) + raycast_2D.global_position
		if raycast_2D.is_colliding():
			_ray_dest = raycast_2D.get_collision_point()

func _draw():
	if fired:
		draw_line(muzzle.position, (_ray_dest - muzzle.global_position).rotated(-global_rotation) + muzzle.position, 
				Color(255,250,0),1.25)
	
	if _use_laser_sight:
		draw_line(muzzle.position, (_ray_dest - raycast_2D.global_position).rotated(-global_rotation)
		+ raycast_2D.position , Color.red)
		draw_circle((_ray_dest - raycast_2D.global_position).rotated(-global_rotation) + raycast_2D.position 
		, 3, Color.red)


func _on_recoil_reset_timeout():
	_recoil = 0


func getNextZoom() -> Vector2:
	_zoom_index += 1
	if _zoom_index >= zoom_range.size():
		_zoom_index = 0
	
	return Vector2(zoom_range[_zoom_index], zoom_range[_zoom_index])

func getCurrentZoom() -> Vector2:
	return Vector2(zoom_range[_zoom_index], zoom_range[_zoom_index])
