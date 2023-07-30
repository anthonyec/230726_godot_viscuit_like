class_name Simulation
extends Node2D

const SPEED: int = 1

func _ready() -> void:
	step()
	return
	var timer: Timer = Timer.new()
	
	timer.connect("timeout", func():
		step()
		timer.start(1)
	)
	
	timer.autostart = true
	add_child(timer)

func _process(_delta: float) -> void:
#	step()
	pass
	
func get_rules() -> Array[Rule]:
	var rules: Array[Rule] = []
	var children = get_parent().get_children()
	
	for child in children:
		if child.is_in_group("rule"):
			rules.append(child as Rule)
			
	return rules
	
func get_drawings_within_bounds(bounds: Rect2, tolerance: int = 0) -> Array[Drawing]:
	var drawings: Array[Drawing] = []
	var check_bounds = bounds.grow(tolerance)
	
	for drawing in get_drawings():
		if check_bounds.encloses(drawing.get_bounds()):
			drawings.append(drawing)
	
	return drawings

func get_drawings() -> Array[Drawing]:
	return Drawing.get_drawings(self)

func step() -> void:
	var scene_drawings: Array[Drawing] = get_drawings()
	
	var already_matched_instance_ids: Array[int] = []
	var drawing_instance_id_to_rule: Dictionary = {}
	
	for drawing in scene_drawings:
		var instance_id = drawing.get_instance_id()
		
		if already_matched_instance_ids.has(instance_id):
			continue
		
		for rule in get_rules():
			if not rule.enabled:
				continue
			
			var rule_blueprint = rule.get_match_blueprint()
			var scene_bounds = rule_blueprint.get_bounds_anchored_to(drawing)
			
			if scene_bounds.size.x == 0 and scene_bounds.size.y == 0:
				continue
			
			var scene_drawings_within_bounds = get_drawings_within_bounds(scene_bounds, 5)
			var scene_blueprint = MatchBlueprint.new(scene_drawings_within_bounds)
			
			var matched_instance_ids = scene_blueprint.overlap_matches(rule_blueprint)
			
			DebugDraw.rect(rule_blueprint.bounds, Color.WHITE)
			DebugDraw.rect(scene_bounds)

			if matched_instance_ids.is_empty():
				continue
				
			already_matched_instance_ids.append_array(matched_instance_ids)
			
			# TODO: Clean up, maybe using a class if it's not too mem intensive?
			# Then I don't have to re-type things as dictionaries loose types.
			if not drawing_instance_id_to_rule.has(instance_id):
				drawing_instance_id_to_rule[instance_id] = {
					"multiple": [],
					"single": [],
				}
			
			if rule.has_multiple_drawings():
				drawing_instance_id_to_rule[instance_id]["multiple"].append(rule)
			else:
				drawing_instance_id_to_rule[instance_id]["single"].append(rule)
			
		
	for instance_id in drawing_instance_id_to_rule.keys():
		var drawing = instance_from_id(instance_id) as Drawing
		
		if not drawing:
			print("DRAWING NOT FOUND!")
			
		var info = drawing_instance_id_to_rule[instance_id]
		# TODO: Type this : (
		var rules = info["single"]
		
		if not info["multiple"].is_empty():
			rules = info["multiple"]
		
		print(drawing)
		print(rules)
	



func apply_differences(result: MatchResult, rule: Rule) -> void:
	var scene_drawings: Array[Drawing] = result.affected_scene_drawings
	
	# TODO: Warning, this is sorting the original array.
	scene_drawings.sort_custom(func(a: Drawing, b: Drawing):
		return a.position.distance_squared_to(result.bounds.position) > b.position.distance_squared_to(result.bounds.position)
	)
	
	var rule_bounds = rule.condition.get_bounds()
	var differences = rule.get_differences()
	
	differences.sort_custom(func(a: Difference, b: Difference):
		return a.drawing.position.distance_squared_to(rule_bounds.position) > b.drawing.position.distance_squared_to(rule_bounds.position)
	)
	
	for index in scene_drawings.size():
		var drawing = scene_drawings[index]
		var difference = differences[index]
		
		match difference.type:
			Difference.Type.PERSIST:
				var tween = drawing.create_tween()
				tween.set_parallel(true)
				
				tween.tween_property(
					drawing, 
					"position",
					drawing.position + difference.position.rotated(drawing.rotation + difference.rotation),
					SPEED
				)
				
				tween.tween_property(
					drawing, 
					"scale",
					drawing.scale + difference.scale,
					SPEED
				)

				tween.tween_property(
					drawing, 
					"rotation",
					drawing.rotation + difference.rotation,
					SPEED
				)
				
			Difference.Type.REMOVE:
				remove_child(drawing)

			Difference.Type.ADD:
				var new_drawing: Drawing = difference.drawing.duplicate() as Drawing
				new_drawing.position = difference.position
				new_drawing.rotation = difference.rotation
				new_drawing.scale = difference.scale
