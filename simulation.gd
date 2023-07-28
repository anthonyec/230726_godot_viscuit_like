class_name Simulation
extends Node2D

const CHANGE_RATE = 0.01

func _ready() -> void:
	step()

func _process(_delta: float) -> void:
#	step()
	queue_redraw()
	
func get_rules() -> Array[Rule]:
	var rules: Array[Rule] = []
	var children = get_parent().get_children()
	
	for child in children:
		if child.is_in_group("rule"):
			rules.append(child as Rule)
			
	return rules
	
func get_rule_containing_drawing_in_condition(drawing: Drawing) -> Rule:
	for rule in get_rules():
		if rule.condition.has_drawing(drawing):
			return rule

	return null

var temp_bounds: Array[Rect2] = []

func step() -> void:
	var scene_drawings: Array[Drawing] = Drawing.get_drawings(self)
	var processed_scene_drawings: Array[Drawing] = []
	
	for drawing in scene_drawings:
		if processed_scene_drawings.has(drawing):
			continue
			
		# TODO: Change to multiple rules, an array of rules and randomly select.
		var rule = get_rule_containing_drawing_in_condition(drawing)
		
		if not rule:
			continue
			
			
		var rule_drawing = rule.condition.get_first_drawing_matching(drawing)
		
		var bounds = rule.condition.get_bounds_relative_to_drawing(rule_drawing)
		var bounds_position = drawing.position - bounds.position
		bounds.position = bounds_position
		
		temp_bounds.append(bounds)
		
	
func _draw() -> void:
	for bounds in temp_bounds:
		draw_rect(bounds, Color.RED, false, 2)
