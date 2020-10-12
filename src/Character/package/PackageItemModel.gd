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


func has_attribute(_attribute):
	if not _attribute:
		return false
		
	if item_name == _attribute:
		return true

	if function_attribute_dic.has(_attribute):
		return function_attribute_dic[_attribute]
	return false


func get_params(_param):
	assert(false)
	return 1
	

func get_type():
	return "package_item"

