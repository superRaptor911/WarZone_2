extends Node

# Dictionary of menu
var menu : Dictionary
var prev_menu = null
var cur_menu = null

# Admob instance
var admob : AdMob = null
# Number of times to load ads if loading fails
var _admob_max_load_fails = 2
# Counter for each ad types [banner, intestitial, video]
var _admob_load_fail_count = [0, 0, 0]

# This signal is emitted when back button is pressed
signal back_pressed

func _ready():
	setupAds()
	loadMenus()

func addMenu(name,path):
	menu[name] = load(path)

func loadMenus():
	addMenu("mainMenu","res://Menus/MainMenu/MainMenu.tscn")
	addMenu("once","res://Menus/MainMenu/once.tscn")
	addMenu("newGame","res://Menus/MainMenu/NewGame.tscn")
	addMenu("storeMenu","res://Menus/store/store_menu.tscn")
	addMenu("joinMenu","res://Menus/MainMenu/Join_menu.tscn")
	addMenu("hostMenu","res://Menus/MainMenu/host_menu.tscn")
	addMenu("settings","res://Menus/Settings/Settings.tscn")
	addMenu("stats","res://Menus/MainMenu/Stats.tscn")
	addMenu("summary","res://Menus/Misc/Summary.tscn")
	addMenu("extras", "res://Menus/MainMenu/ExtrasMenu.tscn")
	addMenu("EditorMapSelector","res://Menus/Editor/EditorMapSelector.tscn")
	addMenu("CommunityMenu", "res://Menus/community/comMenu.tscn")
	
	
	#sub menu of store menu
	addMenu("SM/gunStore","res://Menus/store/gun_store.tscn")
	addMenu("SM/gunSelection","res://Menus/store/gun_selection.tscn")
	addMenu("SM/skinBuy","res://Menus/store/SkinBuy.tscn")
	addMenu("SM/skinSelect","res://Menus/store/skinSelect.tscn")
	
	#sub menu of host menu
	addMenu("HM/lobby","res://Menus/Lobby/Lobby.tscn")
	
	#sub menu of settings
	addMenu("set/logViewer", "res://Menus/Misc/LogViewer.tscn")
	
	#Sub menus of Editor map selector
	addMenu("EMS/LevelEditorMenu","res://Menus/Editor/LevelEditorMenu.tscn")
	addMenu("EMS/LEM/LevelEditor", "res://Menus/Editor/LevelEditor.tscn")
	addMenu("EMS/LEM/GameModesMenu", "res://Menus/Editor/GameModesMenu.tscn")
	addMenu("EMS/LEM/GMM/TDM", "res://Menus/Editor/TDMspawnEditor.tscn")
	addMenu("EMS/LEM/GMM/ZM", "res://Menus/Editor/ZMspawnEditor.tscn")
	
	#sub Menu of Community menu
	addMenu("CM/ComMapMenu", "res://Menus/community/Maps/ComMapsMenu.tscn")
	
	# Sub menu of extras
	addMenu("Extras/MsgDev", "res://Menus/Misc/MsgDev.tscn")
	addMenu("Extras/Attrib", "res://Menus/Misc/Attrib.tscn")
	
	# Sub menu of settings
	addMenu("settings/display", "res://Menus/Settings/DisplaySettings.tscn")
	addMenu("settings/control", "res://Menus/Settings/JoySettings.tscn")


func changeScene(new_scene):
	if menu.get(new_scene):
		prev_menu = cur_menu
		cur_menu = new_scene
		get_tree().change_scene_to(menu.get(new_scene))
		admob.hide_banner()
	else:
		print("Error changing scene to ", new_scene)


func changeSceneToPrevious():
	changeScene(prev_menu)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Back_pressed()
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		#get_tree().quit(0)
		_on_Back_pressed()


func _on_Back_pressed():
	admob.hide_banner()
	emit_signal("back_pressed")

######################################ADS######################################

func setupAds():
	randomize()
	var banners = [
		"ca-app-pub-9443221640471166/9049742329",
		"ca-app-pub-9443221640471166/6136808642",
		"ca-app-pub-9443221640471166/1591918779"
		]
	var interstitials = [
		"ca-app-pub-9443221640471166/1781147462",
		"ca-app-pub-9443221640471166/1978071782",
		"ca-app-pub-9443221640471166/7774183742"
	]
	var videos = [
		"ca-app-pub-9443221640471166/2680609241"
	]
	
	if admob:
		admob.queue_free()
	
	admob = AdMob.new()
	admob.is_real = false
	admob.max_ad_content_rate = "MA"
	admob.banner_id = banners[randi() % banners.size()]
	admob.interstitial_id = interstitials[randi() % interstitials.size()]
	admob.rewarded_id = videos[randi() % videos.size()]
	add_child(admob)
	admob.load_banner()
	admob.load_interstitial()
	#admob.load_rewarded_video()
	admob.hide_banner()
	admob.connect("interstitial_closed", self, "on_interstitial_closed")
	admob.connect("rewarded_video_closed", self, "on_video_closed")
	
	admob.connect("banner_loaded", self, "on_banner_loaded")
	admob.connect("interstitial_loaded", self, "on_interstitial_loaded")
	admob.connect("rewarded_video_loaded", self, "on_video_loaded")
	
	admob.connect("banner_failed_to_load", self, "on_banner_failed")
	admob.connect("interstitial_failed_to_load", self , "on_interstitial_failed")
	admob.connect("rewarded_video_failed_to_load", self, "on_video_failed")


func on_interstitial_closed():
	admob.load_interstitial()

func on_video_closed():
	admob.load_rewarded_video()

func on_banner_loaded():
	_admob_load_fail_count[0] = 0

func on_interstitial_loaded():
	_admob_load_fail_count[1] = 0

func on_video_loaded():
	_admob_load_fail_count[2] = 0

func on_banner_failed(_code):
	_admob_load_fail_count[0] += 1
	if _admob_load_fail_count[0] < _admob_max_load_fails:
		admob.load_banner()

func  on_interstitial_failed(_code):
	_admob_load_fail_count[1] += 1
	if _admob_load_fail_count[1] < _admob_max_load_fails:
		admob.load_interstitial()

func on_video_failed(_code):
	_admob_load_fail_count[2] += 1
	if _admob_load_fail_count[2] < _admob_max_load_fails:
		admob.load_rewarded_video()


func showInterstitialAd():
	if admob._is_interstitial_loaded:
		admob.show_interstitial()

func showBannerAds():
	if admob._is_banner_loaded:
		admob.show_banner()
