extends CollisionShape2D

onready var entity                         = get_parent()
onready var fist : Node2D                  = get_node("fist")
onready var skin : Sprite                  = get_node("skin")
onready var anim_player : AnimationPlayer  = get_node("AnimationPlayer")
onready var walk_sfx : AudioStreamPlayer2D = get_node("walk")
onready var die_sfx : AudioStreamPlayer2D  = get_node("die")



func _ready():
	if entity && !entity.is_in_group('Entities'):
		entity = null
	if entity:
		_connectSignals()


func _connectSignals():
	entity.connect("entity_took_damage", self, "_on_damaged")
	entity.connect("entity_killed", self, "_on_killed")
	entity.connect("entity_revived", self, "_on_revived")



func _on_damaged(_attacker):
	if GlobalData.settings.gore:
		pass


func _on_killed(_victim_name, _killer):
	dieAnim()
	if GlobalData.settings.gore:
		pass


func _on_revived():
	reviveAnim()

func changePose(pose_name):
	anim_player.play(pose_name)


func holdWeapon(weapon):
	for i in fist.get_children():
		i.remove_child(i)
	fist.add_child(weapon)
	changePose(weapon.type)


func _process(_delta):
	if anim_player.current_animation == "walk":
		if entity.direction.length_squared() == 0:
			anim_player.play("stop")
	elif entity.direction.length_squared() != 0:
		anim_player.play("walk")


func dieAnim():
	die_sfx.play()
	skin.hide()
	self.call_deferred("set", "disabled" , true)
	

func reviveAnim():
	skin.show()
	self.call_deferred("set", "disabled" , false)
