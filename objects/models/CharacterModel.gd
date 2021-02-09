extends CollisionShape2D

onready var entity = get_parent()


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


func _on_killed(_killer):
	pass
