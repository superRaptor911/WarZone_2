#ifndef BOT_H
#define BOT_H

#include <Godot.hpp>
#include <vector>
#include <Navigation2D.hpp>
#include <BotAttrib.h>
#include <navigate.h>
#include <Attack.h>
#include <memory>
#include <BotFlags.h>

namespace godot
{
	class Bot : public Node
	{
		GODOT_CLASS(Bot, Node)
	private:

		Node2D *_parent = nullptr;
		std::unique_ptr<navigate> navigation_state;
		std::unique_ptr<Attack> attack_state;

		enum class GMODE {DM, ZM, BOMBING};
		enum class STATE {ROAM, ATTACK};
		BotFlags flags;

	private:

		void _loadStates();
	public:

		Navigation2D *nav = nullptr;
		Array visible_enemies;
		Array visible_friends;

		Vector2 point_to_position;
		float angle_left_to_rotate = 0;
		BotAttrib bot_attribute;

		GMODE game_mode;
		STATE current_state;

	public:

		Bot();
		~Bot();
		static void _register_methods();
		void _init(); // our initializer called by Godot
		void _ready();
		void _process(float delta);
		void updateVision();
		void interpolate_rotation(float delta);

		void setBotDifficulty(int difficulty);
		void setGameMode(String gmod);
		void gamemodeDeathmath();
	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}	
}

#endif