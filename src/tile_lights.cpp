#include <tile_lights.h>

using namespace godot;

void TileLighter::_register_methods(){
	register_method("_process", &TileLighter::_process);

	register_method("fill_cell", &TileLighter::fill_cell);
	register_method("light_cell", &TileLighter::light_cell);
	register_method("is_obstacle", &TileLighter::is_obstacle);
	register_method("add_obstacle", &TileLighter::add_obstacle);
	register_method("clear_obstacles", &TileLighter::clear_obstacles);
	register_method("get_obstacles", &TileLighter::get_obstacles);
	register_method("clear_obstacles_canvas", &TileLighter::clear_obstacles_canvas);
	register_method("add_circle_lighter", &TileLighter::add_circle_lighter);
}

void TileLighter::_process(float delta){
	
}

void TileLighter::_init(){
	surface = VisualServer::get_singleton()->canvas_item_create();
	VisualServer::get_singleton()->canvas_item_set_parent(surface, get_canvas_item());
}

TileLighter::TileLighter(){

}

TileLighter::~TileLighter(){

}

void TileLighter::fill_cell(Vector2 cell, Color color){
	Rect2 rect = Rect2(map_to_world(cell), get_cell_size());
	VisualServer::get_singleton()->canvas_item_add_rect(surface, rect, color);
}

void TileLighter::light_cell(Vector2 cell, float brightness){
	fill_cell(cell, Color(1.0, 1.0, 1.0, brightness));
}

bool TileLighter::is_obstacle(Vector2 cell){
	return get_cellv(cell) != INVALID_CELL;
}

void TileLighter::add_obstacle(Vector2 cell){
	set_cellv(cell, 1);
}

void TileLighter::clear_obstacles(){
	clear();
}

Array TileLighter::get_obstacles(){
	return get_used_cells();
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

	bool is_visible1, is_visible2, is_visible3, is_visible4;
	bool is_obst1, is_obst2, is_obst3, is_obst4;
	bool is_obst1f, is_obst2f, is_obst3f, is_obst4f;

	float phi_x, phi_y;
	float c1, c2;

	float o1, o2;

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

			is_visible1 = true;
			is_visible2 = true;
			is_visible3 = true;
			is_visible4 = true;

			is_obst1 = false;
			is_obst2 = false;
			is_obst3 = false;
			is_obst4 = false;

			is_obst1f = false;
			is_obst2f = false;
			is_obst3f = false;
			is_obst4f = false;

			c1 = (y-0.5)/(x+0.5);
			c2 = (x-0.5)/(y+0.5);

			if (is_obstacle(Vector2(x+x0, y+y0))){
				is_obst3 = true;
			}

			if (is_obstacle(Vector2(-x+x0, -y+y0))){
				is_obst1 = true;
			}

			if (is_obstacle(Vector2(-x+x0, y+y0))){
				is_obst2 = true;
			}

			if (is_obstacle(Vector2(x+x0, -y+y0))){
				is_obst4 = true;
			}

			for(int i = 0; i < obsts1.size(); i++){
				if (!is_visible1 && !is_visible2 && !is_visible3 && !is_visible4)
					break;
				o1 = obsts1[i];
				o2 = obsts2[i];
				if (phi_x > o1 && phi_y > o2){
					if (quarts[i] == 3){
						is_visible3 = false;
						is_obst3f = is_obst3 && (c1 < o1 || c2 < o2);
					}
					else if (quarts[i] == 1){
						is_visible1 = false;
						is_obst1f = is_obst1 && (c1 < o1 || c2 < o2);
					}
					else if (quarts[i] == 2){
						is_visible2 = false;
						is_obst2f = is_obst2 && (c1 < o1 || c2 < o2);
					}
					else if (quarts[i] == 4){
						is_visible4 = false;
						is_obst4f = is_obst4 && (c1 < o1 || c2 < o2);
					}
				}
			}
			
			if (is_visible1 && is_obst1 || is_obst1f){
				obsts1.append(c1);
				obsts2.append(c2);
				quarts.append(1);
				is_visible1 = false;
			}
				
			if (is_visible2 && is_obst2 || is_obst2f){
				obsts1.append(c1);
				obsts2.append(c2);
				quarts.append(2);
				is_visible2 = false;
			}
				
			if (is_visible3 && is_obst3 || is_obst3f){
				obsts1.append(c1);
				obsts2.append(c2);
				quarts.append(3);
				is_visible3 = false;
			}
				
			if (is_visible4 && is_obst4 || is_obst4f){
				obsts1.append(c1);
				obsts2.append(c2);
				quarts.append(4);
				is_visible4 = false;
			}
			
			lights = (distance-point_distance(Vector2(x0, y0), Vector2(x+x0, y+y0)))/distance;
			if (x != 0){
				if (is_visible3)
					light_cell(Vector2(x+x0, y+y0), lights);

				if (y != 0 && is_visible4)
					light_cell(Vector2(x+x0, -y+y0), lights);

			}

			if (y != 0 && is_visible1)
				light_cell(Vector2(-x+x0, -y+y0), lights);

			if (is_visible2)
				light_cell(Vector2(-x+x0, y+y0), lights);
		}
	}
}

float TileLighter::point_distance(Vector2 p1, Vector2 p2){
		return (p1-p2).length();
}