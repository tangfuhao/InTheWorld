extends Node2D


onready var pathfinding = $Pathfinding
onready var ground = $Ground
onready var camera = $CameraMovement
onready var player_ui = $UI/PlayerUI


var controll_player

func _ready():
	pathfinding.create_navigation_map(ground)
	


func _on_Player_player_selected(body):
	controll_player = body
	camera.focus_player(controll_player)
	player_ui.show()
	player_ui.setup_player(controll_player)



func _on_CameraMovement_cancle_focus_player():
	player_ui.hide()
	controll_player = null
