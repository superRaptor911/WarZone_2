extends "res://Objects/Misc/TeamSelect.gd"

signal team_selected(team)

func _ready():
	_on_CT_pressed()

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


func _on_CT_join_btn_pressed():
	emit_signal("team_selected",1)
