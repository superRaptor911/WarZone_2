extends Control

onready var langButtons = $Panel/VBoxContainer.get_children()
signal lang_changed

func _ready():
	for i in langButtons:
		i.connect("pressed_text", self, "_on_lang_selected")


func _on_lang_selected(lang):
	TranslationServer.set_locale(lang)
	game_states.game_settings.lang = lang
	game_states.saveSettings()
	emit_signal("lang_changed")
