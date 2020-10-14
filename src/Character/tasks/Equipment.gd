#装备物品
extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Equipment



func active():
	.active()
	
	self.action_target = get_params()
	assert(not action_target or action_target is PackageItemModel)
	var slot_name = get_index_params(1)
	assert(slot_name)
	
	if wear_equipment(slot_name,action_target):
		goal_status = STATE.GOAL_COMPLETED
	else:
		goal_status = STATE.GOAL_FAILED



#装备物品
func wear_equipment(_slot_name,_equipment_item:PackageItemModel) -> bool:
	if _slot_name == "MeleeWeapons":
		var equipment_item = human.inventory_system.get_item_by_equipment_slot(_slot_name)
		if equipment_item:
			var attack_force = int(equipment_item.get_param_value("攻击力"))
			human.param.set_value("攻击",human.param.get_value("攻击") - attack_force)
			human.inventory_system.set_item_by_equipment_slot(_slot_name,null)
			
		
		if _equipment_item:
			var attack_force = int(_equipment_item.get_param_value("攻击力"))
			human.param.set_value("攻击",human.param.get_value("攻击") + attack_force)
			human.inventory_system.set_item_by_equipment_slot(_slot_name,_equipment_item.node_name)
	else:
		human.inventory_system.set_item_by_equipment_slot(_slot_name,null)
		if _equipment_item:
			human.inventory_system.set_item_by_equipment_slot(_slot_name,_equipment_item.node_name)
#	elif _slot_name == "ThrowingWeapons":
#
#
#
#
#	elif _slot_name == "Armor":
#		pass
#	elif _slot_name == "Packsack":
#		pass

	return true
