extends Node2D

func bind(_node):
	if _node.get_parent() == self:
		return
		
	_node.set_disbled_collision(true)
	_node.position = Vector2(0,0)
	_node.get_parent().remove_child(_node)
	self.add_child(_node)
	
	_node.notify_binding_dependency_change()
	
func un_bind(_node:Node2D):
	_node.set_disbled_collision(false)
	self.remove_child(_node)
	
	_node.notify_binding_dependency_change()
	
func is_bind(_node:Node2D):
	return _node.get_parent() == self
