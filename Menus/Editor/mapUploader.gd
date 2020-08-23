extends Control

func _ready():
	var download = DataUploader.new()
	var data = download.getData("getLevels.php")
