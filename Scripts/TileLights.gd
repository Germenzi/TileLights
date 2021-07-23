extends Node2D

export var cell_size = 8

var surf
var obstacles:Array = ([Vector2(61, 68), Vector2(61, 67), Vector2(61, 66), Vector2(62, 66), Vector2(62, 65), Vector2(63, 64), Vector2(65, 63), Vector2(65, 62), Vector2(64, 63), Vector2(64, 64), Vector2(63, 65), Vector2(62, 67), Vector2(61, 69), Vector2(66, 61), Vector2(66, 60), Vector2(66, 62), Vector2(67, 61), Vector2(69, 61), Vector2(70, 60), Vector2(71, 59), Vector2(72, 59), Vector2(74, 58), Vector2(75, 58), Vector2(73, 59), Vector2(69, 60), Vector2(68, 60), Vector2(67, 60), Vector2(68, 59), Vector2(71, 58), Vector2(72, 58), Vector2(69, 58), Vector2(67, 59), Vector2(72, 57), Vector2(73, 57), Vector2(70, 58), Vector2(68, 58), Vector2(74, 56), Vector2(75, 56), Vector2(69, 59), Vector2(75, 57), Vector2(76, 57), Vector2(74, 57), Vector2(77, 56), Vector2(76, 56), Vector2(73, 58), Vector2(70, 59), Vector2(68, 61), Vector2(71, 60), Vector2(77, 57), Vector2(79, 56), Vector2(78, 57), Vector2(67, 62), Vector2(62, 68), Vector2(61, 70), Vector2(61, 71), Vector2(61, 72), Vector2(63, 66), Vector2(64, 65), Vector2(65, 64), Vector2(66, 63), Vector2(68, 62), Vector2(90, 61), Vector2(90, 62), Vector2(89, 63), Vector2(90, 63), Vector2(91, 63), Vector2(91, 62), Vector2(92, 62), Vector2(92, 61), Vector2(91, 61), Vector2(81, 70), Vector2(80, 70), Vector2(80, 71), Vector2(81, 71), Vector2(82, 71), Vector2(82, 70), Vector2(82, 69), Vector2(81, 69), Vector2(78, 56)])

func is_obst(cell:Vector2):
	var t = obstacles.bsearch(cell)
	if t != len(obstacles):
		return obstacles[t] == cell
	else:
		return false

func add_circle_lighter(cell:Vector2, distance:int, color:Color=Color.white):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts_ctg:PoolRealArray = PoolRealArray()
	var obsts_tg:PoolRealArray = PoolRealArray()
	var quarts:PoolByteArray = PoolByteArray()
	
	var tg:float
	var ctg:float
	
	var obst_ctg:float
	var obst_tg:float
	
	var is_visible1:bool
	var is_visible2:bool
	var is_visible3:bool
	var is_visible4:bool
	
	var is_obst1:bool
	var is_obst2:bool
	var is_obst3:bool
	var is_obst4:bool
	
	var brightness:float
	
	for y in range(distance+1):
		for x in range(sqrt(distance*distance - y*y)+1):
			tg = float(y)/x if x != 0 else distance*distance
			ctg = float(x)/y if y != 0 else distance*distance
			
			obst_ctg = (x-0.5)/(y+0.5)
			obst_tg = (y-0.5)/(x+0.5)
			
			is_obst1 = false
			is_obst2 = false
			is_obst3 = false
			is_obst4 = false
			
			if is_obst(Vector2(x0+x, y0+y)):
				is_obst1 = true
			
			if is_obst(Vector2(x0-x, y0-y)):
				is_obst2 = true
			
			if is_obst(Vector2(x0+x, y0-y)):
				is_obst3 = true
			
			if is_obst(Vector2(x0-x, y0+y)):
				is_obst4 = true
		
			is_visible1 = not is_obst1
			is_visible2 = not is_obst2
			is_visible3 = not is_obst3
			is_visible4 = not is_obst4
			
			for i in range(len(obsts_ctg)):
				if tg > obsts_tg[i] and ctg > obsts_ctg[i]:
					match quarts[i]:
						1:
							is_visible1 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst1 = false
						2:
							is_visible2 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst2 = false
						3:
							is_visible3 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst3 = false
						4:
							is_visible4 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst4 = false
			
			if is_obst1:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(1)
				
			if is_obst2:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(2)
				
			if is_obst3:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(3)
				
			if is_obst4:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(4)
					
			brightness = (distance - point_distance(Vector2(x0, y0), Vector2(x+x0, y+y0)))/distance
			
			if is_visible1:
				light_cell(Vector2(x+x0, y+y0), brightness) 
				
			if is_visible2:
				if x != 0:
					light_cell(Vector2(-x+x0, -y+y0), brightness)
					
			if is_visible3:
				if y != 0:
					light_cell(Vector2(x+x0, -y+y0), brightness)
				
			if is_visible4:
				if x != 0 and y != 0:
					light_cell(Vector2(-x+x0, y+y0), brightness)
	
