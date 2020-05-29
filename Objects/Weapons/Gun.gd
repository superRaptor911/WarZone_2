class_name Gun
extends Node2D

export var gun_type : String = "pistol"
export var gun_name : String = "null"
export var damage : float = 18
export var clip_size : int = 10
export var gun_rating : int = 0
export var rate_of_fire : float = 4
export var zoom_range : PoolRealArray = [0.75, 0.85]
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

onready var _fire_delay = 1.0 / rate_of_fire

signal gun_fired
signal gun_reloaded


func _ready():
	#convert to radians
	spread = spread * PI / 180
	if rounds_left == 0:
		reload()
	#if it does not have parent/user then force get parent
	if user_id == "":
		print_debug("user id not set")


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
remotesync func P_createBullet(_cast_to):
	$Muzzle/muzzle.show()
	_muzzle_frame_id = 3
	$fire.play()
	emit_signal("gun_fired")


#server only method
remotesync func S_checkBulletHit():
	var error_angle = rand_range(-spread - _recoil * 0.01,spread + _recoil * 0.01)
	var cast_to = Vector2(0,-750).rotated(global_rotation + error_angle) + global_position
	_recoil += recoil_factor
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, cast_to, [self])
	if result:
		cast_to = result.position
		if result.collider.is_in_group("Actor"):
			result.collider.takeDamage(damage,gun_name,user_id)
	$recoil_reset.start()
	rpc("P_createBullet",cast_to)


#shoot weapon
func _shoot():
	rpc_id(1,"S_checkBulletHit")
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


#reload weapon
func _on_Reload_time_timeout():
	clip_count -= 1
	rounds_left = clip_size
	is_reloading = false
	emit_signal("gun_reloaded")

func _process(_delta):
# warning-ignore:narrowing_conversion
	_muzzle_frame_id = max(_muzzle_frame_id - 1,0)
	if _muzzle_frame_id == 1:
		$Muzzle/muzzle.hide()
	#update _draw()
	if _use_laser_sight:
		update()
		_ray_dest = $RayCast2D.cast_to.rotated(global_rotation) + $RayCast2D.global_position
		if $RayCast2D.is_colliding():
			_ray_dest = $RayCast2D.get_collision_point()

func _draw():
	if _use_laser_sight:
		draw_line($Muzzle.position, (_ray_dest - $RayCast2D.global_position).rotated(-global_rotation)
		+ $RayCast2D.position , Color.red)
		draw_circle((_ray_dest - $RayCast2D.global_position).rotated(-global_rotation) + $RayCast2D.position 
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
