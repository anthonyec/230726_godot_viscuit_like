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

func get_drawings() -> Array[Drawing]:
	return Drawing.get_drawings(self)

func get_first_drawing_matching(other_drawing: Drawing) -> Drawing:
	for drawing in get_drawings():
		if drawing.id == other_drawing.id:
			return drawing
	
	return null

func get_drawing_near_position(other_position: Vector2, tolerance: int = 10) -> Drawing:
	var bounds = get_bounds()
	
	for drawing in get_drawings():
		if drawing.position.distance_to(other_position) < tolerance:
			return drawing
	
	return null
	
class MatchResult:
	enum Error {
		NONE,
		NO_DRAWING_WITH_ID,
		WRONG_DRAWING_COUNT,
		WRONG_DRAWING_ID,
		WRONG_MATCHED_COUNT,
		NO_NEAREST_DRAWING
	}

	var error: Error
	var affected_scene_drawings: Array[Drawing]
	
	func has_error() -> bool:
		return error != Error.NONE

func matches(scene: Simulation, drawing: Drawing) -> MatchResult:
	var result = MatchResult.new()
	
	var first_matching_drawing = get_first_drawing_matching(drawing)
	
	if not first_matching_drawing:
		result.error = MatchResult.Error.NO_DRAWING_WITH_ID
		return result
	
	var bounds = get_bounds()
	var relative_bounds = get_bounds_relative_to_drawing(first_matching_drawing)
	
	# Move the bounding box around in the scene relative to the drawing being targeted.
	var scene_bounds = Rect2(relative_bounds)
	scene_bounds.position = drawing.position - scene_bounds.position
	scene_bounds = scene_bounds.grow(2)
	
	var scene_drawings_within_bounds = scene.get_drawings_within_bounds(scene_bounds)
	var matched_drawing_count: int = 0
	
	if scene_drawings_within_bounds.size() != get_drawings().size():
		result.error = MatchResult.Error.WRONG_DRAWING_COUNT
		return result
	
	for scene_drawing in scene_drawings_within_bounds:
		# TODO: Fix positions, something is a bit off by a few pixels.
		var relative_position = bounds.position + (scene_drawing.position - scene_bounds.position)
		var nearest_drawing = get_drawing_near_position(relative_position)
		
		if not nearest_drawing:
			result.error = MatchResult.Error.NO_NEAREST_DRAWING
			return result
			
		if nearest_drawing.id != scene_drawing.id:
			result.error = MatchResult.Error.NO_DRAWING_WITH_ID
			return result
		
		matched_drawing_count += 1

	if matched_drawing_count != scene_drawings_within_bounds.size():
		result.error = MatchResult.Error.WRONG_MATCHED_COUNT
		return result
	
	result.error = MatchResult.Error.NONE
	result.affected_scene_drawings = scene_drawings_within_bounds
	
	return result
