extends Panel

const ListItem = preload("res://src/customization/ListViewLabelItem.tscn")
onready var list = $ScrollContainer/List

var last_select_item
signal on_item_selected


func set_function_attribute_dic(_function_attribute_name_arr,_funciton_attribute_active_status_dic):
	clear_item()
	var index = 0
	for attribute_name in _function_attribute_name_arr:
		var is_active = _funciton_attribute_active_status_dic[attribute_name]
		add_item(index,attribute_name,is_active)
		index = index + 1

	
func add_item(_index,_label,_is_active):
	var list_item = ListItem.instance()
	list_item.item_index = _index
	list.add_child(list_item)
	list_item.rect_min_size = Vector2(320,30)
	list_item.connect("item_selected",self,"_on_item_selected")
	
	list_item.set_label(_label)
	list_item.set_active(_is_active)
	
func clear_item():
	last_select_item = null
	var child_arr = list.get_children()
	for item in child_arr:
		list.remove_child(item)
		item.queue_free()
		
func _on_item_selected(_index):
	if last_select_item:
		last_select_item.get_node("Backgournd").visible = false
	last_select_item = list.get_child(_index)
	last_select_item.get_node("Backgournd").visible = true
	emit_signal("on_item_selected",_index)


