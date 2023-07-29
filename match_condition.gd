class_name MatchCondition

#class DrawingProxy
#	var id: String
#	var position: Vector2
#	var size: Vector2
#	var rotation: Vector2

var bounds: Rect2
var drawings: Array[Drawing]

func _init(drawings: Array[Drawing]) -> void:
	if drawings.is_empty():
		return
		
	bounds = Rect2(drawings[0].position, Vector2.ZERO)
	
	for drawing in drawings:
		bounds = bounds.merge(drawing.get_bounds())
		
	for drawing in drawings:
		var relative_drawing = drawing.duplicate()
		
		relative_drawing.position = drawing.position - bounds.position
		self.drawings.append(relative_drawing)
	
	bounds.position = Vector2.ZERO
