extends CollisionShape2D
class_name Model

export var model_name : String = "Model"

var is_walking : bool = false
var playing : bool = false
var multiplier : float = 1
var movement_count = 0
var current_anim = ""
var parent = null
var fist


func _ready():
	fist = $sfist
	parent = get_parent()
	parent.connect("char_took_damage", self, "_on_char_damaged")
	parent.connect("char_killed", self, "_on_char_killed")


func _process(delta):
	if parent.alive:
		walking()
	#fist.rotation = rotation - 1.57

func walking():
	if parent.movement_vector.length() or is_walking:
		movement_count = 0
		if not $walk.playing:
		
			$walk.play()
		if not playing:
			$walking.play("walking")
			playing = true
	else:
		if movement_count > 3:
			$walking.play("idle")
		playing = false
		movement_count += 1

func switchGun(gun_type):
	if gun_type == "pistol":
		fist = $pfist
		$skin.frame = 3
	elif gun_type == "smg":
		$skin.frame = 4
		fist = $sfist

func _on_gun_fired():
	pass

func _on_gun_reload():
	return
	if current_anim == "smg":
		$anim.play("smg_reload")



func _on_killed():
	$blood_scat.show()
	$skin.hide()
	$anim.stop()
	$anim.play("smg_reload")
	$walking.stop()
	
func revive():
	$blood_scat.hide()
	$skin.show()

func _on_char_damaged():
	return
	if parent.HP < 50:
		$skin.material.set_shader_param("use",1.0)
		$skin.material.set_shader_param("tex_size",Vector2(64,64))
	else:
		$skin.material.set_shader_param("use",0.0)
		$skin.material.set_shader_param("tex_size",Vector2(0,0))

func _on_char_killed():
	return
	$skin.material.set_shader_param("use",0.0)
	$skin.material.set_shader_param("tex_size",Vector2(0,0))
