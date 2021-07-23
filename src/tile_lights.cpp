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
	register_method("pixel2cell", &TileLighter::pixel2cell);
	register_method("cell2pixel", &TileLighter::cell2pixel);

	register_property<TileLighter, int>("cell_size", &TileLighter::cell_size, 4);
}

void TileLighter::_process(float delta){
	
}

void TileLighter::_init(){
	cell_size = 4;
	obstacles = Array();
	surface = VisualServer::get_singleton()->canvas_item_create();
	VisualServer::get_singleton()->canvas_item_set_parent(surface, get_canvas_item());
}

TileLighter::TileLighter(){

}

TileLighter::~TileLighter(){

}

void TileLighter::fill_cell(Vector2 cell, Color color){
	Rect2 rect = Rect2(cell2pixel(cell), Vector2(cell_size, cell_size));
	VisualServer::get_singleton()->canvas_item_add_rect(surface, rect, color);
}

void TileLighter::light_cell(Vector2 cell, float brightness){
	fill_cell(cell, Color(1.0, 1.0, 1.0, brightness));
}



bool TileLighter::is_obstacle(Vector2 cell){
	int i = obstacles.bsearch(cell);
	if (i < obstacles.size())
		return obstacles[i] == cell;
	else
		return false;
}

void TileLighter::add_obstacle(Vector2 cell){
	obstacles.insert(obstacles.bsearch(cell), cell);
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

Vector2 TileLighter::pixel2cell(Vector2 pixel){
	return (pixel/cell_size).floor();
}

Vector2 TileLighter::cell2pixel(Vector2 cell){
	return cell*cell_size;
}

void TileLighter::add_circle_lighter(Vector2 cell, int distance){
	int x0 = cell.x;
	int y0 = cell.y;

	PoolRealArray obsts_tg = PoolRealArray();
	PoolRealArray obsts_ctg = PoolRealArray();
	PoolIntArray quarts = PoolIntArray();

	bool is_visible1, is_visible2, is_visible3, is_visible4;
	bool is_obst1, is_obst2, is_obst3, is_obst4;

	float tg, ctg;
	float obst_tg, obst_ctg;

	float o1, o2;

	float brightness;

	for(int y = 0; y <= distance; y++){
		for(int x = 0; x < sqrt(distance*distance - y*y) + 1; x++){

			tg = x != 0 ? (float)y/x : distance*distance;
			ctg = y != 0 ? (float)x/y : distance*distance;

			is_obst1 = false;
			is_obst2 = false;
			is_obst3 = false;
			is_obst4 = false;

			obst_tg = (y-0.5)/(x+0.5);
			obst_ctg = (x-0.5)/(y+0.5);

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

			is_visible1 = !is_obst1;
			is_visible2 = !is_obst2;
			is_visible3 = !is_obst3;
			is_visible4 = !is_obst4;

			for(int i = 0; i < obsts_tg.size(); i++){
				o1 = obsts_tg[i];
				o2 = obsts_ctg[i];
				if (tg > o1 && ctg > o2){
					
					if (quarts[i] == 3){
						is_visible3 = false;
						if (obst_tg > o1 && obst_ctg > o2)
							is_obst3 = false;
					}
					else if (quarts[i] == 1){
						is_visible1 = false;
						if (obst_tg > o1 && obst_ctg > o2)
							is_obst1 = false;
					}
					else if (quarts[i] == 2){
						is_visible2 = false;
						if (obst_tg > o1 && obst_ctg > o2)
							is_obst2 = false;
					}
					else if (quarts[i] == 4){
						is_visible4 = false;
						if (obst_tg > o1 && obst_ctg > o2)
							is_obst4 = false;
					}
				}
			}
			
			if (is_obst1){
				obsts_tg.append(obst_tg);
				obsts_ctg.append(obst_ctg);
				quarts.append(1);
			}
				
			if (is_obst2){
				obsts_tg.append(obst_tg);
				obsts_ctg.append(obst_ctg);
				quarts.append(2);
			}
				
			if (is_obst3){
				obsts_tg.append(obst_tg);
				obsts_ctg.append(obst_ctg);
				quarts.append(3);
			}
				
			if (is_obst4){
				obsts_tg.append(obst_tg);
				obsts_ctg.append(obst_ctg);
				quarts.append(4);
			}
			
			brightness = (distance-point_distance(Vector2(x0, y0), Vector2(x+x0, y+y0)))/distance;
			
			if (x != 0){
				if (is_visible3)
					light_cell(Vector2(x+x0, y+y0), brightness);

				if (y != 0 && is_visible4)
					light_cell(Vector2(x+x0, -y+y0), brightness);

			}

			if (y != 0 && is_visible1)
				light_cell(Vector2(-x+x0, -y+y0), brightness);

			if (is_visible2)
				light_cell(Vector2(-x+x0, y+y0), brightness);
		}
	}
}

float TileLighter::point_distance(Vector2 p1, Vector2 p2){
		return (p1-p2).length();
}