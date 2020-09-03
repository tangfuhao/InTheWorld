extends KinematicBody2D
class_name Player

const Bullet = preload("res://src/world/Bullet.tscn")

export var show_log := false
export var player_name = "player1"
export (NodePath) var bullets_node_path
var bullets_node

export (NodePath) var shower_room_path
export (NodePath) var bed_path


onready var playerName = $NameDisplay/PlayerName
onready var movement = $Movement
onready var cpu = $CPU
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var visionSensor = $VisionSensor
#维护关系
onready var relationship_system:RelationshipSystem
#行为回复
onready var response_system:ResponseSystem
#目标
var target = null setget set_target
#与目标的距离
var _target_distance = 0
#背包
var package = []
#组行为
var current_group_task:GroupTask
#预处理 行为 通知 队列
var preprocess_action_notify_dic = {}
#固定记忆
var fixed_memory = {}
var radius = 8




signal to_target_distance_update(distance)
signal be_hurt(area)
signal disappear_notify
signal package_item_change(target,is_exist)
signal find_some_one(body)
signal un_find_some_one(body)
signal find_some_stuff(body)
signal un_find_some_stuff(body)

signal player_action_notify(body,action_name,is_active)

signal fixed_memory_stuff_statu_update(stuff)
signal location_change(_location_name)
signal motivation_item_value_change(motivation_model)

#设置状态值
func set_status_value(_status_name,_status_value):
	cpu.set_status_value(_status_name,_status_value)

func get_status_value(_status_name):
	return cpu.get_status_value(_status_name)

func _process(_delta):
	handle_preprocess_action_notify()
	update_target_distance()
	

func update_target_distance():
	if target:
		var latest_distance_to_target = global_position.distance_to(target.global_position)
		var margin_of_error = _target_distance - latest_distance_to_target
		if margin_of_error > 5 || margin_of_error < -5:
			_target_distance = latest_distance_to_target
			emit_signal("to_target_distance_update",_target_distance)

func _ready() -> void:
	bullets_node = get_node(bullets_node_path)
	
	fixed_memory["淋浴间"] = get_node(shower_room_path)
	fixed_memory["床"] = get_node(bed_path)
	fixed_memory["淋浴间"].connect("stuff_state_change",self,"_on_stuff_state_change")
	
	playerName.text = player_name
	response_system = ResponseSystem.new(self)
	relationship_system = RelationshipSystem.new()
	relationship_system.bind_player_vision(self)

	visionSensor.connect("find_something",self,"_on_visionSensor_find_something")
	visionSensor.connect("un_find_something",self,"_on_visionSensor_un_find_something")
	cpu.motivation.connect("motivation_item_value_change",self,"_on_motivation_item_value_change")

func _on_motivation_item_value_change(motivation_model):
	emit_signal("motivation_item_value_change",motivation_model)

func _on_stuff_state_change(_stuff):
	emit_signal("fixed_memory_stuff_statu_update",_stuff)

func interaction_action(_player,_action_name):
	relationship_system.interaction_action(_player,_action_name)
	

func _on_target_disappear_notify(_target):
	if target:
		target.disconnect("disappear_notify",self,"_on_target_disappear_notify")
	target = null

func set_target(_target):
	if target != _target:
		if target:
			target.disconnect("disappear_notify",self,"_on_target_disappear_notify")
		if _target:
			_target.connect("disappear_notify",self,"_on_target_disappear_notify")
		target = _target
		update_target_distance()
		
		if target is CommonStuff:
			print(player_name,"的目标改为:",target.stuff_name)
		else:
			print(player_name,"的目标改为:",target.player_name)
			

func is_approach(_target):
	var tolerance = radius * 2 + _target.radius * 2
	return global_position.distance_to(_target.global_position) < tolerance

func is_interaction_distance(_target):
	var tolerance = radius * 2 + _target.radius * 2 + 100
	var distance =  global_position.distance_to(_target.global_position) 
	return distance < tolerance

func shoot(_target_position,_damage):
	var next_bullet := Bullet.instance()
	next_bullet.player = self
	var direction:Vector2 = global_position - _target_position
	direction = direction.normalized()
	next_bullet.start(-direction,_damage)
	bullets_node.add_child(next_bullet)
	next_bullet.global_position = global_position

func pick_up(_target:CommonStuff) -> void:
	var item = PackageItemModel.new()
	item.item_name = _target.stuff_name
	package.push_back(item)
	_target.notify_disappear()
	_target.queue_free()
	print(player_name,"捡起了",_target.stuff_name)
	emit_signal("package_item_change",_target,true)
	
#完成洗澡
func take_a_bath():
	set_status_value("清洁状态",1)

	
