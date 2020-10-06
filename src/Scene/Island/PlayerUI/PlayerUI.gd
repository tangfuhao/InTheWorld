extends Control

onready var player_status_panel := $PlayerStatusPanel
onready var player_status_listview := $PlayerStatusPanel/CommonListView

onready var player_inventory_panel := $PlayerInventory


onready var player_sales_panel := $PlayeSales
onready var player_make_panel := $PlayeMake


onready var grid_bkpk := $PlayerInventory/GridBackPack
onready var eq_slots := $PlayerStatusPanel/VBoxContainer/EquipmentSlots


var player:Player

var player_status_item = {}

func setup_player(_player:Player):
	if player == _player:
		return
	player = _player
	
	
	var id_content = "id:%s" % player.display_name
	$PlayerStatusPanel/IDLabel.text = id_content
	
	player.status.connect("status_value_update",self,"on_player_status_value_update")
	update_player_status()
	

	
	
	
func update_player_status():
	if player_status_listview.get_key_value_data().empty():
		var index = 0
		var status_dic = player.status.statusDic
		for status_key in status_dic.keys():
			var status_model = status_dic[status_key]
			var status_value = status_model.status_value
			var content_text = "%s:%f/1.0" % [status_key,status_value]
			player_status_listview.add_content_text(index,content_text,"状态值文本")
			player_status_item[status_key] = index
			index = index + 1
	else:
		pass
	
	
	
func on_player_status_value_update(_status_model):
	var status_key = _status_model.status_name
	var status_value = _status_model.status_value
	var index = player_status_item[status_key]
	var content_text = "%s:%f/1.0" % [status_key,status_value]
	player_status_listview.add_content_text(index,content_text,"状态值文本")


func _on_FunctionButton1_pressed():
	if player_status_panel.is_visible():
		player_status_panel.hide()
	else:
		player_status_panel.show()
	


func _on_FunctionButton2_pressed():
	if player_inventory_panel.is_visible():
		player_inventory_panel.hide()
	else:
		player_inventory_panel.show()


func _on_FunctionButton3_pressed():
	if player_sales_panel.is_visible():
		player_sales_panel.hide()
	else:
		player_sales_panel.show()


func _on_FunctionButto4_pressed():
	if player_make_panel.is_visible():
		player_make_panel.hide()
	else:
		player_make_panel.show()





var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()



func _process(delta):
	if not is_visible():
		return

	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset


func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = item_held.rect_global_position
			item_offset = item_held.rect_global_position - cursor_pos
			move_child(item_held, get_child_count())

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
	

func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk,eq_slots]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.rect_global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null

