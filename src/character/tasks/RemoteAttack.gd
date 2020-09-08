extends "res://src/character/tasks/NoLimitTask.gd"
class_name RemoteAttack

var current_remote_weapon = null
var shoot_times:int
var shoot_duration:float
var shoot_damage:int

var action_timer:Timer = null
var restore_action = true

func active() ->void:
	.active()
	create_action_timer()

func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			human.movement.set_desired_position(target.global_position)
			check_weapons()
			equipment_weapons()
			if current_remote_weapon:
				if restore_action:
					restore_action = false
					human.shoot(target.global_position,shoot_damage)
					human.movement.set_desired_position(target.global_position)
					shoot_times = shoot_times - 1
					print(action_timer,"+",shoot_duration)
					action_timer.start(shoot_duration)
				return STATE.GOAL_ACTIVE
	return STATE.GOAL_FAILED

func terminate() ->void:
	if action_timer:
		human.remove_child(action_timer)
		action_timer = null

func _on_action_timer_time_out():
	restore_action = true
	
func remove_weapon_form_package(item):
	human.inventory_system.remove_item_in_package(item)
	
	
	
func check_weapons():
	if current_remote_weapon:
		if shoot_times <= 0:
			remove_weapon_form_package(current_remote_weapon)
			current_remote_weapon = null

func equipment_weapons():
	while current_remote_weapon == null:
		current_remote_weapon = human.inventory_system.get_item_by_function_attribute_in_package("可发射的")
		if current_remote_weapon:
			shoot_times = int(current_remote_weapon.get_params("发射次数"))
			shoot_duration = float(current_remote_weapon.get_params("动作时间") )
			shoot_damage = int(current_remote_weapon.get_params("命中伤害"))
			check_weapons()
		else:
			#找不到相应武器了 直接结束
			return
