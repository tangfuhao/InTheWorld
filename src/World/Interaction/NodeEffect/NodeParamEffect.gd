class_name NodeParamEffect
var node
var node_name
var param_name
var transform setget set_transform
var assign

var temp_delta = 0




func set_transform(_transform):
	if _transform is String:
		transform = _transform
	else:
		transform = _transform


func _process(_delta,_param_accessor):
	temp_delta = temp_delta + _delta
	if temp_delta < 1:
		return 
		
	if transform:
		var value = node.get_param_value(param_name)
		var t = 0
		if transform is String:
			var parser = FormulaParser.new("\\$\\{(.+?)\\}")
			t = parser.parse(transform, {}, {},_param_accessor) * temp_delta
		else:
			t = transform * temp_delta
	
		value = value + t
		node.set_param_value(param_name,value)
	elif assign:
		node.set_param_value(param_name,assign)
	
	temp_delta = 0
