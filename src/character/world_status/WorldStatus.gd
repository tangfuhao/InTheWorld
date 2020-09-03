extends Node2D
class_name WorldStatus

onready var hurt_time = $HurtTimer

#认知
var world_status_dic:Dictionary = {}
var control_node

var around_player_dic := {}
var around_drink_player_dic := {}
var around_chitchat_player_dic := {}

signal world_status_change



func setup(_control_node):
	control_node = _control_node
	world_status_dic["可以移动"] = true
	world_status_dic["周围有其他人"] = false
	world_status_dic["周围没有其他人"] = true
	world_status_dic["其他人没有武器"] = true
	world_status_dic["受到攻击"] = false
	world_status_dic["不受攻击十秒"] = true
	world_status_dic["未躲入十秒"] = true
	world_status_dic["没有远程武器"] = true
	world_status_dic["有远程武器"] = false
	world_status_dic["不在近战攻击范围"] = true
	world_status_dic["不在远程攻击范围"] = true
	world_status_dic["在近战攻击范围"] = false
	world_status_dic["在远程攻击范围"] = false

	world_status_dic["周围有人在喝酒"] = false
	world_status_dic["周围有人在聊天"] = false
	world_status_dic["淋浴间可用"] = true
	world_status_dic["淋浴间被占用"] = false
	world_status_dic["化身位置"] = "空地"
	world_status_dic["非常困"] = false
	
	
	
	control_node.connect("package_item_change",self,"_on_character_player_package_item_change")
	control_node.connect("find_some_one",self,"_on_character_player_find_some_one")
	control_node.connect("un_find_some_one",self,"_on_character_player_un_find_some_one")
	
	control_node.connect("to_target_distance_update",self,"_on_character_to_target_distance_update")
	control_node.connect("be_hurt",self,"_on_character_be_hurt")
	
	control_node.connect("fixed_memory_stuff_statu_update",self,"_on_character_fixed_memory_stuff_statu_update")
	control_node.connect("location_change",self,"_on_character_location_change")
	control_node.connect("motivation_item_value_change",self,"_on_motivation_item_value_change")

func _on_motivation_item_value_change(motivation_model):
	if motivation_model.motivation_name == "睡眠动机":
		var is_drowse = motivation_model.motivation_value < 0.3
		if is_drowse != world_status_dic["非常困"]:
			world_status_dic["非常困"] = is_drowse
			emit_signal("world_status_change")

	
func _on_character_location_change(_location_name):
	if world_status_dic["化身位置"] != _location_name:
		world_status_dic["化身位置"] = _location_name
		print(control_node.player_name,"认知 化身位置 改变")
		emit_signal("world_status_change")
	
func _on_character_fixed_memory_stuff_statu_update(_stuff):
	if _stuff.stuff_name == "淋浴间":
		var can_use_new = not _stuff.is_occupy() or _stuff.is_occupy_player(control_node)
		var can_use_old = !world_status_dic["淋浴间被占用"]
		if can_use_old != can_use_new:
			world_status_dic["淋浴间被占用"] = !can_use_new
			print(control_node.player_name,"认知 淋浴间被占用 改变")
			emit_signal("world_status_change")

func _on_character_player_package_item_change(_item,_exist):
	var has_remote_weapons = world_status_dic["有远程武器"]
	if has_remote_weapons:
		if _exist == false && _item.has_attribute("可发射的"):
			var object = control_node.get_item_by_function_attribute_in_package("可发射的")
			if object == null:
				world_status_dic["有远程武器"] = false
				world_status_dic["没有远程武器"] = true
				emit_signal("world_status_change")
	else:
		if _exist && _item.has_attribute("可发射的"):
			world_status_dic["有远程武器"] = true
			world_status_dic["没有远程武器"] = false
			emit_signal("world_status_change")


func _on_character_to_target_distance_update(_distance):
	var is_no_melee_range = world_status_dic["不在近战攻击范围"]
	var is_no_remote_attak = world_status_dic["不在远程攻击范围"]

	var is_no_melee_range_new = _distance > 40
	var is_no_remote_attak_new = _distance > 200
	if is_no_melee_range != is_no_melee_range_new || is_no_remote_attak != is_no_remote_attak_new:
		world_status_dic["不在近战攻击范围"] = is_no_melee_range_new
		world_status_dic["不在远程攻击范围"] = is_no_remote_attak_new
		world_status_dic["在近战攻击范围"] = !is_no_melee_range_new
		world_status_dic["在远程攻击范围"] = !is_no_remote_attak_new
		print(control_node.player_name,"认知 攻击范围 改变")
		emit_signal("world_status_change")



