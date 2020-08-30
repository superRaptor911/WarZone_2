extends Node2D


func _ready():
	var uploader = DataUploader.new()
	var dat = uploader.getFile("minimapDownloader.php", {map = "", author = ""})
	var image = Image.new()
	var image_error = image.load_png_from_buffer(dat)
	if image_error != OK:
		print("An error occurred while trying to display the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	$Sprite.texture = texture
	print("done..........")
