extends "res://Objects/Misc/TeamSelect.gd"

signal team_selected(team)

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_T_pressed()


func _on_T_pressed():
	if selected_btn:
		if selected_btn != $TeamSelect/container/T:
			$TeamSelect/container/T.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $TeamSelect/container/T
			changePanelTween("T_join")
	else:
		selected_btn = $TeamSelect/container/T
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("T_join")
		


func _on_CT_pressed():
	if selected_btn:
		if selected_btn != $TeamSelect/container/CT:
			$TeamSelect/container/CT.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $TeamSelect/container/CT
			changePanelTween("CT_join")
	else:
		selected_btn = $TeamSelect/container/CT
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("CT_join")


func _on_Tjoin_btn_pressed():
	emit_signal("team_selected",0)


func _on_CT_join_btn_pressed():
	emit_signal("team_selected",1)
