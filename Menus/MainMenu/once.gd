extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	game_states.savePlayerData()
	MenuManager.changeScene("mainMenu")


func _on_LineEdit_text_entered(new_text):
	game_states.player_data.name = new_text
	game_states.player_info.name = new_text
	$Panel/Button.disabled = (new_text == "")
