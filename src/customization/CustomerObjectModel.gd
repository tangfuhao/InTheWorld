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
