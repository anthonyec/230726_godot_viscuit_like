class_name Glasses
extends Node2D

@onready var lens_left: Lens = $LensLeft
@onready var lens_right: Lens = $LensRight

@export var local: bool = false

var changes: Array[Change] = []

enum Transition {
	PERSIST,
	DESTROY,
	SPAWN
}

class Change:
	var drawing_id: String
	var movement: Vector2
	var growth: Vector2
	var rotation: float
	var transition: Transition
	var local: bool
	
	func _init(drawing: Drawing) -> void:
		drawing_id = drawing.id

func _ready() -> void:
	for drawing in Simulation.get_drawings(lens_left):
		var change = Change.new(drawing)
		var right_drawing = Simulation.get_drawing(lens_right, drawing.id)
		
		if right_drawing:
			change.transition = Transition.PERSIST
			change.movement = right_drawing.position - drawing.position
			change.growth = right_drawing.scale - drawing.scale
			change.rotation = right_drawing.rotation - drawing.rotation
			change.local = local
			
		if not right_drawing:
			change.transition = Transition.DESTROY
			
		changes.append(change)
		
	for drawing in Simulation.get_drawings(lens_right):
		var left_drawing = Simulation.get_drawing(lens_left, drawing.id)
			
		if not left_drawing:
			var change = Change.new(drawing)
			change.transition = Transition.SPAWN
			changes.append(change)
