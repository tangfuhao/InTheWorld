class_name PackageItemModel


var item_name setget _set_item_name
var node_name
var display_name
var function_attribute_dic = {}
var physics_data




func _set_item_name(_item_name):
	item_name = _item_name
	node_name = item_name + IDGenerator.pop_id_index()
	display_name = item_name


# func has_attribute(_attribute):
# 	if not _attribute:
# 		return false
		
# 	if item_name == _attribute:
# 		return true

# 	if function_attribute_dic.has(_attribute):
# 		return function_attribute_dic[_attribute]
# 	return false


#获取属性值
func get_param_value(_param_name):
	if physics_data and physics_data.has(_param_name):
		var stuff_param_value = physics_data[_param_name]
		return stuff_param_value
	return null

# func get_function(_function_name,_param_value):
# 	if function_attribute_dic.has(_function_name):
# 		var active_functon_attribute = function_attribute_dic[_function_name]
# 		if active_functon_attribute and active_functon_attribute.has(_param_value):
# 			return active_functon_attribute[_param_value]
# 	return null

func get_type():
	return "package_item"