var is_wear_clothes = true
#脱衣服
func take_off_clothes():
	if is_wear_clothes:
		is_wear_clothes = false
		print(player_name,"脱衣服")

func to_wear_clothes():
	if not is_wear_clothes:
		is_wear_clothes = true
		print(player_name,"穿衣服")
	

func pop_item_by_name_in_package(_name):
	for item in package:
		if item.item_name == _name:
			package.erase(item)
			return item
	return null

func get_item_by_function_attribute_in_package(_function_attribute):
	for item in package:
		if item.has_attribute(_function_attribute):
			return item
	return null

func remove_item_in_package(_item):
	var item_pos = package.find(_item)
	if item_pos != -1:
		package.remove(item_pos)
		emit_signal("package_item_change",_item,false)
		
func location_change(_location_name):
	emit_signal("location_change",_location_name)
	

#受到伤害
func _on_HurtBox_area_entered(area):
	if area.owner == self:
		return 
		
	var health_status = cpu.status.statusDic["健康状态"]
	health_status.status_value = health_status.status_value - 0.1
	
	
	hurt_box.start_invincibility(0.5)
	hurt_box.show_attack_effect()
	emit_signal("be_hurt",area)
	
#受到伤害
func _on_HurtBox_body_entered(body):
	if body.player == self:
		return 
		
	var health_status = cpu.status.statusDic["健康状态"]
	health_status.status_value = health_status.status_value - body.damage
	
	body.coliision_finish()
	hurt_box.show_attack_effect()
	emit_signal("be_hurt",body)

func _on_visionSensor_find_something(_body):
	if _body is KinematicBody2D:
		emit_signal("find_some_one",_body)
	else:
		emit_signal("find_some_stuff",_body)
	

func _on_visionSensor_un_find_something(_body):
	if _body is KinematicBody2D:
		emit_signal("un_find_some_one",_body)
	else:
		emit_signal("un_find_some_stuff",_body)
	

func has_attribute(_params):
	return _params == "其他人"

func get_recent_target(_params):
	if fixed_memory.has(_params):
		return fixed_memory[_params]
	return visionSensor.get_recent_target(_params)


#开始一场组行为
func start_join_group_action(_action_name,number_num_limit = 1):
	if current_group_task and current_group_task.action_name == _action_name and current_group_task.is_group_task_running():
		#旧的组行为仍然存在
		join_group_action(current_group_task)
	else:
		current_group_task = GroupTask.new(_action_name)
		current_group_task.number_num_limit = number_num_limit
		current_group_task.add_player(self)

#加入一场组行为
func join_group_action(_group_action):
	current_group_task = _group_action
	current_group_task.add_player(self)

#获取当前的组行为
func get_group_action():
	if not current_group_task or not current_group_task.has_player(self):
		print("异常:退出 不存在的组行为 1")
	return current_group_task

#退出组行为
func quit_group_action():
	if current_group_task:
		current_group_task.remove_player(self)
		current_group_task = null

#加入组行为的成员 
func new_member_join_action(_player):
	#加入视线监听
	visionSensor._on_RealVision_body_entered(_player)
func get_current_action_name():
	if current_group_task:
		return current_group_task.action_name
	elif cpu.strategy.current_running_task:
		return cpu.strategy.current_running_task.action_name
	return ""


#行为通知 延迟通知
func notify_action(_action_name,_is_active):
	if _is_active:
		print(player_name,"预通知：",_action_name,"开始")
	else:
		print(player_name,"预通知：",_action_name,"结束")
	preprocess_action_notify_dic[_action_name] = _is_active
	
func handle_preprocess_action_notify():
	for action_name in preprocess_action_notify_dic.keys():
		var is_active = preprocess_action_notify_dic[action_name]
		if is_active:
			print(player_name,"处理预通知:",action_name,"开始")
		else:
			print(player_name,"处理预通知:",action_name,"结束")
		
		emit_signal("player_action_notify",self,action_name,is_active)
		
	preprocess_action_notify_dic.clear()
	
func ask_for_action(_asker,_action_name):
	var lover_value = relationship_system.get_relation_value_for_player("喜爱值",_asker)
	var accept_chance = response_system.check_accept_chance_by_lover_value(lover_value,_action_name)
	var random_chance = rand_range(0,1)
	var is_accept_action =  random_chance <= accept_chance
	if is_accept_action:
		set_target(_asker)
		add_response_task("加入:"+_action_name)
	return is_accept_action
	
#加入回应任务
func add_response_task(_response_action):
	#1.激活回应动机
	set_status_value("回应状态",0.4)
	#2.加入回应动作到回应列表
	response_system.add_task_to_queue(_response_action)

	


func notify_disappear():
	emit_signal("disappear_notify",self)





