class_name CConditionAttributeItem
var attribute_name:String
var attribute_value_arr:Array = []

func _init(_attribute_name,_attribute_value_arr):
	attribute_name = _attribute_name
	parse_attribute(_attribute_value_arr)
	
		
func parse_attribute(_attribute_value_arr):
	if _attribute_value_arr:
		for item in _attribute_value_arr:
			var attribute_value =  item["属性值"]
			var attribute_condition_arr =  item["条件组"]
			attribute_value_arr.push_back(CConditionModel.new(attribute_value,attribute_condition_arr))
		
func calculate_attribute_value(_physics_data):
	var else_value = null
	for item in attribute_value_arr:
		if item.is_all_condition():
			return item
		if item.is_else_condition():
			else_value = item.condition_name
		else:
			if item.is_meet_condition(_physics_data):
				var value = item.condition_name
				return value
	return else_value

func get_params_arr() -> Array:
	var params_arr := []
	for item in attribute_value_arr:
		 params_arr.push_back(item.condition_name)
	return params_arr
