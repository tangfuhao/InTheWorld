#管理存储
extends Node2D
class_name Storage

func store(_node:Node2D):
	_node.set_disable_interactino(false)
	_node.position = Vector2(0,0)
	if _node.get_parent():
		_node.get_parent().remove_child(_node)
	add_child(_node)
	
	
