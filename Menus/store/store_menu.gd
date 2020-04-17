extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	initialTween()


func _on_back_pressed():
	get_tree().change_scene("res://Menus/MainMenu/MainMenu.tscn")


func _on_bw_pressed():
	get_tree().change_scene("res://Menus/store/gun_store.tscn")


func _on_sw_pressed():
	get_tree().change_scene("res://Menus/store/gun_selection.tscn")

####################Tweeening###########################

func initialTween():
	var duration = 0.5
	var node = $Panel
	node.rect_pivot_offset = node.rect_size / 2
	node.rect_scale = Vector2(0.01,0.01)
	$Tween.interpolate_property(node,"rect_scale",node.rect_scale,
		Vector2(1,1),duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()


