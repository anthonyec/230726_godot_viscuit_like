class_name Simulation
extends Node2D

const CHANGE_RATE = 0.01

var glasses: Array[Glasses] = []

func _ready() -> void:
	var children = get_parent().get_children()
	
	for child in children:
		if child.is_in_group("glasses") and child.enabled:
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
					
				drawing.position += movement * CHANGE_RATE
				drawing.scale += change.growth * CHANGE_RATE
				drawing.rotation += change.rotation * CHANGE_RATE
				
				if change.transition == Glasses.Transition.DESTROY:
					remove_child(drawing)
