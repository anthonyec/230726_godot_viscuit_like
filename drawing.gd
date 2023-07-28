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
	
static func get_closest_drawing_to(drawings: Array[Drawing], target_drawing: Drawing) -> Drawing:
	if drawings.is_empty():
		return null
		
	var closest_drawing: Drawing = drawings[0]
	var smallest_distance: float = INF
	
	for drawing in drawings:
		var distance = drawing.position.distance_to(target_drawing.position)
		
		if distance < smallest_distance:
			closest_drawing = drawing
			smallest_distance = distance
	
	return closest_drawing
	
func get_size() -> Vector2:
	# TODO: Hard-coded until I work out how to calcuate it.
	return Vector2(44, 44)

func get_bounds() -> Rect2:
	var size = get_size()
	return Rect2(position - (size / 2), size)
