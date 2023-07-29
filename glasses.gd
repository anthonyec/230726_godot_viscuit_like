class_name Rule
extends Node2D

@export var enabled: bool = true

@onready var condition := $Condition as Lens
@onready var outcome := $Outcome as Lens

func get_differences() -> Array[Difference]:
	return condition.compared_to(outcome)

func get_match_blueprint() -> MatchBlueprint:
	return MatchBlueprint.new(condition.get_drawings())
