extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.5

@export_group("Movement")
@export var move_speed := 2.0
@export var acceleration := 10.0 
@export var rotation_speed := 2.0
@export var jump_impulse := 3.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -10

@onready var fl_leg = %FrontLeftStepTarget
@onready var fr_leg = %FrontRightStepTarget
@onready var bl_leg = %BackLeftStepTarget
@onready var br_leg = %BackRightStepTarget

@onready var fl_leg_ray = %FrontLeftRay
@onready var fr_leg_ray = %FrontRightRay
@onready var bl_leg_ray = %BackLeftRay
@onready var br_leg_ray = %BackRightRay

@onready var back_rotation_bone: BoneAttachment3D = %BackRotationBone
@onready var front_rotation_bone: BoneAttachment3D = %FrontRotationBone

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %Fox
@onready var _skeleton: Skeleton3D = %Skeleton3D


func _input(event) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
	if event is InputEventMouseButton:
		if event.is_action("scroll_up"):
			%SpringArm3D.spring_length -= 0.01
		if event.is_action("scroll_down"):
			%SpringArm3D.spring_length += 0.01


func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_impulse
	
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	
	_update_body_rotation()


func _update_body_rotation():
	var front_normal: Vector3 = ((fl_leg_ray.ground_normal + fr_leg_ray.ground_normal)).normalized()
	var back_normal: Vector3 = ((bl_leg_ray.ground_normal + br_leg_ray.ground_normal)).normalized()
	
	back_normal = (back_normal + front_normal).normalized()
	
	var front_side := front_normal.cross(-_skin.global_basis.z)
	var back_side := back_normal.cross(-_skin.global_basis.z)
	
	var front_forward := -front_side.cross(front_normal)
	
	var front := Basis(front_side, front_forward, front_side.cross(front_forward)).orthonormalized()
	var back := Basis(-back_side, back_side.cross(back_normal), back_normal).orthonormalized()
	
	front_rotation_bone.global_basis = Basis(front_rotation_bone.global_basis.get_rotation_quaternion().slerp(front.get_rotation_quaternion(), 0.04))
	back_rotation_bone.global_basis = Basis(back_rotation_bone.global_basis.get_rotation_quaternion().slerp(back.get_rotation_quaternion(), 0.04))
