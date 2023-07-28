class_name Simulation
extends Node2D

const CHANGE_RATE = 0.01

func _ready() -> void:
	step()
	pass

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
			
			if not result.has_error():
				processed_scene_drawings.append_array(result.affected_scene_drawings)
				print("MATCH")
				# TODO: Perform difference transition.
				break
