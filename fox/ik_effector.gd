extends GodotIKEffector

@export var step_target: Node3D
@export var step_distance := 0.15

@export var adjacent_target: GodotIKEffector
@export var opposite_target: GodotIKEffector

@export var step_curve: Curve2D


var stepping_progress := 0.0
var allow_neighbor_step: bool:
	get:
		return stepping_progress <= 0.0 or stepping_progress > 0.5


func _process(_delta):
	var predicted_target = step_target.global_position
	if stepping_progress:
		return
	if global_position.distance_to(predicted_target) < step_distance:
		return
	if adjacent_target.allow_neighbor_step:
		step(predicted_target)


func curve_tween(t: float, from_pos: Vector3, target_pos: Vector3) -> void:
	var curve_pos := step_curve.samplef(t * step_curve.point_count)
	var floor_pos := from_pos.lerp(target_pos, curve_pos.x)
	var lift_height := 0.1
	var final_pos := floor_pos + Vector3.UP * curve_pos.y * lift_height
	global_position = final_pos
	stepping_progress = t


func step(target_pos: Vector3):
	stepping_progress = 0.01
	var t = get_tree().create_tween()
	t.tween_method(curve_tween.bind(global_position, target_pos), 0.0, 1.0, 0.6).set_ease(Tween.EASE_OUT)#.set_trans(Tween.TRANS_QUAD)
	t.tween_callback(func(): stepping_progress = 0.0)