func _on_character_player_find_some_one(_body):
	around_player_dic[_body.player_name] = _body
	update_around_player_num(_body)
	find_around_player_action(_body)
	
func _on_character_player_un_find_some_one(_body):
	around_player_dic.erase(_body.player_name)
	update_around_player_num(_body)
	un_find_around_player_action(_body)

func update_around_player_num(_player):
	var has_other_people = !around_player_dic.empty()
	if world_status_dic["周围有其他人"] != has_other_people:
		world_status_dic["周围有其他人"] = has_other_people
		world_status_dic["周围没有其他人"] = !has_other_people
		print(control_node.player_name,"认知 周围有其他人 改变")
		emit_signal("world_status_change")

func meet_player_action(_player,_action_name):
	return _player.get_current_action_name() == _action_name

func update_around_player_drink():
	var around_has_people_drink = world_status_dic["周围有人在喝酒"]
	var still_has_people_drink = !around_drink_player_dic.empty()
	if around_has_people_drink != still_has_people_drink:
		world_status_dic["周围有人在喝酒"] = still_has_people_drink
		print(control_node.player_name,"认知 周围有人在喝酒 改变")
		emit_signal("world_status_change")
		
func update_around_player_chitchat():
	var around_has_people_chitchat = world_status_dic["周围有人在聊天"]
	var still_has_people_chitchat = !around_chitchat_player_dic.empty()
	if around_has_people_chitchat != still_has_people_chitchat:
		world_status_dic["周围有人在聊天"] = still_has_people_chitchat
		print(control_node.player_name,"认知 周围有人在聊天 改变")
		emit_signal("world_status_change")
	
func find_around_player_action(_player):
	_player.connect("player_action_notify",self,"_on_around_player_action_notify")
	if meet_player_action(_player,"喝酒"):
		around_drink_player_dic[_player.player_name] = _player
		update_around_player_drink()
		
	if meet_player_action(_player,"聊天"):
		around_chitchat_player_dic[_player.player_name] = _player
		update_around_player_chitchat()
	
func un_find_around_player_action(_player):
	_player.disconnect("player_action_notify",self,"_on_around_player_action_notify")
	if meet_player_action(_player,"喝酒"):
		around_drink_player_dic.erase(_player.player_name)
		update_around_player_drink()
		
	if meet_player_action(_player,"聊天"):
		around_chitchat_player_dic.erase(_player.player_name)
		update_around_player_chitchat()

func _on_around_player_action_notify(_player,_action_name,_is_active):
	#喝酒
	if around_drink_player_dic.has(_player.player_name):
		if not meet_player_action(_player,"喝酒"):
			around_drink_player_dic.erase(_player.player_name)
			update_around_player_drink()
	else:
		if meet_player_action(_player,"喝酒"):
			around_drink_player_dic[_player.player_name] = _player
			update_around_player_drink()

	#聊天
	if around_chitchat_player_dic.has(_player.player_name):
		if not meet_player_action(_player,"聊天"):
			around_chitchat_player_dic.erase(_player.player_name)
			update_around_player_drink()
	else:
		if meet_player_action(_player,"聊天"):
			around_chitchat_player_dic[_player.player_name] = _player
			update_around_player_drink()


		


func _on_character_be_hurt(area):
	var is_hurt_status = world_status_dic["受到攻击"]
	if hurt_time.is_stopped():
		hurt_time.start(10)
	else:
		hurt_time.stop()
		hurt_time.start(10)
	if is_hurt_status == false: 
		world_status_dic["受到攻击"] = true
		world_status_dic["不受攻击十秒"] = false
		print(control_node.player_name,"认知 受到攻击 改变")
		emit_signal("world_status_change")

func _on_HurtTimer_timeout():
	var is_hurt_status = world_status_dic["受到攻击"]
	if is_hurt_status: 
		world_status_dic["受到攻击"] = false
		world_status_dic["不受攻击十秒"] = true
		print(control_node.player_name,"认知 不受攻击十秒 改变")
		emit_signal("world_status_change")
		
		


func meet_condition(_condition_item) -> bool :
	var condition_item_arr := Array(_condition_item.split(":"))
	var condition_item_name = condition_item_arr.pop_front()
	var condition_item_param = condition_item_arr.pop_front()
	if world_status_dic.has(condition_item_name):
		var value =  world_status_dic[condition_item_name]
		if value is String:
			return value == condition_item_param
		else:
			return value
	else:
		print("错误 不存在的认知:",_condition_item)
	return false



