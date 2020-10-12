class_name InventorySystem
#库存系统 背包系统
var package := []

#最大负重值
var max_load_value = 50
var current_load_value = 50

signal add_item(item)
signal remove_item(item)

func add_stuff_to_package(_target:CommonStuff) -> bool:
	assert(_target.get_param_value("重量"))
	var load_value = float(_target.get_param_value("重量"))
	if current_load_value + load_value > max_load_value:
		return false

	var item = conver_stuff_to_item(_target)
	if add_item_to_package(item):
		current_load_value = current_load_value + load_value
		return true
	else:
		return false

func add_item_to_package(_item:PackageItemModel) -> bool:
	var load_value = float(_item.get_param_value("重量"))
	if current_load_value + load_value > max_load_value:
		return false
	package.push_back(_item)
	emit_signal("add_item",_item)
	return true
		
func conver_stuff_to_item(_stuff) -> PackageItemModel:
	var item = PackageItemModel.new()
	item.item_name = _stuff.stuff_type_name
	item.function_attribute_dic = _stuff.function_attribute_active_dic
	item.physics_data = _stuff.physics_data
	return item
		


func pop_item_by_name_in_package(_name):
	for item in package:
		if item.item_name == _name:
			package.erase(item)
			return item
	return null

func pop_item_by_function_name_in_package(_function_name):
	for item in package:
		if item.has_attribute(_function_name):
			remove_item_in_package(item)
			return item
	return null

func get_item_by_function_attribute_in_package(_function_attribute):
	for item in package:
		if item.has_attribute(_function_attribute):
			return item
	return null

func remove_item_in_package(_item):
	package.erase(_item)
	emit_signal("remove_item",_item)
