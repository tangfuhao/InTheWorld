extends WindowDialog

const item_base = preload("res://src/Scene/Island/PlayerUI/inventory/ItemBase.tscn")

onready var grid_bkpk := $GridBackPack
onready var laod_value_label := $Label

var _current_player

func _ready():
	if not visible:
		deactivate()

func deactivate():
	hide()
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	set_process_input(false)
	
func activate():
	show()
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
	set_process_input(true)


func setup_player(_player:Player):
	if _current_player != _player:
		if _current_player:
			_current_player.inventory_system.disconnect("add_item",self,"on_inventory_add_item")
			_current_player.inventory_system.disconnect("remove_item",self,"on_inventory_remove_item")
		_player.inventory_system.connect("add_item",self,"on_inventory_add_item")
		_player.inventory_system.connect("remove_item",self,"on_inventory_remove_item")
		_current_player = _player
		synchron_data_to_ui(_player.inventory_system.get_package_data())
		update_laod_value()
	

#更新负重值
func update_laod_value():
	var content = "负重值:%d/%d" % [_current_player.inventory_system.current_load_value,_current_player.inventory_system.max_load_value]
	laod_value_label.text = content

#把背包里的数据同步到ui
func synchron_data_to_ui(_packge_data):
	grid_bkpk.clear()
	for item in _packge_data:
		add_item(item.node_name,item.display_name)


func on_inventory_add_item(_item:PackageItemModel):
	if _current_player:
		add_item(_item.node_name,_item.display_name)
		update_laod_value()
		
	

func on_inventory_remove_item(_item):
	if _current_player:
		remove_item(_item.node_name)
		update_laod_value()
		



	
func add_item(item_id,item_text):
	var item = item_base.instance()
	item.set_meta("id", item_id)
	item.get_node("Control").text = item_text
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true
	
func remove_item(item_id):
	var item = grid_bkpk.get_item_under_meta_data("id",item_id)
	if item:
		grid_bkpk.remove_item(item)
		item.queue_free()
