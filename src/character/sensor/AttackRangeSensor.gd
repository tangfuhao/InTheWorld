class_name AttackRangeSensor
extends Sensor
#攻击范围传感器

var _target_distance = 0

func setup(_control_node):
	.setup(_control_node)
	set_process(true)
	control_node.connect("target_update",self,"on_character_target_update")

func on_character_target_update(target):
	update_target_distance()

func _process(_delta):
	update_target_distance()

func update_target_distance():
	var target = control_node.get_target()
	if target:
		var latest_distance_to_target = control_node.global_position.distance_to(target.global_position)
		var margin_of_error = _target_distance - latest_distance_to_target
		if margin_of_error > 5 || margin_of_error < -5:
			_target_distance = latest_distance_to_target
			on_character_to_target_distance_update(_target_distance)

func on_character_to_target_distance_update(_distance):
	var is_no_melee_range_new = _distance > 40
	var is_no_remote_attak_new = _distance > 200
	world_status.set_world_status("不在近战攻击范围",is_no_melee_range_new)
	world_status.set_world_status("不在远程攻击范围",is_no_remote_attak_new)
	world_status.set_world_status("在近战攻击范围",!is_no_melee_range_new)
	world_status.set_world_status("在远程攻击范围",!is_no_remote_attak_new)

