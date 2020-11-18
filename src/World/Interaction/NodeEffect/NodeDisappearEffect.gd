class_name NodeDisappearEffect
var node_name
var disppear_node


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	node.disappear()
