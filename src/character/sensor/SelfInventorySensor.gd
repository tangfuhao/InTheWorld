extends Sensor
class_name SelfInventorySensor
#自身库存传感器

var object_function_dic = {}

#功能计数
var function_obj_arr_dic = {}

func setup(_control_node):
	.setup(_control_node)
	
	control_node.inventory_system.connect("add_item",self,"_on_inventory_system_add_item")
	control_node.inventory_system.connect("remove_item",self,"_on_inventory_system_remove_item")
	
func function_dic_remove_item(_item):
	var num = 0
	if function_obj_arr_dic.has(_item):
		num = function_obj_arr_dic[_item]
		num = num - 1
	
	function_obj_arr_dic[_item] = num
	
func function_dic_add_item(_item):
	var num = 0
	if function_obj_arr_dic.has(_item):
		num = function_obj_arr_dic[_item]
	
	function_obj_arr_dic[_item] = num + 1
	
func update_function_world_status(_item):
	var world_status_item = "拥有-%s"%_item
	var obj_num = function_obj_arr_dic[_item]
	var value = obj_num > 0
	world_status.set_world_status(world_status_item,value)

func _on_inventory_system_add_item(_item):
	function_dic_add_item(_item.item_name)
	update_function_world_status(_item.item_name)
	
	var function_attribute_dic = _item.function_attribute_dic
	for function_attribute_item in function_attribute_dic.keys():
		var value = function_attribute_dic[function_attribute_item]
		if value:
			function_dic_add_item(function_attribute_item)
			update_function_world_status(function_attribute_item)

func _on_inventory_system_remove_item(_item):
	function_dic_remove_item(_item.item_name)
	update_function_world_status(_item.item_name)
	
	var function_attribute_dic = _item.function_attribute_dic
	for function_attribute_item in function_attribute_dic.keys():
		var value = function_attribute_dic[function_attribute_item]
		if value:
			function_dic_remove_item(function_attribute_item)
			update_function_world_status(function_attribute_item)
