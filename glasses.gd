class_name Glasses
extends Node2D

@export var enabled: bool = true
@export var local: bool = false

@onready var condition: Lens = $Condition
@onready var outcome: Lens = $Outcome

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
	if not enabled:
		return
		
	for drawing in Simulation.get_drawings(condition):
		var change = Change.new(drawing)
		var outcome_drawing = Simulation.get_drawing(outcome, drawing.id)
		
		if outcome_drawing:
			change.transition = Transition.PERSIST
			change.movement = outcome_drawing.position - drawing.position
			change.growth = outcome_drawing.scale - drawing.scale
			change.rotation = outcome_drawing.rotation - drawing.rotation
			change.local = local
			
		if not outcome_drawing:
			change.transition = Transition.DESTROY
			
		changes.append(change)
		
	for drawing in Simulation.get_drawings(outcome):
		var condition_drawing = Simulation.get_drawing(condition, drawing.id)
			
		if not condition_drawing:
			var change = Change.new(drawing)
			change.transition = Transition.SPAWN
			changes.append(change)
			
	print(changes)
