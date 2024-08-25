extends Node2D

@export var map_size = Rect2i(Vector2i(0, 0), Vector2i(36, 20))
@export var draw_debug : bool = false

var redraw_timer = Timer.new()

func _ready() -> void:
	add_child(redraw_timer)
	redraw_timer.timeout.connect(queue_redraw)
	redraw_timer.start(0.1)

func _draw() -> void:
	if draw_debug:
		var path_grid = get_node("Player").path_grid
		
		for x in range(map_size.position.x, map_size.size.x):
			for y in range(map_size.position.y, map_size.size.y):
				draw_string(ThemeDB.fallback_font, Vector2i(x * 32, (y * 32) + 32), str(path_grid[str(x)+";"+str(y)]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.GRAY)

func _on_debug_drawing_toggled(toggled_on: bool) -> void:
	draw_debug = toggled_on
