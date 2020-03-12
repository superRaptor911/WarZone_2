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

		godot::Timer *_no_target_Timer = nullptr;
		godot::Timer *_attack_delay_timer = nullptr;

	private:

		void _getCurrentEnemy();
		void _attack_enemy();

	public:

		enum EGetMode
		{
			NEAREST = 0, RANDOM, FARTHEST
		};

		enum EAttackMode
		{
			SPRAY = 0, BURST, SINGLE
		};

		EGetMode enemy_get_mode = EGetMode::NEAREST;
		EAttackMode attack_mode = EAttackMode::BURST;

	public:

		static void _register_methods(){}

		Attack();	
		virtual bool isStateReady();
		virtual void runState();
		virtual void startState();
		virtual void stopState();

		void on_no_target_Timer_Timeout();
	};
}
#endif