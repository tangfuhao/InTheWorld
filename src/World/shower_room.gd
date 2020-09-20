extends Node2D
#控制淋浴间
#控制周围黑暗

signal env_change(is_drak)

export(NodePath) var shower_room_path
onready var shower_room = get_node(shower_room_path)


func _on_control_shower_timeout():
	if randf():
		shower_room.is_broke(true)
	else:
		shower_room.is_broke(false)



func _on_control_env_timeout():
	if randf():
		emit_signal("env_change",true)
	else:
		emit_signal("env_change",false)
