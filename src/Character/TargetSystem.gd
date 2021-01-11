class_name TargetSystem
#目标系统

signal target_change(target)
var control_node

#类型到目标的缓存
var target_cache_dir := {}
#目标绑定了哪些类型
var target_param_dic := {}

var message_generator

func _init(_control_node,_message_generator):
	control_node = _control_node
	message_generator = _message_generator



func _on_target_disappear_notify(_target):
	var param_arr = CollectionUtilities.get_arr_item_by_key_from_dic(target_param_dic,_target)
	for param_item in param_arr:
		var target_arr = CollectionUtilities.get_arr_item_by_key_from_dic(target_cache_dir,param_item)
		CollectionUtilities.remove_item_from_arr(target_arr,_target)
	CollectionUtilities.remove_key_from_dic(target_param_dic,_target)
	
var recently_target
func set_target(_param,_target):
	recently_target = _target
	var target_arr = CollectionUtilities.get_arr_item_by_key_from_dic(target_cache_dir,_param)
	if CollectionUtilities.add_item_to_arr_no_repeat(target_arr,_param):
		_target.connect("disappear_notify",self,"_on_target_disappear_notify")
		message_generator.send_player_target_change(control_node,_target)
		emit_signal("target_change",_target)

func get_recently_target():
	return recently_target

func get_target(_param):
	if target_cache_dir.has(_param):
		var target_arr = CollectionUtilities.get_arr_item_by_key_from_dic(target_cache_dir,_param)
		if target_arr.size() > 0:
			return target_arr.back()
	return null
