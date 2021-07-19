extends Node2D

export var cell_size = 16

var surf
var obstacles:PoolVector2Array = PoolVector2Array()

func check_visible(start:Vector2, goal:Vector2, obsts):
	var steep = abs(goal.y-start.y) > abs(goal.x-start.x)
	if steep:
		start = Vector2(start.y, start.x)
		goal = Vector2(goal.y, goal.x)
	var reverse = start.x > goal.x
	if reverse:
		var x = start.x
		start.x = goal.x
		goal.x = x
		
		var y = start.y
		start.y = goal.y
		goal.y = y
		
	var dx = goal.x - start.x
	var dy = abs(goal.y - start.y)
	var error = dx/2
	var ystep = 1 if start.y < goal.y else -1
	var y = start.y
	for x in range(start.x, goal.x+1):
		if steep:
			if Vector2(y, x) in obsts:
				return false
		else:
			if Vector2(x, y) in obsts:
				return false
		error -= dy
		if error < 0:
			y += ystep
			error += dx
		
	return true

func add_circle_lighter(cell:Vector2, distance:int):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts1:PoolRealArray = PoolRealArray()
	var obsts2:PoolRealArray = PoolRealArray()
	var quarts:PoolIntArray = PoolIntArray()
	
	var flag1:bool
	var flag2:bool
	var flag3:bool
	var flag4:bool
	
	var is_obst1:bool
	var is_obst2:bool
	var is_obst3:bool
	var is_obst4:bool
	
	var phi_x:float
	var phi_y:float
	
	var x_scale:float
	
	for y in range(distance+1):
		x_scale = sqrt(distance*distance - y*y)/distance
		for x in range(distance*x_scale + 1):
			phi_x = float(y)/x if x != 0 else distance*distance
			phi_y = float(x)/y if y != 0 else distance*distance
			
			flag1 = true
			flag2 = true
			flag3 = true
			flag4 = true
			
			is_obst1 = false
			is_obst2 = false
			is_obst3 = false
			is_obst4 = false
			
			if Vector2(x+x0, y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(3)
				is_obst3 = true
			
			if Vector2(-x+x0, -y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(1)
				is_obst1 = true
				
			if Vector2(-x+x0, y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(2)
				is_obst2 = true
			
			if Vector2(x+x0, -y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(4)
				is_obst4 = true
			
			var n:float
			
			for i in range(len(obsts1)):
				if (phi_x >= obsts1[i] and phi_y >= obsts2[i]):
#					if phi_x != 0 and phi_y != 0:
#						n = max(0.0, min(0.5, (phi_x-obsts1[i])/phi_x *(phi_y-obsts2[i])/phi_y))
#					else:
#						n = 0
#
					match quarts[i]:
						3:
							flag3 = false
						1:
							flag1 = false
						2:
							flag2 = false
						4:
							flag4 = false
			
			var lights = (distance - point_distance(Vector2(x0, y0), Vector2(x+x0, y+y0)))/distance
#			var lights = 1.0
			if x != 0:
				if flag3:
					light_cell(Vector2(x+x0, y+y0), lights)
				else:
					light_cell(Vector2(x+x0, y+y0), n*lights)
				if y != 0 and flag4:
					light_cell(Vector2(x+x0, -y+y0), lights)
				elif y != 0:
					light_cell(Vector2(x+x0, -y+y0), n*lights)
			if y != 0 and flag1:
				light_cell(Vector2(-x+x0, -y+y0), lights)
			elif y != 0:
				light_cell(Vector2(-x+x0, -y+y0), n*lights)
				
			if flag2:
				light_cell(Vector2(-x+x0, y+y0), lights)
			else:
				light_cell(Vector2(-x+x0, y+y0), n*lights)

func point_distance(cell1:Vector2, cell2:Vector2):
	return (cell1-cell2).length()

func add_rhombous_lighter(cell:Vector2, distance:int):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts1 = []
	var obsts2 = []
	var quarts = []
	
	var flag1:bool
	var flag2:bool
	var flag3:bool
	var flag4:bool
	
	var phi_x:float
	var phi_y:float
	
	for y in range(distance+1):
		for x in range(distance-y+1):
			
			phi_x = float(y)/x if x != 0 else distance*distance
			phi_y = float(x)/y if y != 0 else distance*distance
			
			flag1 = true
			flag2 = true
			flag3 = true
			flag4 = true
			
			if Vector2(x+x0, y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(3)
				flag3 = false
			
			if Vector2(-x+x0, -y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(1)
				flag1 = false
				
			if Vector2(-x+x0, y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(2)
				flag2 = false
			
			if Vector2(x+x0, -y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				quarts.append(4)
				flag4 = false
				
			for i in range(len(obsts1)):
				if (phi_x >= obsts1[i] and phi_y >= obsts2[i]):
					match quarts[i]:
						3:
							flag3 = false
						1:
							flag1 = false
						2:
							flag2 = false
						4:
							flag4 = false
			
			if x != 0:
				if flag3:
					light_cell(Vector2(x+x0, y+y0), (distance-x-y)/float(distance))
				if y != 0 and flag4:
					light_cell(Vector2(x+x0, -y+y0), (distance-x-y)/float(distance))
			if y != 0 and flag1:
				light_cell(Vector2(-x+x0, -y+y0), (distance-x-y)/float(distance))
			if flag2:
				light_cell(Vector2(-x+x0, y+y0), (distance-x-y)/float(distance))

# light_cone_angle
func add_direct_lighter(cell:Vector2, distance:int, angle:float):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts1 = []
	var obsts2 = []
	var parts = []
	
	var flag1:bool
	var flag2:bool
	
	var phi_x:float
	var phi_y:float
	
	var y_scale:float
	
	for x in range(distance+1):
		y_scale = tan(angle/2)
		for y in range(distance*y_scale + 1):
			
			flag1 = true
			flag2 = true
			
			phi_x = float(y)/x if x != 0 else distance*distance
			phi_y = float(x)/y if y != 0 else distance*distance
			
			if Vector2(x+x0, y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				parts.append(1)
				flag1 = false
				
			if Vector2(x+x0, -y+y0) in obstacles:
				obsts1.append((y-0.5)/(x+0.5))
				obsts2.append((x-0.5)/(y+0.5))
				parts.append(2)
				flag2 = false
				
			if y < x*tan(angle/2):
				for i in range(len(obsts1)):
					if phi_x >= obsts1[i] and phi_y >= obsts2[i]:
						match parts[i]:
							1:
								flag1 = false
							2:
								flag2 = false
				
				if flag1:
					light_cell(Vector2(x+x0, y+y0), max((distance-x-y)/float(distance), 0.0))
					
				if flag2 and y != 0:
					light_cell(Vector2(x+x0, -y+y0), max((distance-x-y)/float(distance), 0.0))


func _process(delta):
	var mouse_cell = pixel2cell(get_local_mouse_position())
	
	return # Pretty switcher between Gdscript and c++ implementations ;)

	if Input.is_action_pressed("mouse_right"):
		if not mouse_cell in obstacles:
			obstacles.append(mouse_cell)
			print(obstacles.size())
		
	if Input.is_action_just_pressed("ui_select"):
		clear_lights()
		
	if Input.is_action_just_pressed("ui_down"):
		obstacles = PoolVector2Array()
	
	# I used visual server for to get rid of _draw
	# Updating canvas every frame is not necessary
	
	clear_lights()
	
	for i in obstacles:
		fill_cell(i, Color(1, 0.0, 0.0, 1.0))
	
	# ctrl + k
	add_circle_lighter(mouse_cell, 40)
#	add_rhombous_lighter(mouse_cell, 40)
#	add_direct_lighter(mouse_cell, 30, 0.8*PI)
	
	update()

func _ready():
	surf = VisualServer.canvas_item_create()
	VisualServer.canvas_item_set_parent(surf, get_canvas_item())
	VisualServer.canvas_item_set_use_parent_material(surf, true)
	
func cell2pixel(cell:Vector2):
	return cell*cell_size
	
func pixel2cell(pixel:Vector2):
	return (pixel/cell_size).floor()
	
func fill_cell(cell, color):
	VisualServer.canvas_item_add_rect(surf, Rect2(cell2pixel(cell), Vector2(cell_size, cell_size)), color)
	
func light_cell(cell, brightness):
	fill_cell(cell, Color(1.0, 1.0, 1.0, brightness))
	
func clear_lights():
	VisualServer.canvas_item_clear(surf)