func add_rhombous_lighter(cell:Vector2, distance:int):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts_ctg:PoolRealArray = PoolRealArray()
	var obsts_tg:PoolRealArray = PoolRealArray()
	var quarts:PoolByteArray = PoolByteArray()
	
	var tg:float
	var ctg:float
	
	var obst_ctg:float
	var obst_tg:float
	
	var is_visible1:bool
	var is_visible2:bool
	var is_visible3:bool
	var is_visible4:bool
	
	var is_obst1:bool
	var is_obst2:bool
	var is_obst3:bool
	var is_obst4:bool
	
	var brightness:float
	
	for y in range(distance+1):
		for x in range(distance-y+1):
			tg = float(y)/x if x != 0 else distance*distance
			ctg = float(x)/y if y != 0 else distance*distance
			
			obst_ctg = (x-0.5)/(y+0.5)
			obst_tg = (y-0.5)/(x+0.5)
			
			is_obst1 = false
			is_obst2 = false
			is_obst3 = false
			is_obst4 = false
			
			if is_obst(Vector2(x0+x, y0+y)):
				is_obst1 = true
			
			if is_obst(Vector2(x0-x, y0-y)):
				is_obst2 = true
			
			if is_obst(Vector2(x0+x, y0-y)):
				is_obst3 = true
			
			if is_obst(Vector2(x0-x, y0+y)):
				is_obst4 = true
		
			is_visible1 = not is_obst1
			is_visible2 = not is_obst2
			is_visible3 = not is_obst3
			is_visible4 = not is_obst4
			
			for i in range(len(obsts_ctg)):
				if tg > obsts_tg[i] and ctg > obsts_ctg[i]:
					match quarts[i]:
						1:
							is_visible1 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst1 = false
						2:
							is_visible2 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst2 = false
						3:
							is_visible3 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst3 = false
						4:
							is_visible4 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst4 = false
			
			if is_obst1:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(1)
				
			if is_obst2:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(2)
				
			if is_obst3:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(3)
				
			if is_obst4:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(4)
				
			brightness = float(distance-x-y)/distance
			
			if is_visible1:
				light_cell(Vector2(x+x0, y+y0), brightness) 
				
			if is_visible2:
				if x != 0:
					light_cell(Vector2(-x+x0, -y+y0), brightness)
					
			if is_visible3:
				if y != 0:
					light_cell(Vector2(x+x0, -y+y0), brightness)
				
			if is_visible4:
				if x != 0 and y != 0:
					light_cell(Vector2(-x+x0, y+y0), brightness)
					
					
func add_direct_lighter(cell:Vector2, distance:int, angle:float):
	var x0:int = cell.x
	var y0:int = cell.y
	var obsts_ctg:PoolRealArray = PoolRealArray()
	var obsts_tg:PoolRealArray = PoolRealArray()
	var quarts:PoolByteArray = PoolByteArray()
	
	var tg:float
	var ctg:float
	
	var obst_ctg:float
	var obst_tg:float
	
	var is_visible1:bool
	var is_visible2:bool
	
	var is_obst1:bool
	var is_obst2:bool
	
	var brightness:float
	
	var coef:float = tan(angle/2)
	var dist:int = distance*coef
	
	for x in range(distance+1):
		# This is necessary to take into account obstacles that cast a shadow, but can be missed
		for y in range(dist + 1):
			tg = float(y)/x if x != 0 else distance*distance
			ctg = float(x)/y if y != 0 else distance*distance
			
			obst_ctg = (x-0.5)/(y+0.5)
			obst_tg = (y-0.5)/(x+0.5)
			
			is_obst1 = false
			is_obst2 = false
			
			if is_obst(Vector2(x0+x, y0+y)):
				is_obst1 = true
			
			if is_obst(Vector2(x0+x, y0-y)):
				is_obst2 = true
			
			is_visible1 = not is_obst1
			is_visible2 = not is_obst2
			
			for i in range(len(obsts_ctg)):
				if tg > obsts_tg[i] and ctg > obsts_ctg[i]:
					match quarts[i]:
						1:
							is_visible1 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst1 = false
						2:
							is_visible2 = false
							if obst_tg > obsts_tg[i] and obst_ctg > obsts_ctg[i]:
								is_obst2 = false
			
			if is_obst1:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(1)
				
			if is_obst2:
				obsts_tg.append(obst_tg)
				obsts_ctg.append(obst_ctg)
				quarts.append(2)
				
			# And here we draw points that in light shape
			if y > coef*x:
				continue
				
			brightness = max(0.0, float(distance-x-y)/distance)
			
			if is_visible1:
				light_cell(Vector2(x+x0, y+y0), brightness) 
				
			if is_visible2:
				if y != 0:
					light_cell(Vector2(x+x0, -y+y0), brightness)
	
func point_distance(cell1:Vector2, cell2:Vector2):
	return (cell1-cell2).length()

func _process(delta):
	return # Pretty switcher between Gdscript and c++ implementations ;)
	
	var mouse_cell = pixel2cell(get_local_mouse_position())
	
	if Input.is_action_pressed("mouse_right"):
		if not mouse_cell in obstacles:
			obstacles.insert(obstacles.bsearch(mouse_cell), mouse_cell)
			print(obstacles.size())
		
	if Input.is_action_just_pressed("ui_select"):
		clear_lights()
		
	if Input.is_action_just_pressed("ui_down"):
		obstacles = PoolVector2Array()
		
	
	clear_lights()
	
	for i in obstacles:
		fill_cell(i, Color(1, 0.0, 0.0, 1.0))
		
	# ctrl + k
	add_circle_lighter(mouse_cell, 30)
#	add_rhombous_lighter(mouse_cell, 30)
#	add_direct_lighter(mouse_cell, 90, PI/4)
	update()

func pixel2cell(pixel:Vector2):
	return (pixel/cell_size).floor()
	
func cell2pixel(cell:Vector2):
	return cell*cell_size

func _ready():
	surf = VisualServer.canvas_item_create()
	obstacles.sort()
	VisualServer.canvas_item_set_parent(surf, get_canvas_item())
	VisualServer.canvas_item_set_use_parent_material(surf, true)
	
func fill_cell(cell, color):
	VisualServer.canvas_item_add_rect(surf, Rect2(cell2pixel(cell), Vector2(cell_size, cell_size)), color)
	
func light_cell(cell, brightness):
	fill_cell(cell, Color(1.0, 1.0, 1.0, brightness))
	
func clear_lights():
	VisualServer.canvas_item_clear(surf)
