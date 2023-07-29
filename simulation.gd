class_name Simulation
extends Node2D

signal animations_finished

const CHANGE_RATE = 0.01

func _ready() -> void:
	step()
	animations_finished.connect(step)

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
	
func get_drawings_within_bounds(bounds: Rect2) -> Array[Drawing]:
	var drawings: Array[Drawing] = []
	
	for drawing in get_drawings():
		if bounds.encloses(drawing.get_bounds()):
			drawings.append(drawing)
	
	return drawings

func get_drawings() -> Array[Drawing]:
	return Drawing.get_drawings(self)

func step() -> void:
	var scene_drawings: Array[Drawing] = get_drawings()
	var processed_scene_drawings: Array[Drawing] = []
	
	for drawing in scene_drawings:
		if processed_scene_drawings.has(drawing):
			continue
			
		for rule in get_rules():
			var result = rule.condition.matches(self, drawing)
			
			if result.has_error():
				continue
				
			processed_scene_drawings.append_array(result.affected_scene_drawings)
			apply_differences(result, rule)

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
	
	var wait_group = WaitGroup.new()
	
	for index in scene_drawings.size():
		var drawing = scene_drawings[index]
		var difference = differences[index]
		
		match difference.type:
			Difference.Type.PERSIST:
				var tween = drawing.create_tween()
				
				wait_group.bind(tween.finished)
				tween.set_parallel(true)
				
				tween.tween_property(
					drawing, 
					"position",
					drawing.position + difference.position,
					1
				)
				
				tween.tween_property(
					drawing, 
					"scale",
					drawing.scale + difference.scale,
					1
				)

				tween.tween_property(
					drawing, 
					"rotation",
					drawing.rotation + difference.rotation,
					1
				)
				
			Difference.Type.REMOVE:
				remove_child(drawing)

			Difference.Type.ADD:
				var new_drawing: Drawing = difference.drawing.duplicate() as Drawing
				new_drawing.position = difference.position
				new_drawing.rotation = difference.rotation
				new_drawing.scale = difference.scale
	
	await wait_group.finished
	animations_finished.emit()
