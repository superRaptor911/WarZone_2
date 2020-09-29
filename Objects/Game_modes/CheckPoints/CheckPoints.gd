extends CanvasLayer


var mode_settings = {
	round_time = 8, # Round time limit in minutes
	max_score = 500
}

var time_elasped = 0

onready var timer_label = $top_panel/Label


func _on_Timer_timeout():
	time_elasped += 1
	rpc_unreliable("P_syncTime", time_elasped)


remotesync func P_syncTime(time : int):
	time_elasped = time
	# Show time remaining in panel
	var time_limit = mode_settings.round_time * 60
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


