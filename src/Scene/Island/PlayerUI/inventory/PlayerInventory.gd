extends WindowDialog

const item_base = preload("res://src/Scene/Island/PlayerUI/inventory/ItemBase.tscn")

onready var grid_bkpk := $GridBackPack

func _ready():
	if not visible:
		deactivate()
		
	pickup_item("s")
	pickup_item("s")
	pickup_item("s")


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




func pickup_item(item_id):
	var item = item_base.instance()
	item.set_meta("id", item_id)
#	var texture_path = ItemDB.get_item(item_id)["icon"]
#	var texture = load(texture_path)
#	item.texture = texture
	add_child(item)
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true
