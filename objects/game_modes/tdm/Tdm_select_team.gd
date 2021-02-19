extends CanvasLayer

onready var terrorist_button : Button = get_node("Panel/container/t")
onready var counter_terrorist_button : Button = get_node("Panel/container/ct")
onready var spectate_button : Button = get_node("Panel/container/spectate")


func _ready():
	_connectSignals()


func _connectSignals():
	terrorist_button.connect("pressed", self, "_on_terrorist_selected")
	counter_terrorist_button.connect("pressed", self, "_on_counter_terrorist_selected")
	spectate_button.connect("pressed", self, "_on_spectate_selected")


# Team id 0
func _on_terrorist_selected():
	var level = get_tree().get_nodes_in_group("Levels")[0]
	level.get_node("SpawnManager").spawnOurPlayer(0)
	queue_free()


# Team id 1
func _on_counter_terrorist_selected():
	var level = get_tree().get_nodes_in_group("Levels")[0]
	level.get_node("SpawnManager").spawnOurPlayer(1)
	queue_free()


# NOTE : To do
func _on_spectate_selected():
	pass
