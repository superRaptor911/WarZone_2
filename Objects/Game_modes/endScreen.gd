extends Panel

signal ok


func _ready():
	var ct_score = 0
	var t_score = 0
	var pl_dat = game_server._unit_data_list.values()
	for i in pl_dat:
		if i.ref.team_id == 0:
			t_score += i.ref.score
		else:
			ct_score += i.ref.score
	setScore(t_score,ct_score)
 

func setScore(t_score,ct_score):
	$CT/score.text = String(ct_score)
	$T/score2.text  = String(t_score)
	if ct_score < t_score:
		$winner.text = "T WIN"


func _process(_delta):
	$ok.text = String(int($Timer.time_left))

func _on_ok_pressed():
	pass


func _on_Timer_timeout():
	emit_signal("ok")
	queue_free()
