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
	
func to_formatted_string() -> String:
	var string: String = ""
	
	string += "Difference " + str(self) + " {" + "\n"
	string += "  id: " + self.id + "\n"
	string += "  drawing: " + str(self.drawing) + "\n"
	string += "  type: " + Difference.Type.find_key(self.type) + "\n"
	string += "  position: " + str(self.position) + "\n"
	string += "  rotation: " + str(self.rotation) + "\n"
	string += "  scale: " + str(self.scale) + "\n"
	string += "}"
	
	return string

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
