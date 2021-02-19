extends CollisionShape2D

onready var entity = get_parent()
onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")


func _ready():
	if entity && !entity.is_in_group('Entities'):
		entity = null
	if entity:
		_connectSignals()


func _connectSignals():
	entity.connect("entity_took_damage", self, "_on_damaged")
	entity.connect("entity_killed", self, "_on_killed")



func _on_damaged(_attacker):
	pass


func _on_killed(_victim_name, _killer):
	pass


func _process(_delta):
	if anim_player.current_animation == "walk":
		if entity.direction.length_squared() == 0:
			anim_player.play("stop")
	elif entity.direction.length_squared() != 0:
			anim_player.play("walk")

