class_name Difference

enum Type {
	PERSIST,
	ADD,
	REMOVE
}

var id: String
var type: Type = Type.PERSIST
var movement: Vector2
var growth: Vector2
var rotation: float
var local: bool

func _init(id: String) -> void:
	self.id = id
