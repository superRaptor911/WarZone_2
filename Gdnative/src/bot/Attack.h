#ifndef ATTACK_H
#define ATTACK_H

#include <State.h>
#include <Timer.hpp>
#include <Array.hpp>

namespace godot
{	
	class Attack : public State
	{
	private:
		godot::Node2D *_current_enemy = nullptr;
		godot::Node2D *_old_enemy = nullptr;
		godot::NodePath _current_enemy_path;

		godot::Timer *_attack_pause_timer = nullptr;
		godot::Timer *_can_attack_timer = nullptr;

		godot::Array _path_to_dest;
		Vector2 _old_dest;
		int _current_dest_id = 0;

	private:

		void _getCurrentEnemy();
		void _attack_enemy();
		bool _headToPosition(const Vector2 &pos);
		void _handleWeapons();

	public:

		Attack();
		virtual void initState();
		virtual bool isStateReady();
		virtual void runState();
		virtual void startState();
		virtual void stopState();

	};
}
#endif