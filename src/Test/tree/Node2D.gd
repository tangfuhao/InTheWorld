extends Node2D

onready var node1 = $Node2D
onready var node2 = $Node2D2
onready var child = $Node2D/Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	node1.remove_child(child)
	node2.add_child(child)


func _on_Node2D_tree_entered():
	print("_on_Node2D_tree_entered")
	pass # Replace with function body.


func _on_Node2D_tree_exited():
	print("_on_Node2D_tree_exited")
	pass # Replace with function body.


func _on_Node2D_tree_exiting():
	print("_on_Node2D_tree_exiting")
	pass # Replace with function body.
