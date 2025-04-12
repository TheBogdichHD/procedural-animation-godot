extends Node3D

@export var offset: float = 0.28

@onready var parent = get_parent_node_3d()


func _process(_delta):
	var velocity = owner.velocity
	velocity.y = 0
	global_position = parent.global_position + velocity * offset
