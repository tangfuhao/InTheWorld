#请求文本
class_name NodeRequestInputEffect
var node_name
var request_input
var bind_param





func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	var text_arr =  yield(node,"request_input")
	
	

