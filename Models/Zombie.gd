extends "res://Models/Model.gd"

var is_monster : bool = false

####################################
var lhand_detached = false
var lhand_pos : Vector2
var lhand_rot : float

var rhand_detached = false
var rhand_pos : Vector2
var rhand_rot : float

func _ready():
	is_monster = parent.is_in_group("Monster")
	if parent and is_monster:
		parent.connect("char_took_damage",self,"_on_damaged")

func _process(delta):
	if is_monster and parent.alive:
		if parent.movement_vector.length() and current_anim != "zm_w" and not $anim.is_playing():
			$anim.play("zombie_walk")
			current_anim = "zm_w"
		if lhand_detached:
			$body/l_shoulder/arm.global_position = lhand_pos
			$body/l_shoulder/arm.global_rotation = lhand_rot
		if rhand_detached:
			$body/r_shoulder/arm.global_position = rhand_pos
			$body/r_shoulder/arm.global_rotation = rhand_rot


func _on_damaged():
	if parent.HP < 55 and not lhand_detached:
		rpc_unreliable("_detachLeftArm")
	if parent.HP < 25 and not rhand_detached:
		rpc_unreliable("_detachRightArm")



remotesync func _detachLeftArm():
	parent.speed *= 0.6
	lhand_detached = true
	lhand_pos = $body/l_shoulder/arm.global_position
	lhand_rot = $body/l_shoulder/arm.global_rotation


remotesync func _detachRightArm():
		parent.speed *= 0.5
		rhand_detached = true
		rhand_pos = $body/r_shoulder/arm.global_position
		rhand_rot = $body/r_shoulder/arm.global_rotation
