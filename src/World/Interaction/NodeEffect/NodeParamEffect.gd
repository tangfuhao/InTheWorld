class_name NodeParamEffect
var node
var node_name
var param_name
var transform
var assign

var temp_delta = 0

func _process(_delta):
	temp_delta = temp_delta + _delta
	if temp_delta < 1:
		return 
	
	var value = node.get_param_value(param_name)
	var t = transform * temp_delta
	value = value + t
	node.set_param_value(param_name,value)
	
	temp_delta = 0
