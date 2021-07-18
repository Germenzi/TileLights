#include <tile_lights.h>

using namespace godot;

void TileLighter::_register_methods(){
	register_method("_process", &TileLighter::_process);

	register_method("pixel2cell", &TileLighter::pixel2cell);
	register_method("cell2pixel", &TileLighter::cell2pixel);
	register_method("fill_cell", &TileLighter::fill_cell);
	register_method("light_cell", &TileLighter::light_cell);
	register_method("is_obstacle", &TileLighter::is_obstacle);
	register_method("add_obstacle", &TileLighter::add_obstacle);
	register_method("clear_obstacles", &TileLighter::clear_obstacles);
	register_method("get_obstacles", &TileLighter::get_obstacles);
	register_method("clear_obstacles_canvas", &TileLighter::clear_obstacles_canvas);
	register_method("add_circle_lighter", &TileLighter::add_circle_lighter);

	register_property<TileLighter, int>("cell_size", &TileLighter::cell_size, 8);
}

void TileLighter::_process(float delta){
	
}

void TileLighter::_init(){
	cell_size = 8;
	obstacles = Array();

	surface = VisualServer::get_singleton()->canvas_item_create();
	VisualServer::get_singleton()->canvas_item_set_parent(surface, get_canvas_item());
}

TileLighter::TileLighter(){

}

TileLighter::~TileLighter(){

}


Vector2 TileLighter::pixel2cell(Vector2 pixel){
	return (pixel/cell_size).floor();
}

Vector2 TileLighter::cell2pixel(Vector2 cell){
	return cell*cell_size;
}

void TileLighter::fill_cell(Vector2 cell, Color color){
	Rect2 rect = Rect2(cell2pixel(cell), Vector2(cell_size, cell_size));
	VisualServer::get_singleton()->canvas_item_add_rect(surface, rect, color);
}

void TileLighter::light_cell(Vector2 cell, float brightness){
	fill_cell(cell, Color(1.0, 1.0, 1.0, brightness));
}

bool TileLighter::is_obstacle(Vector2 cell){
	return obstacles.has(cell);
}

void TileLighter::add_obstacle(Vector2 cell){
	obstacles.append(cell);
}

void TileLighter::clear_obstacles(){
	obstacles.clear();
}

Array TileLighter::get_obstacles(){
	return obstacles;
}

void TileLighter::clear_obstacles_canvas(){
	VisualServer::get_singleton()->canvas_item_clear(surface);
}

void TileLighter::add_circle_lighter(Vector2 cell, int distance){
	int x0 = cell.x;
	int y0 = cell.y;
	PoolRealArray obsts1 = PoolRealArray();
	PoolRealArray obsts2 = PoolRealArray();
	PoolIntArray quarts = PoolIntArray();

	bool flag1, flag2, flag3, flag4;

	float phi_x, phi_y;

	float x_scale;

	float lights;

	for(int y = 0; y <= distance; y++){
		x_scale = sqrt(distance*distance - y*y)/distance;
		for(int x = 0; x < distance*x_scale + 1; x++){

			if (x != 0)
				phi_x = (float)y/x;
			else
				phi_x = distance*distance;

			if (y != 0)
				phi_y = (float)x/y;
			else
				phi_y = distance*distance;

			flag1 = true;
			flag2 = true;
			flag3 = true;
			flag4 = true;

			if (is_obstacle(Vector2(x+x0, y+y0))){
				obsts1.append((y-0.5)/(x+0.5));
				obsts2.append((x-0.5)/(y+0.5));
				quarts.append(3);
				flag3 = false;
			}

			if (is_obstacle(Vector2(-x+x0, -y+y0))){
				obsts1.append((y-0.5)/(x+0.5));
				obsts2.append((x-0.5)/(y+0.5));
				quarts.append(1);
				flag1 = false;
			}

			if (is_obstacle(Vector2(-x+x0, y+y0))){
				obsts1.append((y-0.5)/(x+0.5));
				obsts2.append((x-0.5)/(y+0.5));
				quarts.append(2);
				flag2 = false;
			}

			if (is_obstacle(Vector2(x+x0, -y+y0))){
				obsts1.append((y-0.5)/(x+0.5));
				obsts2.append((x-0.5)/(y+0.5));
				quarts.append(4);
				flag4 = false;
			}

			for(int i = 0; i < obsts1.size(); i++){
				if (phi_x >= obsts1[i] && phi_y >= obsts2[i]){
					if (quarts[i] == 3)
						flag3 = false;
					else if (quarts[i] == 1)
						flag1 = false;
					else if (quarts[i] == 2)
						flag2 = false;
					else if (quarts[i] == 4)
						flag4 = false;
				}
			}
			lights = (distance-point_distance(Vector2(x0, y0), Vector2(x+x0, y+y0)))/distance;
			if (x != 0){
				if (flag3)
					light_cell(Vector2(x+x0, y+y0), lights);

				if (y != 0 && flag4)
					light_cell(Vector2(x+x0, -y+y0), lights);

			}

			if (y != 0 && flag1)
				light_cell(Vector2(-x+x0, -y+y0), lights);

			if (flag2)
				light_cell(Vector2(-x+x0, y+y0), lights);
		}
	}
}

float TileLighter::point_distance(Vector2 p1, Vector2 p2){
		return (p1-p2).length();
}