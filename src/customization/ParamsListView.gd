extends Panel

const ListItem = preload("res://src/customization/ParamsListViewLabelItem.tscn")
onready var list = $ScrollContainer/List



func set_config(_data_dic:Dictionary):
	clear_item()
	for key in _data_dic.keys():
		add_item(key,_data_dic[key])
		
func add_item(_label,_select_arr):
	var list_item = ListItem.instance()
	list.add_child(list_item)
	list_item.rect_min_size = Vector2(320,30)
	
	list_item.set_label(_label)
	if _select_arr.empty():
		list_item.set_params("")
	else:
		list_item.set_selector_arr(_select_arr)
	
func clear_item():
	var child_arr = list.get_children()
	for item in child_arr:
		list.remove_child(item)
		item.queue_free()

func get_physics_data():
	var data := {}
	var child_num = list.get_child_count()
	for index in range(child_num):
		var child = list.get_child(index)
		var key_value = child.get_key_and_value()
		data[key_value[0]] = key_value[1]
	return data
