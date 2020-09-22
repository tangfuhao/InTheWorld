extends KinematicBody2D
class_name Player

const Bullet = preload("res://src/World/bullet/Bullet.tscn")

export var show_log := false
export var player_name = "player1"
export (NodePath) var bullets_node_path
var bullets_node_layer





onready var playerName = $NameDisplay/PlayerName
onready var movement = $Movement
onready var cpu = $CPU
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var visionSensor = $VisionSensor



#维护关系
var relationship_system:RelationshipSystem
#行为回复
var response_system:ResponseSystem
#背包
var inventory_system:InventorySystem
#目标
var target_system:TargetSystem

#传感器组
var sensor_arr = []

#组行为
var current_group_task:GroupTask
#等到的求助flag
var wait_for_help_flag
#预处理 行为 通知 队列
var preprocess_action_notify_dic = {}




#固定记忆
export (NodePath) var shower_room_path
export (NodePath) var bed_path
var fixed_memory = {}
var radius = 8


var is_wear_clothes = true
var location

#每个实体都会生成一个唯一的node_id
var node_name


signal disappear_notify
signal player_action_notify(body,action_name,is_active)
signal location_change(body,location_name)

#设置状态值
func set_status_value(_status_name,_status_value):
	cpu.set_status_value(_status_name,_status_value)

func get_status_value(_status_name):
	return cpu.get_status_value(_status_name)

func _process(_delta):
	handle_preprocess_action_notify()
	
func _on_status_model_value_update(_status_model):
	if _status_model.status_name == "体力状态":
		if _status_model.status_value == 0.5:
			movement.switch_move_state("walk")
		elif _status_model.status_value == 1:
			movement.switch_move_state("run")


func _ready() -> void:
	playerName.text = player_name
	node_name = player_name + IDGenerator.pop_id_index()

	bullets_node_layer = get_node(bullets_node_path)
	fixed_memory["淋浴间"] = get_node(shower_room_path)
	fixed_memory["床"] = get_node(bed_path)
	
	
	response_system = ResponseSystem.new(self)
	relationship_system = RelationshipSystem.new()
	relationship_system.bind_player_vision(self)
	
	inventory_system = InventorySystem.new()
	target_system = TargetSystem.new(self)
	

	add_sensors()
	
	cpu.status.connect("status_value_update",self,"_on_status_model_value_update")

func add_sensors():
	
	add_sensor(AroundPeopleSensor.new())
	add_sensor(AroundLikePeopleSensor.new())
	add_sensor(AroundPeopleActionSensor.new())
	add_sensor(AroundEnvironmentSensor.new())
	add_sensor(SelfInventorySensor.new())
	add_sensor(SelfLocationSensor.new())
	add_sensor(SelfStateSensor.new())
	add_sensor(SelfHurtBoxSensor.new())
	add_sensor(StuffStateSensor.new())
	add_sensor(MemorySensor.new())
	add_sensor(AttackRangeSensor.new())
	
func add_sensor(_sensor):
	_sensor.setup(self)
	sensor_arr.push_back(_sensor)
	add_child(_sensor)
	
func interaction_action(_player,_action_name):
	relationship_system.interaction_action(_player,_action_name)

func is_like_people(_player):
	var lover_value = relationship_system.get_relation_value_for_player("喜爱值",_player)
	return lover_value > 0.6


func location_change(_location_name):
	location = _location_name
	emit_signal("location_change",self,location)

func set_target(_target):
	target_system.set_target(_target)
#	if _target is CommonStuff:
#		print(player_name,"的目标改为:",_target.stuff_name)
#	else:
#		print(player_name,"的目标改为:",_target.player_name)

func get_target():
	return target_system.target


func get_recent_target(_params):
	if fixed_memory.has(_params):
		return fixed_memory[_params]
	return visionSensor.get_recent_target(_params)
			

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
	bullets_node_layer.add_child(next_bullet)
	next_bullet.global_position = global_position

func pick_up(_target) -> void:
	inventory_system.add_stuff_to_package(_target)
	# print(player_name,"捡起了",_target.stuff_name)
	# emit_signal("package_item_change",_target,true)


func be_hurt(_damage):
	var health_status_value = get_status_value("健康状态")
	if _damage:
		health_status_value = health_status_value - _damage
		set_status_value("健康状态",health_status_value)
	

#脱衣服
func take_off_clothes():
	if is_wear_clothes:
		is_wear_clothes = false
		GlobalMessageGenerator.send_player_action(self,"脱衣服",null)
		GlobalMessageGenerator.send_player_stop_action(self,"脱衣服",null)
		
		# print(player_name,"脱衣服")

func to_wear_clothes():
	if not is_wear_clothes:
		is_wear_clothes = true
		GlobalMessageGenerator.send_player_action(self,"穿衣服",null)
		GlobalMessageGenerator.send_player_stop_action(self,"穿衣服",null)
		# print(player_name,"穿衣服")



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
		# print(player_name,"不存在的组行为")
		return null
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
	return null
	
#是否在同一个组任务
func is_togeter_group_action(_player):
	return get_group_action() == _player.get_group_action()


#行为通知 延迟通知
func notify_action(_action_name,_is_active):
	# if _is_active:
	# 	print(player_name,"预通知：",_action_name,"开始")
	# else:
	# 	print(player_name,"预通知：",_action_name,"结束")
	preprocess_action_notify_dic[_action_name] = _is_active
	
func handle_preprocess_action_notify():
	for action_name in preprocess_action_notify_dic.keys():
		var is_active = preprocess_action_notify_dic[action_name]
		# if is_active:
		# 	print(player_name,"处理预通知:",action_name,"开始")
		# else:
		# 	print(player_name,"处理预通知:",action_name,"结束")
		
		emit_signal("player_action_notify",self,action_name,is_active)
		
	preprocess_action_notify_dic.clear()
	
func ask_for_action(_asker,_action_name):
	var lover_value = relationship_system.get_relation_value_for_player("喜爱值",_asker)
	var accept_chance = response_system.check_accept_chance_by_lover_value(lover_value,_action_name)
	var random_chance = rand_range(0,1)
	var is_accept_action =  random_chance <= accept_chance
	if is_accept_action:
		add_response_task(_asker,"获取目标:发起人,加入:"+_action_name)
	return is_accept_action

func help_for_request(_asker,_action_name):
	fixed_memory["发起人"] = _asker
	add_response_task(_asker,_action_name)


func wait_for_help():
	if wait_for_help_flag:
		return false
	return true
	
func help_for_result(_help_flag):
	if wait_for_help_flag and wait_for_help_flag == _help_flag:
		wait_for_help_flag = null
	
#加入回应任务
func add_response_task(_asker,_action_name):
	#1.激活回应动机
	set_status_value("回应状态",0.4)
	#2.加入回应动作到回应列表
	response_system.add_task_to_queue(_asker,_action_name)


func notify_disappear():
	emit_signal("disappear_notify",self)

func has_attribute(_params):
	if not _params:
		return false
		
	if player_name == _params:
		return true
	return _params == "其他人" or _params == "发起人"
	
func get_type():
	return "player"
