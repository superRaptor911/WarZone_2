extends CanvasLayer

var checkpoints

func _ready():
	checkpoints = get_tree().get_nodes_in_group("CheckPoint")
	if checkpoints.empty():
		Logger.LogError("_ready of CCP","No checkpoints found")
		Logger.notice.showNotice(self, "Error", "No checkpoints found", Color.red)
	
	
