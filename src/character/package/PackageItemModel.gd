class_name PackageItemModel
var item_name
var function_attribute_dic

func has_attribute(_attribute):
	if function_attribute_dic.has(_attribute):
		return function_attribute_dic[_attribute]
	return false


func get_params(_param):
	return 1
