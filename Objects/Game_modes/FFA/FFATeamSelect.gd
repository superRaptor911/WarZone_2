extends "res://Objects/Misc/TeamSelect.gd"

signal team_selected(team)

func _ready():
	_on_Join_pressed()

func _on_Join_pressed():
	if selected_btn:
		if selected_btn != $container/Join:
			$container/Join.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $container/Join
			changePanelTween("join_panel")
	else:
		selected_btn = $container/Join
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("join_panel")


func _on_join_btn_pressed():
	emit_signal("team_selected",0)
