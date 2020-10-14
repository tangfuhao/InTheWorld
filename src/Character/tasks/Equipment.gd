#装备物品
extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Equipment



func active():
	.active()
	
	self.action_target = get_params()
	assert(action_target and action_target is PackageItemModel)
	var slot_name = get_index_params(1)
	assert(slot_name)
	
	if slot_name == "MeleeWeapons":
		var attack_force = action_target.get_param_value("攻击力")
		human.param.set_value("攻击",attack_force)
	elif slot_name == "ThrowingWeapons":
		pass
	elif slot_name == "Armor":
		pass
	elif slot_name == "Packsack":
		pass

	
	goal_status = STATE.GOAL_COMPLETED

