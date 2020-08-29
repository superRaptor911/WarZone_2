extends Node2D


func _ready():
	var uploader = DataUploader.new()
	uploader.uploadFile("res://Sprites/WARZONE-512.png", "fileReceiver.php")
	
	print("done..........")
