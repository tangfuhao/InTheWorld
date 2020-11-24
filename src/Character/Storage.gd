#管理存储
extends Node2D
class_name Storage

func store(_node:Node2D):
	if _node.get_parent() == self:
		return false
		
	_node.set_storage_state(true)

	_node.position = Vector2(0,0)
	_node.interaction_onwer = self.get_parent()
	if _node.get_parent():
		_node.get_parent().remove_child(_node)
	self.add_child(_node)
	return true
	
func un_store(_node:Node2D):
	if _node.get_parent() != self:
		return false
		
	_node.set_storage_state(false)
	self.remove_child(_node)
	_node.interaction_onwer = null
	
	return true
	
func is_store(_node:Node2D):
	return _node.get_parent() == self


func container_type():
	return "storage"
