#ifndef TILELIGHTS_H
#define TILELIGHTS_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <VisualServer.hpp>

namespace godot{

class TileLighter : public Node2D{
	GODOT_CLASS(TileLighter, Node2D)

private:
	RID surface;
	int cell_size;
	Array obstacles;

public:
	static void _register_methods();

	TileLighter();
	~TileLighter();

	void _init();

	void _process(float delta);

	Vector2 pixel2cell(Vector2 pixel);
	Vector2 cell2pixel(Vector2 cell);

	void light_cell(Vector2 cell, float brightness);
	void fill_cell(Vector2 cell, Color color);

	bool is_obstacle(Vector2 cell);
	void add_obstacle(Vector2 cell);
	void clear_obstacles();
	Array get_obstacles();

	void clear_obstacles_canvas();

	void add_circle_lighter(Vector2 cell, int distance);

	float point_distance(Vector2 p1, Vector2 p2);
};

}

#endif