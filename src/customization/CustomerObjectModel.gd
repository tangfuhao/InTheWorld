class_name CustomerObjectModel
var object_name:String

#条件 是否激活组
var funciton_attribute_active_status_dic:Dictionary = {}
#被哪些条件 激活组
var funciton_attribute_active_condition_dic:Dictionary = {}

#参数和值
var funciton_attribute_value_dic:Dictionary = {}
var function_attribute_name_arr:Array = []

#设置当前属性是否激活 
func set_function_attribute(_is_active,_condition_rule,_pre_condition_arr):
	var rule_name = _condition_rule.attribute_name
	function_attribute_name_arr.push_back(rule_name)
	funciton_attribute_active_status_dic[rule_name] = _is_active
	funciton_attribute_active_condition_dic[rule_name] = _pre_condition_arr


func set_funciton_attribute_value_dic(_condition_rule,_funciton_attribute_value_dic):
	var rule_name = _condition_rule.attribute_name
	funciton_attribute_value_dic[rule_name] = _funciton_attribute_value_dic


func to_json() -> String:
	var json_object := {}
	json_object["object_name"] = object_name
	json_object["funciton_attribute_active_status_dic"] = funciton_attribute_active_status_dic
	json_object["funciton_attribute_active_condition_dic"] = convert_funciton_attribute_active_condition_dic()
	json_object["funciton_attribute_value_dic"] = funciton_attribute_value_dic
	json_object["function_attribute_name_arr"] = function_attribute_name_arr

	return to_json(json_object)
	
func convert_funciton_attribute_active_condition_dic():
	var convert_dic = {}
	for key in funciton_attribute_active_condition_dic.keys():
		var conver_arr = []
		var value_arr = funciton_attribute_active_condition_dic[key]
		for item in value_arr:
			conver_arr.push_back(item.get_json_obejct())
		convert_dic[key] = conver_arr
	return convert_dic

func re_convert_funciton_attribute_active_condition_dic(_dic:Dictionary):
	for key in _dic.keys():
		var conver_arr = []
		var value_arr = _dic[key]
		for item in value_arr:
			var ccondition_model = CConditionModel.new()
			ccondition_model.set_json_obejct(item)
			conver_arr.push_back(ccondition_model)
		funciton_attribute_active_condition_dic[key] = conver_arr
			
	
func set_config(config_dic):
	object_name = config_dic["object_name"]
	funciton_attribute_active_status_dic = config_dic["funciton_attribute_active_status_dic"]
	funciton_attribute_value_dic = config_dic["funciton_attribute_value_dic"]
	function_attribute_name_arr = config_dic["function_attribute_name_arr"]
	re_convert_funciton_attribute_active_condition_dic(config_dic["funciton_attribute_active_condition_dic"])
