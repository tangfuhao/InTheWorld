extends KinematicBody2D
class_name Player

const Bullet = preload("res://src/world/Bullet.tscn")

export var show_log := false
export var player_name = "player1"
export (NodePath) var bullets_node_path
var bullets_node





onready var playerName = $NameDisplay/PlayerName
onready var movement = $Movement
onready var cpu = $CPU
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var visionSensor = $VisionSensor


#目标
var target = null setget set_target
#与目标的距离
var _target_distance = 0
#背包
var package = []



signal to_target_distance_update(distance)
signal be_hurt(area)
signal disappear_notify
signal package_item_change(target,is_exist)
signal find_something(body)
signal un_find_something(body)




func _process(delta):
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
	playerName.text = player_name

	visionSensor.connect("find_something",self,"_on_visionSensor_find_something")
	visionSensor.connect("un_find_something",self,"_on_visionSensor_un_find_something")

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
	var tolerance = 100
	return global_position.distance_squared_to(_target.global_position) < tolerance

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

func get_package():
	return package

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
	emit_signal("find_something",_body)

func _on_visionSensor_un_find_something(_body):
	emit_signal("un_find_something",_body)
	

func has_attribute(_params):
	return _params == "其他人"

func get_recent_target(_params):
	return visionSensor.get_recent_target(_params)

	
func notify_disappear():
	emit_signal("disappear_notify",self)



