class_name Simulation
extends Node2D

const CHANGE_RATE = 0.01

func _process(_delta: float) -> void:
	step()
	
func get_rules() -> Array[Rule]:
	var rules: Array[Rule] = []
	var children = get_parent().get_children()
	
	for child in children:
		if child.is_in_group("rule"):
			rules.append(child as Rule)
			
	return rules
	
func step() -> void:
	for rule in get_rules():
		pass
#		print(rule.condition.g)
#	for pair in glasses:
#		for change in pair.changes:
#			var drawings = Simulation.get_drawings(self, change.drawing_id)
#
#			for drawing in drawings:
#				var movement = change.movement
#
#				if change.local:
#					movement = change.movement.rotated(drawing.rotation)
#
#				drawing.position += movement * CHANGE_RATE
#				drawing.scale += change.growth * CHANGE_RATE
#				drawing.rotation += change.rotation * CHANGE_RATE
#
#				if change.transition == Glasses.Transition.DESTROY:
#					remove_child(drawing)
