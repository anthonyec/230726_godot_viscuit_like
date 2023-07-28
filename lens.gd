class_name Lens
extends Node2D

const SIMILAR_ROTATION = deg_to_rad(5)

func compared_to(other_lens: Lens) -> Array[Difference]:
	var differences: Array[Difference] = []
	
	# Drawings in this array get removed once they are matched, drainng the 
	# bucket to avoid generating differences for the same drawing.
	var other_drawings_bucket = Drawing.get_drawings(other_lens)
	
	for drawing in Drawing.get_drawings(self):
		var other_drawings = Drawing.get_drawings(other_lens, drawing.id)
		var difference = Difference.new(drawing.id)

		var closest_other_drawing = Drawing.get_closest_drawing_to(
			other_drawings_bucket,
			drawing
		)
		
		if closest_other_drawing and closest_other_drawing.id == drawing.id:
			difference.type = Difference.Type.PERSIST
			difference.position = closest_other_drawing.position - drawing.position
			difference.scale = closest_other_drawing.scale - drawing.scale
			difference.rotation = closest_other_drawing.rotation - drawing.rotation
			
			var index_to_remove = other_drawings_bucket.find(closest_other_drawing)
			other_drawings_bucket.remove_at(index_to_remove)
		else:
			difference.type = Difference.Type.REMOVE
		
		differences.append(difference)
	
	# Any drawings left over will be counted as new drawings to be added.
	for drawing in other_drawings_bucket:
		var difference = Difference.new(drawing.id)

		difference.type = Difference.Type.ADD
		difference.position = drawing.position
		difference.rotation = drawing.rotation
		difference.scale = drawing.scale

		differences.append(difference)
	
	return differences

func get_bounds() -> Rect2:
	var bounds = Rect2()
	
	for drawing in get_drawings():
		bounds = bounds.merge(drawing.get_bounds())
	
	return bounds
	
func get_bounds_relative_to_drawing(drawing: Drawing) -> Rect2:
	var bounds = get_bounds()
	bounds.position = drawing.position - bounds.position
	return bounds
	
func has_drawing(drawing: Drawing) -> bool:
	return Drawing.get_drawing(self, drawing.id) != null
	
func has_multiple_drawings() -> bool:
	return not Drawing.get_drawings(self).is_empty()

func get_drawings() -> Array[Drawing]:
	return Drawing.get_drawings(self)

func get_first_drawing_matching(other_drawing: Drawing) -> Drawing:
	for drawing in get_drawings():
		if drawing.id == other_drawing.id:
			return drawing
	
	return null
