extends RayCast3D

@export var step_target: Node3D

var ground_normal := Vector3.UP


func _physics_process(_delta):
	if is_colliding():
		step_target.global_position = get_collision_point()
		ground_normal = get_collision_normal()
