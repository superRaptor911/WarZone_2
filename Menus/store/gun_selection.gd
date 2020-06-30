extends CanvasLayer

export var laser_tex : Texture
export var mag_tex : Texture

var guns = Array()
var no_slots = 4
var arr_slot_index = 0

var selected_primary_gun = null
var selected_sec_gun = null

var current_gun = null
var selected_item = "l_aser_sight"
var cur_cost = 0


func _ready():
	getGuns()
	selectSelectedWeapons()
	MenuManager.connect("back_pressed", self,"_on_back_pressed")

#get all purchased guns
func getGuns():
	var index = 0
	for i in game_states.player_data.guns:
		guns.append(game_states.weaponResource.get(i.gun_name).instance())
		guns[index]._use_laser_sight= i.laser
		guns[index]._has_extended_mag = i.mag_ext
		if index < no_slots:
			var panel = $weapons/HBoxContainer.get_node("p" + String(index + 1))
			panel.get_node("p" + String(index + 1) + "_btn").texture_normal = guns[index].gun_portrait
		index += 1
		

func selectSelectedWeapons():
	var index = 0
	for i in game_states.player_data.guns:
		if i.gun_name == game_states.player_data.selected_guns[0]:
			selectWeapon(index)
			break
		index += 1
	
	index = 0
	for i in game_states.player_data.guns:
		if i.gun_name == game_states.player_data.selected_guns[1]:
			selectWeapon(index)
			break
		index += 1


#free all loaded guns
func freeGuns():
	for i in guns:
		i.queue_free()


#select weapon when user press weapons panel
func selectWeapon(index):
	if (arr_slot_index + index) < guns.size():
		if guns[arr_slot_index + index].gun_type == "pistol":
			selected_sec_gun = guns[arr_slot_index + index]
			$sec_gun/gun_panel/Label.text = guns[arr_slot_index + index].gun_name
			$sec_gun/gun_panel/texture.texture = guns[arr_slot_index + index].gun_portrait
			$sec_gun/sec_laser.disabled = selected_sec_gun._use_laser_sight
			$sec_gun/sec_clip_ext.disabled = selected_sec_gun._has_extended_mag
		else:
			selected_primary_gun = guns[arr_slot_index + index]
			$primary_gun/gun_panel/Label.text = guns[arr_slot_index + index].gun_name
			$primary_gun/gun_panel/texture.texture = guns[arr_slot_index + index].gun_portrait
			$primary_gun/prim_laser.disabled = selected_primary_gun._use_laser_sight
			$primary_gun/prim_clip_ext.disabled = selected_primary_gun._has_extended_mag


func _on_p1_btn_pressed():
	selectWeapon(0)



func _on_p2_btn_pressed():
	selectWeapon(1)


func _on_p3_btn_pressed():
	selectWeapon(2)

func _on_p4_btn_pressed():
	selectWeapon(3)


func _on_laser_pressed():
	$buy.show()
	$AnimationPlayer.play("buy_popup")


func _on_prim_laser_pressed():
	if $buy.visible:
		return
	$buy/img.texture = laser_tex
	selected_item = "_use_laser_sight"
	current_gun = selected_primary_gun
	cur_cost = 500
	$buy/img/Label.text = "Laser Sight"
	$buy/buy_Button.disabled = (game_states.player_data.cash < cur_cost)
	$buy/cost.text = "Cost : " + String(cur_cost)
	$buy/cash.text = "Cash : " + String(game_states.player_data.cash)
	$buy.show()
	$AnimationPlayer.play("buy_popup")


func _on_prim_clip_ext_pressed():
	if $buy.visible:
		return
	$buy/img.texture = mag_tex
	cur_cost = 500
	selected_item = "_has_extended_mag"
	current_gun = selected_primary_gun
	$buy/img/Label.text = "Mag extender"
	$buy/buy_Button.disabled = (game_states.player_data.cash < cur_cost)
	$buy/cost.text = "Cost : " + String(cur_cost)
	$buy/cash.text = "Cash : " + String(game_states.player_data.cash)
	$buy.show()
	$AnimationPlayer.play("buy_popup")


func _on_sec_laser_pressed():
	if $buy.visible:
		return
	$buy/img.texture = laser_tex
	cur_cost = 500
	selected_item = "_use_laser_sight"
	current_gun = selected_sec_gun
	$buy/img/Label.text = "Laser Sight"
	$buy/buy_Button.disabled = (game_states.player_data.cash < cur_cost)
	$buy/cost.text = "Cost : " + String(cur_cost)
	$buy/cash.text = "Cash : " + String(game_states.player_data.cash)
	$buy.show()
	$AnimationPlayer.play("buy_popup")


func _on_sec_clip_ext_pressed():
	if $buy.visible:
		return
	$buy/img.texture = mag_tex
	cur_cost = 500
	selected_item = "_has_extended_mag"
	current_gun = selected_sec_gun
	$buy/img/Label.text = "Mag extender"
	$buy/buy_Button.disabled = (game_states.player_data.cash < cur_cost)
	$buy/cost.text = "Cost : " + String(cur_cost)
	$buy/cash.text = "Cash : " + String(game_states.player_data.cash)
	$buy.show()
	$AnimationPlayer.play("buy_popup")


func _on_buy_Button_pressed():
	current_gun.set(selected_item,true)
	game_states.player_data.cash -= cur_cost
	$sec_gun/sec_laser.disabled = selected_sec_gun._use_laser_sight
	$sec_gun/sec_clip_ext.disabled = selected_sec_gun._has_extended_mag
	$primary_gun/prim_laser.disabled = selected_primary_gun._use_laser_sight
	$primary_gun/prim_clip_ext.disabled = selected_primary_gun._has_extended_mag
	$buy.hide()
	$AnimationPlayer.play_backwards("buy_popup")
	saveAll()


func _on_exit_buy_pressed():
	$AnimationPlayer.play_backwards("buy_popup")
	$buy.hide()

func saveAll():
	game_states.player_data.guns.clear()
	var gun_data = {gun_name = "", laser = false, mag_ext = false}
	
	for i in guns:
		var data = gun_data.duplicate(true)
		data.gun_name = i.gun_name
		data.laser = i._use_laser_sight
		data.mag_ext = i._has_extended_mag
		game_states.player_data.guns.append(data)
	
	game_states.player_data.selected_guns.clear()
	game_states.player_data.selected_guns.append(selected_primary_gun.gun_name)
	game_states.player_data.selected_guns.append(selected_sec_gun.gun_name)
	game_states.player_info.primary_gun_name = selected_primary_gun.gun_name
	game_states.player_info.sec_gun_name = selected_sec_gun.gun_name
	game_states.savePlayerData()
	


func _on_back_pressed():
	saveAll()
	freeGuns()
	MenuManager.changeScene("storeMenu")
	queue_free()

func _on_prev_btn_pressed():
	if arr_slot_index > 0:
		MusicMan.click()
		arr_slot_index -= 1
		for i in range(0,no_slots):
			var panel = $weapons/HBoxContainer.get_node("p" + String(i + 1))
			panel.get_node("p" + String(i + 1) + "_btn").texture_normal = guns[arr_slot_index +i].gun_portrait


func _on_next_btn_pressed():
	if arr_slot_index + no_slots < guns.size():
		MusicMan.click()
		arr_slot_index += 1
		for i in range(0,no_slots):
			var panel = $weapons/HBoxContainer.get_node("p" + String(i + 1))
			panel.get_node("p" + String(i + 1) + "_btn").texture_normal = guns[arr_slot_index +i].gun_portrait
