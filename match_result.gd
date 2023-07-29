class_name MatchResult

enum Error {
	NONE,
	NO_DRAWING_WITH_ID,
	WRONG_DRAWING_COUNT,
	WRONG_DRAWING_ID,
	WRONG_MATCHED_COUNT,
	NO_NEAREST_DRAWING
}

var error: Error
var affected_scene_drawings: Array[Drawing]
var bounds: Rect2

func has_error() -> bool:
	return error != Error.NONE
