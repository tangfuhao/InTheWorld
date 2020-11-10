#管理存储
extends Node2D
class_name Storage

func store(_node:Node2D):
	_node.set_interactino_state(false)
	_node.position = Vector2(0,0)
	if _node.get_parent():
		_node.get_parent().remove_child(_node)
	self.add_child(_node)
	
func un_store(_node:Node2D):
	_node.set_interactino_state(true)
	self.remove_child(_node)
	
	
func is_store(_node:Node2D):
	return _node.get_parent() == self
