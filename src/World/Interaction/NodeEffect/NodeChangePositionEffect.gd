class_name NodeChangePositionEffect
var node
var node_name
var position 


func _process(_delta,_param_accessor):
	var parser = FormulaParser.new("\\$\\{(.+?)\\}")
	var result =  parser.finalExpression(position,{},{},_param_accessor) 
	if result is String:
		var result_arr = result.split(",")
		var x = float(result_arr[0])
		var y = float(result_arr[1])
		node.set_global_position(Vector2(x,y))
