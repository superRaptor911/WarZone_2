#ifndef BOT_H
#define BOT_H

#include <Godot.hpp>
#include <vector>
#include <Navigation2D.hpp>
#include <BotAttrib.h>

namespace godot
{
	class Bot : public Node
	{
		GODOT_CLASS(Bot, Node)
	private:

		Node2D *_parent = nullptr;

	private:

		void _loadStates();

	public:

		Navigation2D *nav = nullptr;
		Array visible_enemies;
		Array visible_friends;

		Vector2 point_to_position;
		float angle_left_to_rotate = 0;
		BotAttrib bot_attribute;

	public:

		Bot();
		~Bot();
		static void _register_methods();
		void _init(); // our initializer called by Godot
		void _ready();
		void _process(float delta);
		void interpolate_rotation(float delta);

		void setBotDifficulty(int difficulty);

	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}

	
}

#endif