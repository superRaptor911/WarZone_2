extends Control

signal got_selected(tile)

func setData(tex : Texture, vframes, hframes, frame):
	var spr = $Sprite
	spr.texture = tex
	spr.vframes = vframes
	spr.hframes = hframes
	spr.frame = frame

func highlightTile():
	$Sprite.modulate = Color8(62,175,224)

func unhighlightTile():
	$Sprite.modulate = Color8(255,255,255,255)




func _on_Area2D_input_event(viewport, event, shape_idx):
	pass

func _on_Tile_gui_input(event):
	
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			emit_signal("got_selected", self)
