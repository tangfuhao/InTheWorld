class_name InventorySystem
#库存系统 背包系统
var package := []

#最大负重值
var max_load_value = 100

signal add_item(item)
signal remove_item(item)

func add_stuff_to_package(_target):
	if _target is CommonStuff:
		var item = conver_stuff_to_item(_target)
		_target.disappear()
		add_item_to_package(item)
		
func conver_stuff_to_item(_stuff):
	var item = PackageItemModel.new()
	item.item_name = _stuff.stuff_type_name
	item.function_attribute_dic = _stuff.function_attribute_active_dic
	item.physics_data = _stuff.physics_data
	return item
		
func add_item_to_package(_item):
	package.push_back(_item)
	emit_signal("add_item",_item)

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
