extends Node2D


onready var pathfinding = $Pathfinding
onready var ground = $Ground
onready var camera = $CameraMovement
onready var player_ui = $UI/PlayerUI


var controll_player


func _ready():
	pathfinding.create_navigation_map(ground)
	

func _process(delta):
	if controll_player and Input.is_action_just_pressed("operation_option"):
		var interaction_object = GlobalRef.get_key_global(GlobalRef.global_key.mouse_interaction)
		if interaction_object:
			player_ui.show_option_menu(interaction_object)
		else:
			var pos = get_global_mouse_position()
			controll_player.task_scheduler.add_tasks([["移动",pos]])
		




func _on_Player_player_selected(body):
	controll_player = body
	camera.focus_player(controll_player)
	player_ui.show()
	player_ui.setup_player(controll_player)



func _on_CameraMovement_cancle_focus_player():
	player_ui.hide()
	controll_player = null


#ui操作交互
func _on_PlayerUI_interaction_commond(_player, _target:Node2D, _task_name):
	_player.task_scheduler.add_tasks([["移动",_target.get_global_position()],[_task_name,_target]])
