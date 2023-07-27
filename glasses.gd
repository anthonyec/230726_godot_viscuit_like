class_name Rule
extends Node2D

@export var enabled: bool = true

@onready var condition := $Condition as Lens
@onready var outcome := $Outcome as Lens

func _ready() -> void:
	Difference.print_differences(get_differences())

func get_differences() -> Array[Difference]:
	return condition.compared_to(outcome)
