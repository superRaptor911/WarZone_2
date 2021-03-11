# Base class for guns
extends Sprite

export var wpn_name : String  = "" # Gun name
var type : String        = "rifle"   # Gun type, pistol , rifle and smg
var user_name : String   = ""        # Name of gun user
var damage : int         = 0         # Damage it will cause
var rate_of_fire : float = 0 setget set_rof        # How much bullets it can fire per seconds
var reload_time : float  = 0         # Time taken for reload
var mag_size : int       = 0         # Capacity of a magazine
var bullets_in_mag : int = 4         # bullets left in magazine
var bullets : int        = 0         # bullets remaining other than magazine
var accuracy : float     = 0         #
var recoil_factor : float= 0         #
var zoom_range           = []
var penetration_ratio : float= 0.3   #

var is_reloading : bool = false           # flag for reloading

# Nodes
onready var timer        = get_node("Timer")
onready var reload_timer = get_node("reload_timer")
onready var recoil_reset = get_node("recoil_reset_timer")
onready var muzzle_sfx   = get_node("muzzle")
onready var muzzle_flash = get_node("muzzle_flash")
onready var clip_in_sfx = get_node("clip_in") 
onready var clip_out_sfx = get_node("clip_out") 
onready var level        = get_tree().get_nodes_in_group("Levels")[0]
onready var resource     = get_tree().root.get_node("Resources")


# Variables
var _recoil  : float  = 0
var cast_to : Vector2 = Vector2.ZERO
var fired : bool = false
var cur_frame = 0
var cur_zoom_id = 0
var user_ref = null
const frames = 4

signal gun_fired
signal gun_reloaded


# Set user for this gun
func init(user):
	user_ref = user
	user_name = user.name
	name = wpn_name


func _ready():
	name = wpn_name
	_loadStats()
	_connectSignals()
	_fillAmmo()
	timer.wait_time = 1.0 / rate_of_fire
	reload_timer.wait_time = reload_time


func _connectSignals():
	recoil_reset.connect("timeout", self, "_on_recoil_timer_timeout") 
	reload_timer.connect("timeout", self, "_on_reload_complete")


func set_rof(value):
	rate_of_fire = value
	timer.wait_time = 1.0 / rate_of_fire
	reload_timer.wait_time = reload_time


func _loadStats():
	var stats = resource.gun_stats.get(wpn_name)
	damage       = stats.damage
	rate_of_fire = stats.rate_of_fire
	reload_time  = stats.reload_time
	mag_size     = stats.mag_size
	accuracy     = stats.accuracy
	recoil_factor= stats.recoil_factor
	type         = stats.type
	zoom_range   = stats.zoom_range
	penetration_ratio = stats.penetration_ratio


func fireGun():
	if bullets_in_mag > 0 && !is_reloading && timer.is_stopped():
		# muzzle_sfx.stream = fire_sounds[randi() % fire_sounds.size()]
		muzzle_sfx.play()
		bullets_in_mag -= 1
		timer.start()
		var error_angle = simulateGunFire()
		rpc_id(1, "S_fireGun", error_angle)
		update()
		showMuzzleFlash()
		emit_signal("gun_fired")


func showMuzzleFlash():
	cur_frame = frames
	muzzle_flash.scale = Vector2(rand_range(0.8, 1.2), rand_range(0.8, 1.2))
	muzzle_flash.show()


func reload():
	if !is_reloading && bullets > 0 && bullets_in_mag != mag_size:
		reload_timer.start()
		is_reloading = true
		clip_out_sfx.play()


func _on_reload_complete():
	clip_in_sfx.play()
	_reload()


func _reload():
	var decrement = min(mag_size - bullets_in_mag, bullets)
	bullets -= decrement
	bullets_in_mag += decrement
	is_reloading = false
	emit_signal("gun_reloaded")


func simulateGunFire() -> float:
	var spread = (1 - accuracy) / 4
	var error_angle = rand_range(-spread - _recoil * 0.01,spread + _recoil * 0.01)
	_recoil += recoil_factor
	# No need to simulate gunfire for server
	if !get_tree().is_network_server():
		cast_to = Vector2(0,-750).rotated(global_rotation + error_angle) + global_position
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, cast_to, [self])
		if result:
			cast_to = result.position

	recoil_reset.start()
	return error_angle


func _draw():
	if cur_frame != 0:
		draw_line(muzzle_sfx.position, (cast_to -
		muzzle_sfx.global_position).rotated(-global_rotation) + muzzle_sfx.position, Color(255,250,0),1.25)


func _process(_delta):
	cur_frame = max(0, cur_frame - 1)
	if cur_frame == 0:
		muzzle_flash.hide()
		update()


# Custom function for is_network_master
func isNetworkServer():
	return user_name == String(get_tree().get_network_unique_id())


func _on_recoil_timer_timeout():
	_recoil = 0


func zoom():
	print("zooming")
	cur_zoom_id += 1
	if cur_zoom_id >= zoom_range.size():
		cur_zoom_id = 0
	if user_ref.is_network_master():
		user_ref.get_node("camera").zoom = Vector2(zoom_range[cur_zoom_id], zoom_range[cur_zoom_id])
	

func resetZoom():
	cur_zoom_id = 0
	if user_ref.is_network_master():
		user_ref.get_node("camera").zoom = Vector2(zoom_range[cur_zoom_id], zoom_range[cur_zoom_id])


func _fillAmmo():
	bullets_in_mag = mag_size
	bullets = mag_size * 3

# Networking

# remotesync func _fire():
# 	var bullet = resource.bullets.get(cur_bullet_type).instance()
# 	bullet.init(-global_transform.y, damage, user_name, wpn_name)
# 	bullet.position = muzzle_sfx.global_position
# 	level.add_child(bullet)
# 	muzzle_sfx.stream = fire_sounds[randi() % fire_sounds.size()]
# 	muzzle_sfx.play()


#server only method
remotesync func S_fireGun(error_angle : float):
	cast_to = Vector2(0,-750).rotated(global_rotation + error_angle) + global_position
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, cast_to, [self])
	if result:
		cast_to = result.position
		if result.collider.is_in_group("Destructible"):
			result.collider.takeDamage(damage, penetration_ratio, user_name, wpn_name)
	rpc("C_fireGun",cast_to)



remotesync func C_fireGun(dest : Vector2):
	if !isNetworkServer():
		cast_to = dest
		muzzle_sfx.play()
		update()
		showMuzzleFlash()
