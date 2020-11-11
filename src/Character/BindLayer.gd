extends Node2D

func bind(_node) -> bool:
	if _node.get_parent() == self:
		return false
		
	_node.set_disbled_collision(true)
	_node.position = Vector2(0,0)
	_node.interaction_onwer = self.get_parent()
	if _node.get_parent():
		_node.get_parent().remove_child(_node)
	self.add_child(_node)
	return true

	
func un_bind(_node:Node2D) -> bool:
	if _node.get_parent() != self:
		return false
	
	_node.set_disbled_collision(false)
	self.remove_child(_node)
	_node.interaction_onwer = null
	return true
	
	
	
func is_bind(_node:Node2D):
	return _node.get_parent() == self
