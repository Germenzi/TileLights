extends Node2D

onready var grid = $"../"

func _process(delta):
#	return
	
	var mouse_cell = grid.pixel2cell(get_local_mouse_position())
	
	if Input.is_action_pressed("mouse_right"):
		if not grid.is_obstacle(mouse_cell):
			grid.add_obstacle(mouse_cell)
			print(len(grid.get_obstacles()))
		
	grid.clear_obstacles_canvas()
	
	acl(mouse_cell)
	
	for i in grid.get_obstacles():
		grid.fill_cell(i, Color.blue)
		
func acl(cell):
	grid.add_circle_lighter(cell, 30)
