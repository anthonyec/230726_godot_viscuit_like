class_name Lens
extends Node2D

const SIMILAR_ROTATION = deg_to_rad(5)

func compare(other_lens: Lens) -> Array[Difference]:
	var differences: Array[Difference] = []
	
	for drawing in Drawing.get_drawings(self):
		var other_drawing = Drawing.get_drawing(other_lens, drawing.id)
		var difference = Difference.new(drawing.id)
		
		if other_drawing:
			difference.type = Difference.Type.PERSIST
			difference.position = other_drawing.position - drawing.position
			difference.scale = other_drawing.scale - drawing.scale
			difference.rotation = other_drawing.rotation - drawing.rotation
		else:
			difference.type = Difference.Type.REMOVE
		
		differences.append(difference)
		
	for drawing in Drawing.get_drawings(other_lens):
		var existing_differences = differences.filter(func(difference):
			return difference.id == drawing.id
		)
				
		if not existing_differences.is_empty():
			continue

		var difference = Difference.new(drawing.id)

		difference.type = Difference.Type.ADD
		difference.position = drawing.position
		difference.rotation = drawing.rotation
		difference.scale = drawing.scale

		differences.append(difference)
	
	return differences

func get_closest_drawing(other_drawing: Drawing) -> Drawing:
	var drawings = Drawing.get_drawings(self, other_drawing.id)
	
	if drawings.is_empty():
		return null
	
	var closest_drawing: Drawing = drawings[0]
	var smallest_distance: float = INF
	
	for drawing in drawings:
		var distance = drawing.position.distance_to(other_drawing.position)
		
		if distance < smallest_distance:
			closest_drawing = drawing
	
	return closest_drawing
