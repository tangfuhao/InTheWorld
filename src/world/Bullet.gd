extends KinematicBody2D

export var speed := 3000.0

onready var timer := $Lifetime

var velocity := Vector2.ZERO
var player: Node
var damage:float

func _ready() -> void:
	timer.connect("timeout", self, "_on_Lifetime_timeout")
	timer.start()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		coliision_finish()
#		collision.collider.damage(10)

func coliision_finish():
	if timer.is_stopped() == false:
		timer.stop()
		clear()


func start(direction: Vector2,_damage:float) -> void:
	velocity = direction * speed
	damage = _damage

func clear() -> void:
	queue_free()


func _on_Lifetime_timeout() -> void:
	clear()
