extends Camera2D

export var panSpeed = 10.0
export var speed = 10.0
export var zoomspeed = 10.0
export var zoommargin = 0.1

export var zoomMin = 0.25
export var zoomMax = 3.0
export var marginX = 200.0
export var marginY = 200.0

var mousepos = Vector2()
var mouseposGlobal = Vector2()
var start = Vector2()
var startv = Vector2()
var end = Vector2()
var endv = Vector2()
var zoomfactor = 1.0
var zooming = false
var is_dragging = false
var move_to_point = Vector2()

var focus_player


signal cancle_focus_player

func _process(_delta):
	if focus_player :
		handle_player_operation(_delta)
	else:
		handle_camera_operation(_delta)

	

func handle_player_operation(_delta):
	if Input.is_action_just_pressed("back"):
		focus_player(null)
		emit_signal("cancle_focus_player")

func handle_camera_operation(_delta):
	#smooth movement
	var inpx = (int(Input.is_action_pressed("ui_right"))
					   - int(Input.is_action_pressed("ui_left")))
	var inpy = (int(Input.is_action_pressed("ui_down"))
					   - int(Input.is_action_pressed("ui_up")))
	position.x = lerp(position.x, position.x + inpx *speed * zoom.x,speed * _delta)
	position.y = lerp(position.y, position.y + inpy *speed * zoom.y,speed * _delta)

	if Input.is_key_pressed(KEY_CONTROL):
		#check mousepos
		if mousepos.x < marginX:
			position.x = lerp(position.x, position.x - abs(mousepos.x - marginX)/marginX * panSpeed * zoom.x, panSpeed * _delta)
		elif mousepos.x > OS.window_size.x - marginX:
			position.x = lerp(position.x, position.x + abs(mousepos.x - OS.window_size.x + marginX)/marginX *  panSpeed * zoom.x, panSpeed * _delta)
		if mousepos.y < marginY:
			position.y = lerp(position.y, position.y - abs(mousepos.y - marginY)/marginY * panSpeed * zoom.y, panSpeed * _delta)
		elif mousepos.y > OS.window_size.y - marginY:
			position.y = lerp(position.y, position.y + abs(mousepos.y - OS.window_size.y + marginY)/marginY * panSpeed * zoom.y, panSpeed * _delta)
	

	
	
	#zoom in
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed * _delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed * _delta)

	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)

	if not zooming:
		zoomfactor = 1.0


func focus_player(_player):
	if focus_player == _player:
		return
	
	
	if _player:
		self.get_parent().remove_child(self)
		_player.add_child(self)
		global_position.x = _player.global_position.x
		global_position.y = _player.global_position.y
		
		zoom.x = 0.5
		zoom.y = 0.5
	else:
		var root_node = self.get_node("/root/Island")
		self.get_parent().remove_child(self)
		root_node.add_child(self)
		
		global_position.x = focus_player.global_position.x
		global_position.y = focus_player.global_position.y
		zoom.x = 1
		zoom.y = 1
		
	focus_player = _player
	

		
	



func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.button_index == BUTTON_WHEEL_UP:
				zoomfactor -= 0.01 * zoomspeed
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoomfactor += 0.01 * zoomspeed
		else:
			zooming = false
		
