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
	
	var instance_ids_in_multi_rules: Array[int] = []
	var instance_ids_in_single_rules: Array[int] = []
	
	var already_matched_instance_ids: Dictionary = {}
	var instance_id_to_rules: Dictionary = {}
	var instance_id_to_affected_instance_ids: Dictionary = {}
	
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
				
			for matched_instance_id in matched_instance_ids:
				already_matched_instance_ids[matched_instance_id] = true
				
			if rule.has_multiple_drawings():
				instance_ids_in_multi_rules.append_array(matched_instance_ids)
			else:
				instance_ids_in_single_rules.append_array(matched_instance_ids)
				
			if not instance_id_to_affected_instance_ids.has(instance_id):
				instance_id_to_affected_instance_ids[instance_id] = []
			
			print(instance_id, " : ", matched_instance_ids)
			instance_id_to_affected_instance_ids[instance_id].append_array(matched_instance_ids)
				
			if not instance_id_to_rules.has(instance_id):
				instance_id_to_rules[instance_id] = []
				
			instance_id_to_rules[instance_id].append(rule)
	
	
	print(instance_id_to_rules.keys())
	print(instance_id_to_affected_instance_ids)
	var ignored_instance_ids: Array[int] = []
	
	for instance_id in instance_id_to_rules.keys():
		if ignored_instance_ids.has(instance_id):
			continue
			
		var drawing = instance_from_id(instance_id) as Drawing
		var rules = instance_id_to_rules[instance_id]
		
		var is_in_multi_rule = instance_ids_in_multi_rules.has(instance_id)
		var is_in_single_rule = instance_ids_in_single_rules.has(instance_id)
		
		if is_in_single_rule and is_in_multi_rule:
			print("DO MULTI RULE: ", drawing)
			ignored_instance_ids.append_array(instance_id_to_affected_instance_ids.get(instance_id, []))
			continue
		
		if is_in_single_rule and not is_in_multi_rule:
			print("DO SINGLE RULE: ", drawing)
			continue
		

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
