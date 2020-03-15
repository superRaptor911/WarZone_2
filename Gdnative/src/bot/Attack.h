#ifndef ATTACK_H
#define ATTACK_H

#include <State.h>
#include <Timer.hpp>

namespace godot
{	
	class Attack : public State
	{
	private:
		godot::Node2D *_current_enemy = nullptr;
		godot::NodePath _current_enemy_path;

		godot::Timer *_attack_pause_timer = nullptr;
		godot::Timer *_attack_timer = nullptr;

		Vector2 _old_enemy_position;

	private:

		void _getCurrentEnemy();
		void _attack_enemy();

	public:

		static void _register_methods(){}

		Attack();	
		virtual bool isStateReady();
		virtual void runState();
		virtual void startState();
		virtual void stopState();

		void on_attack_pause_timer_Timeout();
	};
}
#endif