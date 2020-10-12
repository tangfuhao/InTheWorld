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


func setup_player(_player:Player):
	_player.inventory_system.connect("add_item",self,"on_inventory_add_item")
	_player.inventory_system.connect("remove_item",self,"on_inventory_remove_item")

func on_inventory_add_item(_item:PackageItemModel):
	pickup_item(_item.node_name,_item.display_name)

func on_inventory_remove_item(_item):
	pass

func pickup_item(item_id,item_text):
	var item = item_base.instance()
	item.set_meta("id", item_id)
	item.get_node("Control").text = item_text
	add_child(item)
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true
