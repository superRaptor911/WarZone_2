#ifndef MINIMAPMAKER_H
#define MINIMAPMAKER_H

#include <Godot.hpp>
#include <Array.hpp>
#include <PoolArrays.hpp>
#include <Vector2.hpp>
#include <Color.hpp>
#include <Node.hpp>

namespace godot
{
	class MinimapMaker : public Node
	{
		GODOT_CLASS(MinimapMaker, Node)
	private:

		Array _data;

	public:

		static void _register_methods();
		void _init(); // our initializer called by Godot
		void _ready();
		PoolByteArray generateMinimap(Vector2 world_size, PoolVector2Array used_cells, int cell_size = 4,Color base_color = Color(0.0f,0.0f,0.0f)
			, Color cell_color = Color(0.5f,0.8f,0.7f));
	};
}

#endif