extends Node

var level_dirs = [
	"res://resources/levels/"
]


func getLevels() -> Array:
	var levels = []
	for i in level_dirs:
		levels += Utility.scanDir(i, 'd')
	print("ReadLevels::Found %d levels" % [levels.size()])
	return levels


func getLevelModes(level_name) -> Dictionary:
	for i in level_dirs:
		if Utility.dirExists(i + level_name):
			var mode_info = Utility.loadDictionary(i + level_name + "/level_info.rjs")
			return mode_info.keys()
	return {}
