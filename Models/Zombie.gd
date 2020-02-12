extends "res://Models/Model.gd"

var is_monster : bool = false

####################################
var lhand_detached = false
var lhand_pos : Vector2
var lhand_rot : float

func _ready():
	is_monster = parent.is_in_group("Monster")
	if parent and is_monster:
		parent.connect("char_took_damage",self,"_on_damaged")

func _process(delta):
	if is_monster:
		if parent.movement_vector.length() and current_anim != "zm_w":
			$anim.play("zombie_walk")
			current_anim = "zm_w"
		if lhand_detached:
			$arml.global_position = lhand_pos
			$arml.global_rotation = lhand_rot


func _on_damaged():
	if parent.HP < 50 and not lhand_detached:
		lhand_detached = true
		lhand_pos = $arml.global_position
		lhand_rot = $arml.global_rotation
		$arml.skeleton = NodePath("")



