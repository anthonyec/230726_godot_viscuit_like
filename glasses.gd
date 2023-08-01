class_name Rule
extends Node2D

@export var enabled: bool = true

@onready var condition := $Condition as Lens
@onready var outcome := $Outcome as Lens

func get_differences() -> Array[Difference]:
	return condition.compared_to(outcome)

func get_match_blueprint() -> MatchBlueprint:
	return MatchBlueprint.new(condition.get_drawings())
	
func get_outcome_blueprint() -> MatchBlueprint:
	return MatchBlueprint.new(outcome.get_drawings())

func has_multiple_drawings() -> bool:
	return condition.get_drawings().size() > 1
