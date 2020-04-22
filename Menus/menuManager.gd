extends Node

var menu : Dictionary
var current_menu = null

var max_menus = 10
var menu_loaded = 0
var loading_menu

func _ready():
	if !get_tree().get_nodes_in_group("LoadMenu").empty():
		loading_menu = get_tree().get_nodes_in_group("LoadMenu")[0]
		loading_menu.connect("loading_complete",self, "on_loaded")
		loadMenu()

func loadMenu():
	addMenu("mainMenu","res://Menus/MainMenu/MainMenu.tscn")
	addMenu("once","res://Menus/MainMenu/once.tscn")
	addMenu("newGame","res://Menus/MainMenu/NewGame.tscn")
	addMenu("storeMenu","res://Menus/store/store_menu.tscn")
	addMenu("joinMenu","res://Menus/MainMenu/Join_menu.tscn")
	addMenu("hostMenu","res://Menus/MainMenu/host_menu.tscn")
	addMenu("settings","res://Menus/Settings/Settings.tscn")
	addMenu("stats","res://Menus/MainMenu/Stats.tscn")
	addMenu("summary","res://Menus/Misc/Summary.tscn")
	
	
	#sub menu of store menu
	addMenu("SM/gunStore","res://Menus/store/gun_store.tscn")
	addMenu("SM/gunSelection","res://Menus/store/gun_selection.tscn")
	addMenu("SM/skinBuy","res://Menus/store/SkinBuy.tscn")
	addMenu("SM/skinSelect","res://Menus/store/skinSelect.tscn")
	
	#sub menu of host menu
	addMenu("HM/lobby","res://Menus/Lobby/Lobby.tscn")
	
	finishLoading()

func addMenu(name,path):
	menu[name] = load(path)
	menu_loaded += 1
	loading_menu.get_node("ProgressBar").value = min((menu_loaded / max_menus) * 100.0, 99)

func finishLoading():
	loading_menu.get_node("ProgressBar").value = 100

func changeScene(new_scene):
	if menu.get(new_scene):
		get_tree().change_scene_to(menu.get(new_scene))
	else:
		print("Error changing scene to ", new_scene)

func on_loaded():
	if game_states.first_run:
		changeScene("once")
	else:
		changeScene("mainMenu")
