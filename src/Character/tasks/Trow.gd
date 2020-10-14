#从背包扔到场景
extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Trow

var player_ui
var action_time



func active():
	.active()
	
	self.action_target = get_params()
	assert(action_target and action_target is PackageItemModel)
	
	var main_scence = human.get_node("/root/Island")
	var stuff_node = DataManager.instance_stuff_scene()
	stuff_node.copy_config_data(action_target)
	main_scence.customer_node_group.add_child(stuff_node)
	main_scence.binding_customer_node_item(stuff_node)
	stuff_node.set_global_position(human.get_global_position())
	
	goal_status = STATE.GOAL_COMPLETED

