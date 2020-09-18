extends Area2D
export var damage:float = 0.1
onready var player = null

func _ready():
	if not player:
		player = owner
