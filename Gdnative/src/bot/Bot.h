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

#define DEBUG_MODE

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
		enum class STATE {ROAM, ATTACK, SCOUT, FLEE, FOLLOW, CAMP, BOMB_PLANT};
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

		void onNewBombingRoundStarted();
		void onBombingRoundEnds();
		void onEnteredBombSite();
		void onBombPlanted();
		void onSelectedAsBomber();
		void onKilled();
	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}	
}

#endif