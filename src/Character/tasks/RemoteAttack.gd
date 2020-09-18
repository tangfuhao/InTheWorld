extends "res://src/Character/tasks/NoLimitTask.gd"
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

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")

func process(_delta: float):
	.process(_delta)

	if goal_status == STATE.GOAL_ACTIVE:
		human.movement.set_desired_position(action_target.global_position)
		equipment_weapons()
		if not shoot_use_weapons():
			goal_status = STATE.GOAL_COMPLETED

	return goal_status

func terminate() ->void:
	.terminate()
	if action_timer:
		action_timer.stop()
		human.remove_child(action_timer)
		action_timer = null



func _on_action_timer_time_out():
	restore_action = true
	

	
	
func shoot_use_weapons():
	if not current_remote_weapon:
		return false

	if restore_action:
		restore_action = false
		action_timer.start(shoot_duration)


		human.shoot(action_target.global_position,shoot_damage)
		shoot_times = shoot_times - 1
		

func check_weapons():
	if current_remote_weapon:
		if shoot_times <= 0:
			human.inventory_system.remove_item_in_package(current_remote_weapon)
			current_remote_weapon = null

func equipment_weapons():
	while current_remote_weapon == null:
		current_remote_weapon = human.inventory_system.get_item_by_function_attribute_in_package("可发射的")
		if not current_remote_weapon:
			return

		shoot_times = int(current_remote_weapon.get_params("发射次数"))
		shoot_duration = float(current_remote_weapon.get_params("动作时间") )
		shoot_damage = int(current_remote_weapon.get_params("命中伤害"))
		check_weapons()

