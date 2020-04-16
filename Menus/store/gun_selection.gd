extends CanvasLayer




func _on_laser_pressed():
	$buy.show()
	$AnimationPlayer.play("buy_popup")
