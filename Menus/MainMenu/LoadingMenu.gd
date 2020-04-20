extends CanvasLayer

signal loading_complete


func _on_ProgressBar_value_changed(value):
	if value == 100:
		emit_signal("loading_complete")
		queue_free()
