class_name NodeChangePositionEffect
var node_name
var position 
var parser:FormulaParser
func _init():
	parser = FormulaParser.new("\\$\\{(.+?)\\}")


func _process(_delta,_param_accessor):
	var objecet_regex = DataManager.objecet_regex
	var result =  parser.finalExpression(position,{},{},_param_accessor,objecet_regex) 
	if result is String:
		var result_arr = result.split(",")
		var x = float(result_arr[0])
		var y = float(result_arr[1])
		var node = _param_accessor.get_node_ref(node_name)
		node.set_global_position(Vector2(x,y))
