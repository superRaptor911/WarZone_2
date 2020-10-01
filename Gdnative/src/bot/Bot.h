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
		Node   *_level;
		int team_id = 0;
		std::unique_ptr<navigate> navigation_state;
		std::unique_ptr<Attack> attack_state;

		enum class GMODE {DM, ZM, BOMBING, CP};

		enum class STATE {ROAM, ATTACK, SCOUT, FLEE, FOLLOW, 
						  CAMP, BOMB_PLANT, BOMB_DIFF, DEFEND};

	public:

		Array visible_enemies;
		Array visible_friends;

		Vector2 point_to_dir;
		float angle_left_to_rotate = 0;
		BotAttrib bot_attribute;

		GMODE game_mode;
		STATE current_state;

		float time_elapsed = 0.f;

		BotNavFlags NavFlags;
		BotCPFlags CP_Flags;
		
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

		void on_unit_removed(Node2D *unit);
		
		//returns true by given percentage 
		bool chance(int percentage);

		void setBotDifficulty(int difficulty);
		void setGameMode(String gmod);
		void gamemodeDeathmath();
		void gamemodeZm();
		void gamemodeCP();


		// States
		//	DM	
		void dm_roam();
		void dm_attack();
		void dm_scout();

		//	ZM
		void zm_roam();
		void zm_followLeader();
		void zm_attack();

		// CP
		void cp_attack();
		void cp_roam();
		void cp_defend();
		bool cp_get_uncaped_chkPt();
		bool cp_get_caped_chkPt();
		//void cp_on_born();
		void cp_on_chkPt_captured(Node *_point);

	};


	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}	
}

#endif