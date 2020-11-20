class_name NodeAddToConceptEffect
var node_name

var concept_config_arr 


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	for concept_config_item in concept_config_arr:
		#加概念
		var concept_name = concept_config_item["concept_name"]
		node.add_concept(concept_name)
		
		#加属性定义
		var param_config_arr = concept_config_item["param_config"]
		node.set_param_config(param_config_arr)
		
		#设置属性
		var param_setting_dic = concept_config_item["params"]
		for param_name_item in param_setting_dic.keys():
			var param_value = param_setting_dic[param_name_item]
			node.set_param_value(param_name_item,param_value)

