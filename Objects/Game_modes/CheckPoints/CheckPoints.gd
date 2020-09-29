extends CanvasLayer


var mode_settings = {
	round_time = 8, # Round time limit in minutes
	max_score = 500
}

var time_elasped = 0
var checkpoints = Array()
var focused_point = null

onready var timer_label = $top_panel/Label
onready var points_node = $top_panel/points
onready var progress_bar = $top_panel/ProgressBar

func _ready():
	checkpoints = get_tree().get_nodes_in_group("CheckPoint")
	for i in checkpoints:
		i.connect("team_captured_point", self, "P_on_team_captured_point")
		i.connect("local_player_entered", self, "P_on_local_player_entered")
		i.connect("local_player_exited", self, "P_on_local_player_exited")
		


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


func P_on_team_captured_point(point):
	var rect = points_node.get_node(String(point.id))
	if point.holding_team == 0:
		rect.color = Color8(201, 55, 31)
	else:
		rect.color = Color8(17,64, 194)


func P_on_local_player_entered(point):
	focused_point = point
	progress_bar.value = point.value
	progress_bar.max_value = point.max_points
	progress_bar.show()


func P_on_local_player_exited():
	focused_point = null
	progress_bar.hide()


func _process(_delta):
	if focused_point:
		progress_bar.value = focused_point.value

