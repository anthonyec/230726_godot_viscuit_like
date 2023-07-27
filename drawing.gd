class_name Drawing
extends Node2D

@export var id: String = "Icon"

static func get_drawings(node: Node2D, id: String = "") -> Array[Drawing]:
	var drawings: Array[Drawing] = []
	
	for child in node.get_children():
		if child.is_in_group("drawing"):
			var drawing = child as Drawing
			
			if drawing.id == id or id.is_empty():
				drawings.append(drawing)
	
	return drawings
	
static func get_drawing(node: Node2D, id: String) -> Drawing:
	var drawings: Array[Drawing] = Drawing.get_drawings(node, id)
	
	if drawings.is_empty():
		return null
		
	return drawings[0]
