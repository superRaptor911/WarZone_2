#ifndef BOT_H
#define BOT_H

#include <Godot.hpp>
#include <vector>
#include <Navigation2D.hpp>
#include <State.h>

namespace godot
{
	class Bot : public Node
	{
		GODOT_CLASS(Bot, Node)
	private:

		State *_current_state = nullptr;
		Node2D *_parent = nullptr;
		std::vector<State *> _all_the_states;

	private:

		void _loadStates();

	public:

		Navigation2D *nav = nullptr;
		std::vector<Vector2> points_of_interest;
		float _rotational_speed = 2.f;
		Array visible_enemies;
		Array visible_friends;

	public:

		Bot();
		~Bot();
		static void _register_methods();
		void _init(); // our initializer called by Godot
		void _ready();
		void _process(float delta);
		void interpolate_rotation(float delta);

	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}

	
}

#endif