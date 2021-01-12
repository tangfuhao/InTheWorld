extends WindowDialog
const item_base = preload("res://src/Scene/Island/PlayerUI/inventory/ItemBase.tscn")

onready var grid_bkpk := $GridBackPack



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


func show_wtih_object(_node:Node2D):
	activate()
	node_name_to_node_dic.clear()
	grid_bkpk.clear()
	synchron_data_to_ui(_node.get_children())
	
#存储node_name对node的引用
var node_name_to_node_dic := {}
#把背包里的数据同步到ui
func synchron_data_to_ui(_item_arr:Array):
	for item in _item_arr:
		node_name_to_node_dic[item.node_name] = item
		add_item(item.node_name,item.display_name,item)


func add_item(item_id,item_text,interaction_objec):
	var item = item_base.instance()
	item.interaction_object = interaction_objec
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
