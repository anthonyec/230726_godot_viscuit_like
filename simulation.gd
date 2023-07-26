class_name Simulation
extends Node2D

var glasses: Array[Glasses] = []

func _ready() -> void:
	var children = get_parent().get_children()
	
	for child in children:
		if child.is_in_group("glasses"):
			glasses.append(child)
			
func _process(_delta: float) -> void:
	step()
	
static func get_drawings(parent: Node2D, id: String = "") -> Array[Drawing]:
	var drawings: Array[Drawing] = []
	
	for child in parent.get_children():
		if child.is_in_group("drawing"):
			var drawing = child as Drawing
			
			if drawing.id == id or id.is_empty():
				drawings.append(drawing)
	
	return drawings
	
static func get_drawing(parent: Node2D, id: String) -> Drawing:
	var drawings: Array[Drawing] = Simulation.get_drawings(parent, id)
	
	if drawings.is_empty():
		return null
		
	return drawings[0]
	
func step() -> void:
	for pair in glasses:
		for change in pair.changes:
			var drawings = Simulation.get_drawings(self, change.drawing_id)
			
			for drawing in drawings:
				var movement = change.movement
				
				if change.local:
					movement = change.movement.rotated(drawing.rotation)
					
				drawing.position += movement * 0.1
				drawing.scale += change.growth
				drawing.rotation += change.rotation * 0.1
				
				if change.transition == Glasses.Transition.DESTROY:
					remove_child(drawing)
