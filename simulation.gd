class_name Simulation
extends Node2D

const SPEED: int = 1

func _ready() -> void:
#	step()
#	return
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
	
	var match_results: MatchResults = MatchResults.new()
	
	for drawing in scene_drawings:
		var instance_id = drawing.get_instance_id()
		
		if match_results.has(instance_id):
			continue
		
		for rule in get_rules():
			if not rule.enabled:
				continue
			
			var rule_blueprint = rule.get_match_blueprint()
			var scene_bounds = rule_blueprint.get_bounds_anchored_to(drawing)
			
			if scene_bounds.size.x == 0 and scene_bounds.size.y == 0:
				continue
			
			var scene_drawings_within_bounds = get_drawings_within_bounds(scene_bounds, 10)
			var scene_blueprint = MatchBlueprint.new(scene_drawings_within_bounds)
			
			var matched_instance_ids = scene_blueprint.overlap_matches(rule_blueprint)
			
			# Did not match rule.
			if matched_instance_ids.is_empty():
				continue
				
			match_results.add(instance_id, matched_instance_ids, rule)
	
	for result in match_results.get_results():
		var drawing = result.get("drawing") as Drawing
		var drawings = result.get("drawings", []) as Array[Drawing]
		var rules = result.get("rules", []) as Array[Rule]
		
		if rules.is_empty():
			continue
			
		var rule = rules.pick_random() as Rule
		apply_rules(drawing, drawings, rule)
		
func apply_rules(anchor: Drawing, drawings: Array[Drawing], rule: Rule) -> void:
	var differences = rule.get_differences()
	
	# Use the blueprint instead of the position differences to avoid drift that 
	# is acculumated over time with the tolerances.
	var blueprint = rule.get_outcome_blueprint()
	blueprint.anchor_to(anchor)
	
	for index in drawings.size():
		var drawing = drawings[index]
		var drawing_blueprint = blueprint.drawings[index] as MatchBlueprint.DrawingBlueprint	
		var difference = differences[index]
		
		if difference.type == Difference.Type.PERSIST:
			var tween = drawing.create_tween()
			tween.set_parallel(true)
			
			# TODO: Fix this.
			var target_position = drawing.position + difference.position
			
			if drawing != anchor:
				target_position = drawing_blueprint.position
			
			tween.tween_property(
				drawing, 
				"position",
				drawing.position + difference.position,
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
			
		if difference.type == Difference.Type.ADD:
			# TODO: Implement.
			pass
			
		if difference.type == Difference.Type.REMOVE:
			# TODO: Implement.
			pass
