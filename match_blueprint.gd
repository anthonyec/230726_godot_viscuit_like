class_name MatchBlueprint

class DrawingBlueprint:
	var id: String
	var instance_id: int
	var position: Vector2
	var size: Vector2
	var scale: Vector2
	var rotation: float

var bounds: Rect2
var drawings: Array[DrawingBlueprint]

func _init(drawings: Array[Drawing]) -> void:
	if drawings.is_empty():
		return
		
	bounds = Rect2(drawings[0].position, Vector2.ZERO)
	
	for drawing in drawings:
		bounds = bounds.merge(drawing.get_bounds())
		
	for drawing in drawings:
		var drawing_blueprint = DrawingBlueprint.new()
		
		drawing_blueprint.id = drawing.id
		drawing_blueprint.instance_id = drawing.get_instance_id()
		drawing_blueprint.position = drawing.position - bounds.position
		drawing_blueprint.scale = drawing.scale
		
		self.drawings.append(drawing_blueprint)
	
	bounds.position = Vector2.ZERO
	
func get_bounds_anchored_to(other_drawing: Drawing) -> Rect2:
	var anchored_bounds = Rect2()
	var anchor: DrawingBlueprint = null
	
	# Find drawing that first matches the same ID.
	for drawing in drawings:
		if drawing.id == other_drawing.id:
			anchor = drawing
			break
			
	if not anchor:
		return anchored_bounds
	
	anchored_bounds.position = other_drawing.position - anchor.position
	anchored_bounds.size = bounds.size
	
	return anchored_bounds

func overlap_matches(other_match_blueprint: MatchBlueprint) -> Array[int]:
	if drawings.is_empty() or other_match_blueprint.drawings.is_empty():
		return []
	
	var matched_instance_ids: Array[int] = []

	# For every drawing blueprint, check every other blueprint drawing to see
	# if it is in a similar position (using distance) and has the same ID.
	for drawing in drawings:
		for other_drawing in other_match_blueprint.drawings:
			var distance = drawing.position.distance_to(other_drawing.position)
			
			# TODO: Match on other properties like rotation, and maybe scale?
			if distance > 5 or drawing.id != other_drawing.id:
				continue
			
			matched_instance_ids.append(drawing.instance_id)
			
			if matched_instance_ids.size() == other_match_blueprint.drawings.size():
				return matched_instance_ids
	
	return []
