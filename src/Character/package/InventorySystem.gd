class_name InventorySystem
#库存系统 背包系统
var package_arr := []

#缓存 插槽和id
var equipment_id_dic := {}
#当前用于装备id的
var equipment_id_arr := []

#最大负重值
var max_load_value = 50
var current_load_value = 0

signal add_item(item)
signal remove_item(item)


#通过插槽名 获取当前 item
func get_item_by_equipment_slot(_slot_name) -> PackageItemModel:
	if equipment_id_dic.has(_slot_name):
		return get_item_by_id(equipment_id_dic[_slot_name])
	return null
	
func set_item_by_equipment_slot(_slot_name,_item_id):
	if equipment_id_dic.has(_slot_name):
		var item_id = equipment_id_dic[_slot_name]
		equipment_id_arr.erase(item_id)
		equipment_id_dic.erase(_slot_name)
	
	if _item_id:
		equipment_id_arr.push_back(_item_id)
		equipment_id_dic[_slot_name] = _item_id

func get_package_data() -> Array:
	var package_without_equipment := []
	for item in package_arr:
		if not equipment_id_arr.has(item.node_name):
			package_without_equipment.push_back(item)
	return package_without_equipment

func add_stuff_to_package(_target:CommonStuff,_auto_stack = true) -> bool:
	assert(_target.get_param_value("重量"))
	var load_value = float(_target.get_param_value("重量"))
	if current_load_value + load_value > max_load_value:
		return false
		

	var item = conver_stuff_to_package_item(_target)
	if add_item_to_package(item,_auto_stack):
		current_load_value = current_load_value + load_value
		emit_signal("add_item",item)
		return true
	else:
		return false

func add_item_to_package(_item:PackageItemModel,_auto_stack = true) -> bool:
	var load_value = float(_item.get_param_value("重量"))
	if current_load_value + load_value > max_load_value:
		return false
		
	package_arr.push_back(_item)
	return true
		
func conver_stuff_to_package_item(_stuff) -> PackageItemModel:
	var item = PackageItemModel.new()
	item.item_name = _stuff.stuff_type_name
	item.function_attribute_dic = _stuff.active_functon_attribute_params_dic
	item.physics_data = _stuff.physics_data
	return item

	
func get_item_by_id(_id) -> PackageItemModel:
	for item in package_arr:
		if item.node_name == _id:
			return item
			
	return null

func remove_item_in_package(_item):
	var load_value = float(_item.get_param_value("重量"))
	current_load_value = current_load_value - load_value
	
	package_arr.erase(_item)
	emit_signal("remove_item",_item)
