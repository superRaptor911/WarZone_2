extends Node

var nodes_to_clean = [
		"NetworkManager",
		"LevelManager",
		"Resources"
	]


func cleanUP():
	print("Cleanup::cleanup in progress")
	get_tree().network_peer = null
	print("Cleanup::clearing Level")
	get_tree().get_nodes_in_group("Levels")[0].queue_free()
	for i in nodes_to_clean:
		print("Cleanup::clearing " + i)
		get_tree().root.get_node(i).queue_free()
	
	print("Cleanup::Switching to main menu")
	UImanager.changeMenuTo("main_menu")
	queue_free()
