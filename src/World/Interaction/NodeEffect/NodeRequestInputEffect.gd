#请求文本
class_name NodeRequestInputEffect
var node_name
var request_input
var bind_param

var is_request = false
var is_finish = false


func _process(_delta,_param_accessor):
	if is_finish:
		return null
		
	if not is_request:
		var node = _param_accessor.get_node_ref(node_name)
		node.add_request_input(request_input)
		is_request = true
		var result_text =  yield(node,"request_input_result")
		node.set_param_value(bind_param,result_text)
		is_request = false
		is_finish = true
		
	return 1

	
	


