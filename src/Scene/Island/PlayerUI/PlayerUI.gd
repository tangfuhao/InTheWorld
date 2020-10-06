extends Control

onready var player_status_panel := $PlayerStatusPanel
onready var player_inventory_panel := $PlayerInventory
onready var player_sales_panel := $PlayeSales
onready var player_make_panel := $PlayeMake


onready var grid_bkpk := $PlayerInventory/GridBackPack
onready var eq_slots := $PlayerStatusPanel/VBoxContainer/EquipmentSlots
onready var sales_grid := $PlayeSales/SalesGrid
onready var material_grid := $PlayeMake/MaterialGrid

var current_ui_bind_player:Player
var player_status_item = {}

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()

func _ready():
	$Popup.show()

func hide():
	.hide()
	player_status_panel.hide()
	player_inventory_panel.hide()
	player_sales_panel.hide()
	player_make_panel.hide()

func setup_player(_player:Player):
	if current_ui_bind_player == _player:
		return
	current_ui_bind_player = _player
	player_status_panel.setup_player(current_ui_bind_player)

func _process(_delta):
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
			if item_held.get_parent():
				item_held.get_parent().remove_child(item_held)
			$Popup.add_child(item_held)

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
	var containers = [grid_bkpk,eq_slots,sales_grid,material_grid]
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







