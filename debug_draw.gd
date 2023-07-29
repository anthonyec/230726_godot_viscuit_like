extends Control

var commands: Array[Callable] = []

func _ready() -> void:
	size = get_viewport_rect().size
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	for command in commands:
		command.call()

func line(from: Vector2, to: Vector2, color: Color = Color.RED, width: int = 1) -> void:
	commands.append(func(): 
		draw_line(from, to, color, width)
	)

func rect(rect: Rect2, color: Color = Color.RED, width: int = 1) -> void:
	commands.append(func():
		draw_rect(rect, color, false, width)
	)
	
func circle(origin: Vector2, color: Color = Color.RED, radius: float = 5) -> void:
	commands.append(func():
		draw_circle(origin, radius, color)
	)
	
func match_blueprint(match_blueprint: MatchBlueprint, color: Color = Color.RED, origin: Vector2 = Vector2.ZERO) -> void:
	commands.append(func():
		var bounds = Rect2(match_blueprint.bounds)
		bounds.position = origin + bounds.position
		
		draw_rect(bounds, color, false)
		
		for drawing in match_blueprint.drawings:
			draw_circle(origin + drawing.position, 2, color)
	)
