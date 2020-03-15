#ifndef BOTATTRIB_H
#define BOTATTRIB_H

#include <Godot.hpp>

namespace godot
{
	class BotAttrib : public Node
	{
		GODOT_CLASS(BotAttrib, Node)
	public:

		enum EGetMode
		{
			NEAREST = 0, NEAREST_AIM, FARTHEST
		};

		enum AttackMode
		{
			SPRAY = 0, BURST, SINGLE
		};

	public:

		int enemy_get_mode = EGetMode::NEAREST;
		int attack_mode = AttackMode::BURST;
		float accuracy = 0.5f;

	public:

		static void _register_methods()
		{
			register_property<BotAttrib, int> ("enemy_get_mode", &BotAttrib::enemy_get_mode, EGetMode::NEAREST);
			register_property<BotAttrib, int> ("attack_mode", &BotAttrib::attack_mode, AttackMode::BURST);
			register_property<BotAttrib, float> ("accuracy", &BotAttrib::accuracy, 0.5f);
		}
	};
}

#endif