class_name Difference

enum Type {
	PERSIST,
	ADD,
	REMOVE
}

var id: String
var type: Type = Type.PERSIST
var drawing: Drawing
var position: Vector2
var scale: Vector2
var rotation: float
var local: bool = true

func _init(id: String) -> void:
	self.id = id

static func print_difference(difference: Difference) -> void:
	print("Difference " + str(difference) + " {")
	print("  id: ", difference.id)
	print("  drawing: ", difference.drawing)
	print("  type: ", Difference.Type.find_key(difference.type))
	print("  position: ", difference.position)
	print("  rotation: ", difference.rotation)
	print("  scale: ", difference.scale)
	print("}")

static func print_differences(differences: Array[Difference]) -> void:
	for difference in differences:
		print_difference(difference)
