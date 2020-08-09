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

//#define DEBUG_MODE

namespace godot
{
	class Bot : public Node
	{
		GODOT_CLASS(Bot, Node)
	private:

		Node2D *_parent = nullptr;
		int team_id = 0;
		std::unique_ptr<navigate> navigation_state;
		std::unique_ptr<Attack> attack_state;

		enum class GMODE {DM, ZM, BOMBING};
		enum class STATE {ROAM, ATTACK, SCOUT, FLEE, FOLLOW, CAMP, BOMB_PLANT, BOMB_DIFF};
	private:

		void _loadStates();
	public:

		Navigation2D *nav = nullptr;
		Array visible_enemies;
		Array visible_friends;

		Vector2 point_to_dir;
		float angle_left_to_rotate = 0;
		BotAttrib bot_attribute;

		GMODE game_mode;
		STATE current_state;

		float time_elapsed = 0.f;

		BotNavFlags NavFlags;
		BotBombingFlags BombFlags;
		
	public:

		Bot();
		~Bot();
		static void _register_methods();
		void _init(); // our initializer called by Godot
		void _ready();
		void _process(float delta);
		void think(float delta);
		void updateVision();
		void interpolate_rotation(float delta);
		
		//returns true by given percentage 
		bool chance(int percentage);

		void setBotDifficulty(int difficulty);
		void setGameMode(String gmod);
		void gamemodeDeathmath();
		void gamemodeBombing();

		//bombing mode functions
		void on_new_round_starts();
		void on_selected_as_bomber();
		void on_bomber_selected(Node2D *bomber);
		void on_bomb_dropped();
		void on_bomb_planted();


		// States
		void dm_roam();
		void dm_attack();
		void dm_scout();
	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}	
}

#endif