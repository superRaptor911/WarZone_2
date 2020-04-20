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
	addMenu("storeMenu","res://Menus/store/store_menu.tscn")
	addMenu("joinMenu","res://Menus/MainMenu/Join_menu.tscn")
	addMenu("hostMenu","res://Menus/MainMenu/host_menu.tscn")
	addMenu("settings","res://Menus/Settings/Settings.tscn")
	
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
	loading_menu.get_node("ProgressBar").value = (menu_loaded / max_menus) * 100.0 - 1

func finishLoading():
	loading_menu.get_node("ProgressBar").value = 100

func changeScene(new_scene):
	get_tree().change_scene_to(menu.get(new_scene))

func on_loaded():
	changeScene("mainMenu")
