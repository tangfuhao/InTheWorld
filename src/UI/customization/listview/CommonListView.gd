#通用listview
extends Panel

const ListItemType1 = preload("res://src/UI/customization/listview/ListViewItemType1.tscn")
const ListItemType2 = preload("res://src/UI/customization/listview/ListViewItemType2.tscn")



const ListItemType3 = preload("res://src/UI/customization/listview/ListViewItemType3.tscn")
const ListItemType4 = preload("res://src/UI/customization/listview/ListViewItemType4.tscn")
const ListItemType5 = preload("res://src/UI/customization/listview/ListViewItemType5.tscn")
const ListItemType6 = preload("res://src/UI/customization/listview/ListViewItemType6.tscn")

const ListItemType7 = preload("res://src/UI/customization/listview/ListViewItemType7.tscn")


onready var list = $ScrollContainer/List
onready var scroll_container = $ScrollContainer

var last_select_item
signal on_item_selected(index)
signal on_item_active(index,is_active)
signal on_item_value_change(index,key,value)

export var is_auto_scroll = true
var is_manual_control = false


func set_data_arr(_data_arr:Array):
	clear_item()
	var item_index = 0
	for item in _data_arr:
		add_item_type_1(item_index,item)
		item_index = item_index + 1

func set_data_dic(_data_arr:Array,_data_dic:Dictionary):
	clear_item()
	var item_index = 0
	for key in _data_arr:
		var value = _data_dic[key]
		add_item_type_2(item_index,key,value)
		item_index = item_index + 1
		
func set_data_dic2(_data_dic:Dictionary,_data_value_dic:Dictionary):
	clear_item()
	var item_index = 0
	for key in _data_dic.keys():
		var selected_value
		if _data_value_dic.has(key):
			selected_value = _data_value_dic[key]
			
		add_item_type_3(item_index,key,_data_dic[key],selected_value)
		item_index = item_index + 1

func clear_item():
	last_select_item = null
	var child_arr = list.get_children()
	for item in child_arr:
		list.remove_child(item)
		item.queue_free()

func set_selected(_index):
	if last_select_item:
		last_select_item.get_node("Backgournd").visible = false
	last_select_item = list.get_child(_index)
	last_select_item.get_node("Backgournd").visible = true

#只显示文字
func add_item_type_1(_index,_label):
	var list_item = ListItemType1.instance()
	list_item.item_index = _index
	list.add_child(list_item)
	list_item.rect_min_size = Vector2(320,30)
	list_item.connect("item_selected",self,"_on_item_selected")
	list_item.connect("active_change",self,"_on_item_active")
	list_item.connect("item_value_change",self,"_on_item_value_change")
	
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
	list_item.connect("item_value_change",self,"_on_item_value_change")
	
	list_item.set_label(_label)
	if not _select_arr.empty():
		list_item.set_selector_arr(_select_arr,_selected_value)
	else:
		list_item.set_edit_value(_selected_value)

func create_list_item_by_type(_label_type):
	match _label_type:
		"状态值文本":
			return ListItemType7.instance()
		"世界文本":
			return ListItemType4.instance()
		"对话文本":
			return ListItemType6.instance()
		"思想文本":
			return ListItemType5.instance()




func add_content_text(_index,_label,_label_type):
	var list_item
	if list.get_child_count() > _index:
		list_item = list.get_child(_index)
	else:
		list_item = create_list_item_by_type(_label_type)
		list_item.item_index = _index
		list.add_child(list_item)

	
	list_item.set_label(_label)
	
	if is_auto_scroll and not is_manual_control:
		yield(get_tree(),"idle_frame")
		var rect = self.get_rect()
		var list_rect = list.get_rect()
	
		var remain_offset_y = rect.size.y - list_rect.size.y
		if remain_offset_y < 0:
			remain_offset_y = abs(remain_offset_y)
			scroll_container.set_v_scroll(remain_offset_y)
	return list_item
		
func set_item_active(_index,_is_active):
	var item_view = list.get_child(_index)
	item_view.set_active(_is_active)
	
	
func _on_item_selected(_index):
	if last_select_item:
		last_select_item.get_node("Backgournd").visible = false
	last_select_item = list.get_child(_index)
	last_select_item.get_node("Backgournd").visible = true
	emit_signal("on_item_selected",_index)
	
func _on_item_active(_index,_is_active):
	emit_signal("on_item_active",_index,_is_active)
	
func _on_item_value_change(_index,_key,_value):
	emit_signal("on_item_value_change",_index,_key,_value)
	
func get_key_value_data():
	var data := {}
	var child_num = list.get_child_count()
	for index in range(child_num):
		var child = list.get_child(index)
		var key_value = child.get_key_and_value()
		data[key_value[0]] = key_value[1]
	return data
