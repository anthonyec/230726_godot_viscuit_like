class_name WaitGroup
extends RefCounted

signal finished

var count: int = 0

func add() -> void:
	count += 1
	
func bind(signal_event: Signal) -> void:
	add()
	signal_event.connect(remove)
	
func remove() -> void:
	count = clamp(count - 1, 0, INF)
	
	if count == 0:
		finished.emit()
