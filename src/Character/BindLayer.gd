extends Node2D

func bind(_node):
	_node.set_disbled_collision(true)
	_node.position = Vector2(0,0)
	if _node.get_parent():
		_node.get_parent().remove_child(_node)
	self.add_child(_node)
	
func un_bind(_node:Node2D):
	_node.set_disbled_collision(false)
	self.remove_child(_node)
	
func is_bind(_node:Node2D):
	return _node.get_parent() == self
