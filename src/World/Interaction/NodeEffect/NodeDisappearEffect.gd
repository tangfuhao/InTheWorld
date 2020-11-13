class_name NodeDisappearEffect
var node_name
var disppear_node


func _process(_delta,_param_accessor):
	if _param_accessor.has_node_param(node_name):
		var node = _param_accessor.get_node_ref(node_name)
		node.queue_free()
