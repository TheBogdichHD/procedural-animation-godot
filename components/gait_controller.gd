extends Node

@export var back_left: GodotIKEffector
@export var back_right: GodotIKEffector
@export var front_left: GodotIKEffector
@export var front_right: GodotIKEffector

var stepping := false
var step_pair := 0  # 0 = FL+BR, 1 = FR+BL


func _process(_delta):
	if stepping:
		return
	
	var pair = [front_left, back_right] if (step_pair == 0) else [front_right, back_left]
	
	var should_step := false
	for leg in pair:
		if leg.should_step():
			should_step = true
			break
	
	if should_step:
		for leg in pair:
			leg.step_now()
		stepping = true
		await all_legs_done(pair)
		stepping = false
		step_pair = 1 - step_pair


func all_legs_done(pair):
	while true:
		if pair.all(func(leg): return leg.is_done()):
			return
		await get_tree().process_frame
