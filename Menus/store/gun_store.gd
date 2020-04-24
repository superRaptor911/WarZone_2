extends CanvasLayer

export var nade_img : Texture
var gun_data_format = ("Name : %s\nGun Type : %s\nDamage : %d\nClip Size : %d\nCost : $%d\nRpm : %d")
var grenade_cost = 50

class WeaponType:
	var wpn_type = ""
	var weapons = Array()
	var current_wpn = null
	var cur_wpn_id = 0
	
	func _init(t):
		wpn_type = t
	#sort by cost
	static func sort(a,b) -> bool:
		return a.wpn_cost < b.wpn_cost

var weapon_types = Array()
var current_type = null

func _ready():
	initWeaponTypes()
	loadWeapons()
	initialTween()
	$cash.text = "$" + String(game_states.player_data.cash)

func initWeaponTypes():
	var pistols = WeaponType.new("pistol")
	var smg = WeaponType.new("smg")
	var rifle = WeaponType.new("rifle")
	var nades = WeaponType.new("nades")
	var armour = WeaponType.new("armour")
	
	weapon_types.append(pistols)
	weapon_types.append(smg)
	weapon_types.append(rifle)
	weapon_types.append(nades)
	weapon_types.append(armour)


func loadWeapons():
	var values : Array = game_states.weaponResource.values()
	for i in values:
		var o = i.instance()
		for j in weapon_types:
			if j.wpn_type == o.gun_type:
				j.weapons.append(o)
				break
		
	for i in weapon_types:
		i.weapons.sort_custom(WeaponType,"sort")
	
	setCurrentWeaponType("pistol")


func setCurrentWeaponType(type):
	if (not current_type) or current_type.wpn_type != type:
		for i in weapon_types:
			if i.wpn_type == type:
				current_type = i
				break
	$icon/TextureRect.texture = null
	if current_type:
		if not current_type.weapons.empty():
			current_type.current_wpn = current_type.weapons[0]
			$icon/TextureRect.texture = current_type.current_wpn.gun_portrait
			setGunInfo()
			#current_type.wpn_type = type
	


func setGunInfo():
	var w = current_type.current_wpn
	$gun_desc/Label.text = gun_data_format % [w.gun_name,w.gun_type,w.damage,w.rounds_in_clip,w.wpn_cost,w.rate_of_fire * 60]


func _on_pistol_pressed():
	MusicMan.click()
	setCurrentWeaponType("pistol")


func _on_smg_pressed():
	MusicMan.click()
	setCurrentWeaponType("smg")


func _on_rifle_pressed():
	MusicMan.click()
	setCurrentWeaponType("rifle")


func _on_nades_pressed():
	MusicMan.click()
	setCurrentWeaponType("nades")
	setNadeInfo()


func _on_armour_pressed():
	MusicMan.click()
	setCurrentWeaponType("armour")


func _on_next_wpn_pressed():
	if current_type.weapons.size() > 1:
		MusicMan.click()
		current_type.cur_wpn_id += 1
		if current_type.cur_wpn_id >= current_type.weapons.size():
			current_type.cur_wpn_id = 0
		current_type.current_wpn = current_type.weapons[current_type.cur_wpn_id] 
		$icon/TextureRect.texture = current_type.current_wpn.gun_portrait
		setGunInfo()

func _on_prev_wpn_pressed():
	if current_type.weapons.size() > 1:
		MusicMan.click()
		current_type.cur_wpn_id -= 1
		if current_type.cur_wpn_id < 0:
			current_type.cur_wpn_id = current_type.weapons.size() - 1
		current_type.current_wpn = current_type.weapons[current_type.cur_wpn_id] 
		$icon/TextureRect.texture = current_type.current_wpn.gun_portrait
		setGunInfo()

func _on_purchase_pressed():
	if current_type.wpn_type != "armour" and current_type.wpn_type != "explosive":
		MusicMan.click()
		purchaseGun()

func purchaseGun():
	if current_type.wpn_type == "nades":
		if game_states.player_data.cash >= grenade_cost:
			game_states.player_data.cash -= grenade_cost
			game_states.player_data.nade_count += 1
			$cash.text = "$" + String(game_states.player_data.cash)
			$gun_desc/Label.text = ("High Explosive grenade.\nPrice : " + String(grenade_cost)
			+ "\nYou Have : " + String(game_states.player_data.nade_count))
			game_states.savePlayerData()
		return
		
	var w = current_type.current_wpn.gun_name
	for i in game_states.player_data.guns:
		if i.gun_name == w:
			$purchase_fail/Label.text = "You own this"
			$purchase_fail.popup_centered()
			return
	
	if game_states.player_data.cash >= current_type.current_wpn.wpn_cost:
		game_states.player_data.cash -= current_type.current_wpn.wpn_cost
		var gun = { gun_name = "", laser = false, mag_ext = false}
		gun.gun_name = w
		game_states.player_data.guns.append(gun)
		$cash.text = "$" + String(game_states.player_data.cash)
		game_states.savePlayerData()
	else:
		$purchase_fail/Label.text = "Insufficient Funds"
		$purchase_fail.popup_centered()


func _on_back_pressed():
	MusicMan.click()
	for i in weapon_types:
		for j in i.weapons:
			j.queue_free()
		
	MenuManager.changeScene("storeMenu")


func setNadeInfo():
	$icon/TextureRect.texture = nade_img
	$gun_desc/Label.text = ("High Explosive grenade.\nPrice : " + String(grenade_cost)
	+ "\nYou Have : " + String(game_states.player_data.nade_count))

####################Tweening##########################

func initialTween():
	var duration = 0.5
	#tween gun desc
	var node = $gun_desc
	var old_rectpos = node.rect_position
	node.rect_position += Vector2(400,0) 
	$Tween.interpolate_property(node,"rect_position",node.rect_position,
		old_rectpos,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween icon
	node = $icon
	old_rectpos = node.rect_position
	node.rect_position -= Vector2(0,400) 
	$Tween.interpolate_property(node,"rect_position",node.rect_position,
		old_rectpos,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween wepon types
	node = $weapon_types
	old_rectpos = node.rect_position
	node.rect_position -= Vector2(400,0) 
	$Tween.interpolate_property(node,"rect_position",node.rect_position,
		old_rectpos,duration,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()
