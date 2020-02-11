extends CollisionShape2D
class_name Model

export var model_name : String = "Model"

var is_walking : bool = false
var multiplier : float = 1
var movement_count = 0
var current_anim = ""
var parent

func _ready():
	$anim.play("smg")
	parent = get_parent()

func _process(delta):
	walking()
	$Skeleton2D/boneBody/armr/hand/fist.rotation = -1 * $Skeleton2D/boneBody/armr/hand.rotation + 1.57

func walking():
	if parent.movement_vector.length():
		movement_count = 0
		if not $walk.playing:
		
			$walk.play()
		if not is_walking:
			$walking.play("walking")
			is_walking = true
	else:
		if movement_count > 3:
			$walking.play("idle")
		is_walking = false
		movement_count += 1

func switchGun(gun_type):
	$anim.play("smg_trans")

func _on_gun_fired():
	if current_anim == "smg":
		$anim.play("smg_firing") 

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "smg_trans":
		$anim.play("smg")
		current_anim = "smg"
	if anim_name == "smg_firing":
		$anim.play("smg")
		current_anim = "smg"
