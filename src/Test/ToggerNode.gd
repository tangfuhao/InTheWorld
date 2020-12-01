extends Node2D

const test_node = preload("res://src/Test/ResponserNode.tscn")

var start_time = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("节点遍历")
	if start_time < 0:
		print("条件改变")
		var child_node = test_node.instance()
		print("创建作用")
		get_parent().get_parent().get_node("ResponserNode").add_child(child_node)
		start_time = 10000
	else:
		start_time -= delta
