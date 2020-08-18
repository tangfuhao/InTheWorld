#通用listview
extends Panel

const ListItemType1 = preload("res://src/customization/listview/ListViewItemType1.tscn")
const ListItemType2 = preload("res://src/customization/ParamsListViewLabelItem.tscn")
onready var list = $ScrollContainer/List

var last_select_item
signal on_item_selected(index)
signal on_item_active(index,is_active)
signal on_item_value_change(index,value)


func set_data_arr(_data_arr:Array):
	clear_item()
	var item_index = 0
	for item in _data_arr:
		add_item_type_1(item_index,item)
		item_index = item_index + 1

func set_data_dic(_data_dic:Dictionary):
	clear_item()
	var item_index = 0
	for key in _data_dic.keys():
		var value = _data_dic[key]
		add_item_type_2(item_index,key,value)
		item_index = item_index + 1
		
func set_data_dic2(_data_dic:Dictionary,_data_value_dic:Dictionary):
	clear_item()
	var item_index = 0
	for key in _data_dic.keys():
		var selected_value = _data_value_dic[key]
		add_item_type_3(item_index,key,_data_dic[key],selected_value)
		item_index = item_index + 1

func clear_item():
	last_select_item = null
	var child_arr = list.get_children()
	for item in child_arr:
		list.remove_child(item)
		item.queue_free()

#只显示文字
func add_item_type_1(_index,_label):
	var list_item = ListItemType1.instance()
	list_item.item_index = _index
	list.add_child(list_item)
	list_item.rect_min_size = Vector2(320,30)
	list_item.connect("item_selected",self,"_on_item_selected")
	list_item.connect("active_change",self,"_on_item_active")
	list_item.set_label(_label)
	return list_item

#显示文字和标志
func add_item_type_2(_index,_label,_is_active):
	var list_item = add_item_type_1(_index,_label)
	list_item.set_active(_is_active)

#选择器
func add_item_type_3(_index,_label,_select_arr,_selected_value):
	var list_item = ListItemType2.instance()
	list.add_child(list_item)
	list_item.item_index = _index
	list_item.rect_min_size = Vector2(320,30)
	
	list_item.set_label(_label)
	if _select_arr.empty() == false:
		list_item.set_selector_arr(_select_arr)
	
	
func _on_item_selected(_index):
	if last_select_item:
		last_select_item.get_node("Backgournd").visible = false
	last_select_item = list.get_child(_index)
	last_select_item.get_node("Backgournd").visible = true
	emit_signal("on_item_selected",_index)
	
func _on_item_active(_index,_is_active):
	emit_signal("on_item_active",_index,_is_active)
