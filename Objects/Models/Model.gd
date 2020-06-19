class_name Model
extends CollisionShape2D

#export(String, MULTILINE) var model_desc : String = "Britsh Special forces"

var is_walking : bool = false
var playing : bool = false
var movement_count = 0
var parent = null
var current_gun : Gun = null
var skin_name = ""
onready var fist = $skin/sfist

export var sk_name = ""


func _ready():
	if sk_name != "" && skin_name != sk_name:
		setSkin(sk_name)
	
	fist.global_scale = Vector2(1,1)
	parent = get_parent()
	if parent:
		parent.connect("char_took_damage", self, "_on_char_damaged")
		parent.connect("char_killed", self, "_on_char_killed")
		parent.connect("char_born",self,"_on_char_born")
	

func setSkin(s_name):
	var skin_texture = game_states.skinResource.get(s_name)
	if skin_texture:
		$skin.texture = skin_texture
		skin_name = s_name
	else:
		print_debug("Skin %s not found", s_name)


func _process(_delta):
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


#reset/remove selected gun
func resetGunSelection():
	if current_gun:
		fist.remove_child(current_gun)
	current_gun = null


#switch gun and change fist
func switchGun(gun : Gun):
	if current_gun:
		fist.remove_child(current_gun)
	
	if gun.gun_type == "pistol":
		fist = $skin/pfist
		$skin.frame = 3
	else:
		$skin.frame = 4
		fist = $skin/sfist
	
	current_gun = gun
	fist.add_child(current_gun)
	fist.global_scale = Vector2(1,1)
	fist.show()


#do melee animation
#returns true if did melee attack
func doMelee() -> bool:
	if $mele_delay.is_stopped():
		parent.pause_controls(true)
		$AnimationPlayer.play("melee")
		$mele_delay.start()
		return true
	return false

#function called when character took damage
#used for blinking effect when on low hp
func _on_char_damaged():
	if parent.HP < 50:
		$skin.material.set_shader_param("use",1.0)
		$skin.material.set_shader_param("tex_size",Vector2(64,64))
	else:
		$skin.material.set_shader_param("use",0.0)
		$skin.material.set_shader_param("tex_size",Vector2(0,0))

func _on_char_killed():
	$skin.material.set_shader_param("use",0.0)
	$skin.material.set_shader_param("tex_size",Vector2(0,0))
	$blood_scat.show()
	$skin.hide()
	fist.hide()
	$walking.stop()
	
func _on_char_born():
	$blood_scat.hide()
	$skin.show()
	fist.show()
	$skin.material.set_shader_param("use",0.0)
	$skin.material.set_shader_param("tex_size",Vector2(0,0))

func revive():
	_on_char_born()

#function called when melee animation is finished
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "melee":
		parent.pause_controls(false)
		

