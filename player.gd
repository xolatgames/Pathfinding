extends CharacterBody2D

@export var speed: float = 250

var map_size: Rect2i
var path_grid: Array[int]
var solid_tiles: Array[bool]
var player_pos: Vector2i
var add_cells: Array [Vector2i]
var next_pos: Vector2i
var target: Vector2i

@onready var tileMap = get_parent().get_node("Tiles")
var moving_timer = Timer.new()


func _ready() -> void:
	player_pos = global_position / 32
	
	map_size = get_tree().current_scene.map_size
	
	var tile: int
	
	for x in range(map_size.position.x, map_size.size.x):
		for y in range(map_size.position.y, map_size.size.y):
			path_grid.append(-1)
			solid_tiles.append(false)
	
	target = player_pos
	next_pos = player_pos
	
	for x in range(map_size.position.x, map_size.size.x):
		for y in range(map_size.position.y, map_size.size.y):
			tile = x + map_size.size.x * y
			
			if tileMap.get_cell_atlas_coords(Vector2i(x, y)) == Vector2i(0, 0):
				solid_tiles[tile] = true


func _unhandled_input(event: InputEvent) -> void:
	var tile: int
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			tile = int(event.position.x/32) + map_size.size.x * int(event.position.y/32)
			
			if solid_tiles[tile] == false:
				target = Vector2i(event.position/32)
				_move()


func _move() -> void:
	player_pos = global_position / 32
	
	var tile: int
	
	for x in range(map_size.position.x, map_size.size.x):
		for y in range(map_size.position.y, map_size.size.y):
			tile = x + map_size.size.x * y
			
			path_grid[tile] = -1
	
	next_pos = target
	
	if target != player_pos:
		tile = target.x + map_size.size.x * target.y
		
		if solid_tiles[tile] == false:
			path_grid[tile] = 0
		
		var calculated: bool = false
		
		while(!calculated):
			add_cells.clear()
			
			for x in range(map_size.position.x, map_size.size.x):
				for y in range(map_size.position.y, map_size.size.y):
					tile = x + map_size.size.x * y
					
					if path_grid[tile] == 0:
						_add_cell(x - 1, y)
						_add_cell(x + 1, y)
						_add_cell(x, y - 1)
						_add_cell(x, y + 1)
						
						path_grid[tile] += 1
						
						if player_pos == Vector2i(x, y):
							calculated = true
					
					elif  path_grid[tile] > 0:
						path_grid[tile] += 1
			
			for a in add_cells:
				tile = a.x + map_size.size.x * a.y
				
				if path_grid[tile] == -1:
					path_grid[tile] = 0
			
			if add_cells.size() < 2:
				target = player_pos
				calculated = true
		
		_get_next_pos(-1, 0)
		_get_next_pos(1, 0)
		_get_next_pos(0, -1)
		_get_next_pos(0, 1)
	
	if target == player_pos:
		next_pos = player_pos


func _physics_process(delta: float) -> void:
	velocity = global_position.direction_to(next_pos * 32) * speed
	move_and_slide()
	
	if global_position.distance_to(next_pos * 32) < 2 and global_position.distance_to(next_pos * 32) > 0:
		global_position = next_pos * 32
		_move()


func _add_cell(x, y) -> void:
	var tile: int = x + map_size.size.x * y
	
	if x < map_size.position.x or y < map_size.position.y or x > map_size.size.x - 1 or y > map_size.size.y - 1:
		return
	
	if solid_tiles[tile] == false:
		add_cells.append(Vector2i(x, y))


func _get_next_pos(x, y) -> void:
	var tile: int = (player_pos.x + x) + map_size.size.x * (player_pos.y + y)
	
	if player_pos.x + x < map_size.position.x or player_pos.y + y < map_size.position.y or player_pos.x + x > map_size.size.x - 1 or player_pos.y + y > map_size.size.y - 1:
		return
	
	if path_grid[tile] == 2:
		next_pos = Vector2i(player_pos.x + x, player_pos.y + y)
