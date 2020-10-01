#include <Bot.h>
#include <KinematicBody2D.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <SceneTree.hpp>
#include <Array.hpp>
#include <string>
#include<ctime>

#define SQ(x) x*x

using namespace godot;

Bot::Bot()
{
	current_state = STATE::ROAM;
	game_mode = GMODE::DM;
	std::srand(std::time(0));
}


void Bot::_register_methods()
{
	//common 
	register_method("_process", &Bot::_process);
	register_method("_ready", &Bot::_ready);
	register_method("updateVision", &Bot::updateVision);
	register_method("setBotDifficulty", &Bot::setBotDifficulty);
	register_method("setGameMode", &Bot::setGameMode);
	register_method("think",&Bot::think);
	register_method("on_unit_removed",&Bot::on_unit_removed);

	// CP
	register_method("cp_on_chkPt_captured", &Bot::cp_on_chkPt_captured);

	register_property<Bot, Array> ("visible_enemies", &Bot::visible_enemies, Array());
	register_property<Bot, Array> ("visible_friends", &Bot::visible_friends, Array());
}


void Bot::_ready()
{
	//set parent
	_parent = static_cast<KinematicBody2D *> (get_parent());
	_level = get_tree()->get_nodes_in_group("Level")[0];

	navigation_state = std::make_unique<navigate>(_parent, this);
	attack_state = std::make_unique<Attack>(_parent, this);
	team_id = static_cast<int>(static_cast<Node *>(_parent->get("team"))->get("team_id"));
	
	// Get Point of interests
	auto POIs_node = get_tree()->get_nodes_in_group("POI");
	if (!POIs_node.empty())
	{
		auto POIs = static_cast<Node *>(POIs_node[0])->get_children();
		for (int i = 0; i < POIs.size(); i++)
		{
			NavFlags.POIs.push_back(static_cast<Node2D *>(POIs[i])->get_position());
		}
	}
	
	#ifdef DEBUG_MODE
		std::string team_name = "terrorist";
		if (team_id == 1)
			team_name = "counter_terrorist";
		DEBUG_PRINT(("team is " + team_name).c_str());
	#endif

	current_state = STATE::ROAM;
}

void Bot::on_unit_removed(Node2D *unit)
{
	if (unit == NavFlags.leader)
		NavFlags.leader = nullptr;
	
	if (unit == attack_state->current_enemy)
		attack_state->current_enemy = nullptr;	
}

void Bot::_init()
{
	//pass
}

void Bot::_process(float delta)
{
}

void Bot::think(float delta)
{
	time_elapsed += delta;
	if ( !static_cast<bool>(_parent->get("alive")) )
		return;
		
	interpolate_rotation(delta);
	if (game_mode == GMODE::DM)
		gamemodeDeathmath();
	else if (game_mode == GMODE::ZM)
		gamemodeZm();
	else if (game_mode == GMODE::CP)
		gamemodeCP();
}

void Bot::updateVision()
{
	attack_state->getEnemy();
}

//rotate the bot smoothly
void Bot::interpolate_rotation(float delta)
{
	float rotation = _parent->get_rotation();
	float new_rotation = (point_to_dir).angle() + 1.57f;

	//setting domain [0 - 2pi]
	if (new_rotation < 0.f)
		new_rotation += 6.28f;

	if (rotation < 0.f)
		rotation += 6.28f;
	
	if (rotation > 6.28f)
		rotation -= 6.28f;

	if (fabs(new_rotation - rotation) <= bot_attribute.rotational_speed * delta ||
		fabs(6.28f - fabs(new_rotation - rotation)) <= bot_attribute.rotational_speed * delta)
	{	
		rotation = new_rotation;
		_parent->set_rotation(rotation);
		angle_left_to_rotate = 0.f;
		return;
	}

	float aba = new_rotation - rotation;
	if (fabs(aba) <= 6.28f - fabs(aba))
		rotation += sign(aba) * bot_attribute.rotational_speed * delta;
	else
		rotation += -sign(aba) * bot_attribute.rotational_speed * delta;

	angle_left_to_rotate = fabs(new_rotation - rotation);
	_parent->set_rotation(rotation);
}

bool Bot::chance(int percentage)
{
	return (rand() % 100 < percentage);
}

void Bot::setBotDifficulty(int difficulty)
{
	if (difficulty == 1)
	{
		bot_attribute.rotational_speed = 1.5f;
		bot_attribute.reaction_time = 1.5f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.spray_delay = 0.7f;
		bot_attribute.accuracy = 1.f;
	}
	else if (difficulty == 2)
	{
		bot_attribute.rotational_speed = 2.f;
		bot_attribute.reaction_time = 1.2f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.spray_delay = 0.6f;
		bot_attribute.accuracy = 0.7f;
		bot_attribute.enemy_get_mode = BotAttrib::EGetMode::NEAREST_AIM;
	}
	else if (difficulty == 3)
	{
		bot_attribute.rotational_speed = 3.f;
		bot_attribute.reaction_time = 0.5f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.5f;
		bot_attribute.enemy_get_mode = BotAttrib::EGetMode::NEAREST_AIM;
	}
	else if (difficulty == 4)
	{
		bot_attribute.rotational_speed = 5.f;
		bot_attribute.reaction_time = 0.2f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.3f;
		bot_attribute.enable_evasive_mov = true;
		bot_attribute.enemy_get_mode = BotAttrib::EGetMode::NEAREST_AIM;
	}

	attack_state->resetTimers();
}


void Bot::setGameMode(String gmod)
{
	if (gmod == "TDM")
		game_mode = GMODE::DM;
	
	else if (gmod == "Zombie Mod")
	{
		game_mode = GMODE::ZM;
		auto players = get_tree()->get_nodes_in_group("User");
		int player_count = players.size();

		// Select a random leader
		if (player_count > 0)
			NavFlags.leader = static_cast<Node2D *>(players[rand() % player_count]);
		
		// Set enemy get mode to nearest
		bot_attribute.enemy_get_mode = BotAttrib::EGetMode::NEAREST;
	}
	else if (gmod == "CheckPoints")
	{
		game_mode = GMODE::CP;
		CP_Flags.check_points = get_tree()->get_nodes_in_group("CheckPoint");
	}
	
}


void Bot::gamemodeDeathmath()
{
	switch (current_state)
	{
	case STATE::ROAM:
		dm_roam();
		break;
	
	case STATE::ATTACK:
		dm_attack();
		break;
	
	case STATE::SCOUT:
		dm_scout();
		break;
	
	case STATE::FLEE:
		break;
	
	default:
		dm_roam();
		break;
	}
}

void Bot::dm_roam()
{
	navigation_state->move();
	if (navigation_state->on_final_destination)
	{
		if (chance(60) && NavFlags.POIs.size() > 0)
		{
			int rnd = rand() % NavFlags.POIs.size();
			navigation_state->addPlace(NavFlags.POIs[rnd]);
		}
		else
		{
			navigation_state->getRandomLocation();
		}
	}

	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to attack");
		#endif
	}
}

void Bot::dm_attack()
{
	if (bot_attribute.enable_evasive_mov)
	{
		if (time_elapsed - NavFlags.evasive_mov_start_time > 2.f)
		{
			NavFlags.evasive_mov_dir *= -1;
			NavFlags.evasive_mov_start_time = time_elapsed;
		}
		_parent->set("movement_vector",_parent->get_transform().get_axis(0) * NavFlags.evasive_mov_dir);		
	}
	
	attack_state->engageEnemy();
	
	if (!attack_state->current_enemy)
	{
		navigation_state->clearPlaces();
		navigation_state->addPlace(attack_state->enemy_position);
		current_state = STATE::SCOUT;
		NavFlags.scout_start_time = time_elapsed;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to scout");
		#endif
	}
	else if (bot_attribute.is_coward && static_cast<float>(_parent->get("HP")) < 35.f)
	{
		current_state = STATE::FLEE;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to flee");
		#endif
	}
}

void Bot::dm_scout()
{
	navigation_state->move();
	if (navigation_state->on_final_destination)
	{
		Vector2 mov_vct = static_cast<Vector2>(_parent->get("movement_vector"));
		double angle = atan2(mov_vct.y, mov_vct.x);
		Vector2 rot_pos = Vector2(280,280).rotated(angle + 1.57);
		Vector2 rand_pos = Vector2(2.0 * rot_pos.x * (rand() % 100) / 100.0 - rot_pos.x, 
									2.0 * rot_pos.y * (rand() % 100) / 100.0 - rot_pos.y);
		
		Vector2 pos =  static_cast<Vector2>(_level->call("getNearestPoint", _parent->get_position() + rand_pos));
		navigation_state->addPlace(pos);
	}
	// Enemy spotted
	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to attack");
		#endif
	}
	//stay in this mode for 20 seconds
	if (time_elapsed - NavFlags.scout_start_time > 20.f)
	{
		current_state = STATE::ROAM;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to Roam");
		#endif
	}
}


void Bot::gamemodeZm()
{
	switch (current_state)
	{
	case STATE::ROAM:
		zm_roam();
		break;
	
	case STATE::ATTACK:
		zm_attack();
		break;
	
	case STATE::SCOUT:
		dm_scout();
		break;
	
	case STATE::FOLLOW:
		zm_followLeader();
		break;
	
	default:
		dm_roam();
		break;
	}
}


void Bot::zm_roam()
{
	navigation_state->move();

	
	if (NavFlags.leader)
	{
		if (!static_cast<bool>(NavFlags.leader->get("alive")))
		{
			NavFlags.leader = nullptr;
			return;
		}
		

		auto leader_distance = (_parent->get_position() - NavFlags.leader->get_position()).length();
		if (leader_distance < 300.f)
		{
			current_state = STATE::FOLLOW;
			return;
		}
	}
	// Select leader (20 sec interval)
	else if (time_elapsed - NavFlags.leader_srch_start_time > 30)
	{
		NavFlags.leader_srch_start_time = time_elapsed;
		auto players = get_tree()->get_nodes_in_group("User");
		int player_count = players.size();

		// Select a random leader 50 % chance
		if (player_count > 0 && chance(50))
			NavFlags.leader = static_cast<Node2D *>(players[rand() % player_count]);		
	}
	
	
	if (navigation_state->on_final_destination)
			navigation_state->getRandomLocation();

	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to attack");
		#endif
	}
}

void Bot::zm_followLeader()
{
	//no leader
	if (!NavFlags.leader)
	{
		navigation_state->clearPlaces();
		current_state = STATE::ROAM;
	}
	//leader is dead
	else if (!static_cast<bool>(NavFlags.leader->get("alive")) )
	{
		NavFlags.leader = nullptr;
	}

	//leader too far
	else if ((_parent->get_position() - NavFlags.leader->get_position()).length() > 300.f)
	{
		//go towards player
		navigation_state->clearPlaces();
		navigation_state->addPlace(NavFlags.leader->get_position());
		current_state = STATE::ROAM;
	}
	
	navigation_state->followLeader();
	
	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to attack");
		#endif
	}
}

void Bot::zm_attack()
{
	if (bot_attribute.enable_evasive_mov)
	{
		if (time_elapsed - NavFlags.evasive_mov_start_time > 2.f)
		{
			NavFlags.evasive_mov_dir *= -1;
			NavFlags.evasive_mov_start_time = time_elapsed;
		}
		_parent->set("movement_vector",_parent->get_transform().get_axis(0) * NavFlags.evasive_mov_dir);		
	}
	
	attack_state->engageEnemy();


	if (attack_state->current_enemy)
	{
		// Move back, keep distance from zombies
		auto vector = (_parent->get_position() - attack_state->current_enemy->get_position());
		
		if (vector.length_squared() < SQ(300.f))
			_parent->set("movement_vector", vector);
	}
	// No enemy, change state
	else
	{
		navigation_state->clearPlaces();
		navigation_state->addPlace(attack_state->enemy_position);
		current_state = STATE::SCOUT;
		NavFlags.scout_start_time = time_elapsed;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to scout");
		#endif
	}
}


void Bot::gamemodeCP()
{
	switch (current_state)
	{
	case STATE::ROAM:
		cp_roam();
		break;
	
	case STATE::ATTACK:
		cp_attack();
		break;
	
	case STATE::SCOUT:
		dm_scout();
		break;
	
	case STATE::DEFEND:
		cp_defend();
		break;
	
	default:
		cp_roam();
		break;
	}
}

void Bot::cp_attack()
{
	// Do evasive movement during fire fight.
	if (bot_attribute.enable_evasive_mov)
	{
		if (time_elapsed - NavFlags.evasive_mov_start_time > 2.f)
		{
			NavFlags.evasive_mov_dir *= -1;
			NavFlags.evasive_mov_start_time = time_elapsed;
		}
		_parent->set("movement_vector",_parent->get_transform().get_axis(0) * NavFlags.evasive_mov_dir);		
	}
	
	// Attack enemies
	attack_state->engageEnemy();
	
	// If no enemy
	if (!attack_state->current_enemy)
	{
		navigation_state->clearPlaces();
		navigation_state->addPlace(attack_state->enemy_position);
		
		// Look for enemies (scout)
		if (chance(40))
		{
			current_state = STATE::SCOUT;
			NavFlags.scout_start_time = time_elapsed;
		}
		// Go to CP
		else
		{
			current_state = STATE::ROAM;
			navigation_state->clearPlaces();
			if (!CP_Flags.cur_chk_pt)
			{
				if (!cp_get_uncaped_chkPt())
					cp_get_caped_chkPt();
			}

			if (CP_Flags.cur_chk_pt)
				navigation_state->addPlace(CP_Flags.cur_chk_pt->get_position());
		}
	}
}


void Bot::cp_roam()
{
	navigation_state->move();
	if (navigation_state->on_final_destination)
	{
		// No target CP, Get New CP
		if (!CP_Flags.cur_chk_pt)
		{
			if (!cp_get_uncaped_chkPt())
				cp_get_caped_chkPt();

			if (CP_Flags.cur_chk_pt)
				navigation_state->addPlace(CP_Flags.cur_chk_pt->get_position());
		}
		// Reached Enemy controlled CP
		else if (CP_Flags.cur_chk_pt_holding_team != team_id)
		{
			// Do Nothing
		}
		else
		{
			if (!cp_get_uncaped_chkPt())
				cp_get_caped_chkPt();

			navigation_state->clearPlaces();
			if (CP_Flags.cur_chk_pt)
				navigation_state->addPlace(CP_Flags.cur_chk_pt->get_position());
		}
	}

	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
	}
}


void Bot::cp_defend()
{
	if (time_elapsed - CP_Flags.defend_start_time > CP_Flags.defend_time)
	{
		current_state = STATE::ROAM;
		navigation_state->clearPlaces();
		if (!CP_Flags.cur_chk_pt)
		{
			if (!cp_get_uncaped_chkPt())
				cp_get_caped_chkPt();
		}

		if (CP_Flags.cur_chk_pt)
			navigation_state->addPlace(CP_Flags.cur_chk_pt->get_position());
	}

	if (!visible_enemies.empty())
	{
		current_state = STATE::ATTACK;
		#ifdef DEBUG_MODE
			DEBUG_PRINT("changing state to attack");
		#endif
	}
}


// Function to get uncaptured CP
bool Bot::cp_get_uncaped_chkPt()
{
	Array un_caps;
	for(int i = 0; i < CP_Flags.check_points.size(); i++)
	{
		int chk_pt_team_id = static_cast<Node *>(CP_Flags.check_points[i])->get("holding_team");
		if (chk_pt_team_id != team_id)
		{
			un_caps.append(CP_Flags.check_points[i]);
		}
	}

	if (un_caps.empty())
	{
		return false;
	}

	if (CP_Flags.cur_chk_pt)
	{
		if (CP_Flags.cur_chk_pt->is_connected("team_captured_point", this, "cp_on_chkPt_captured"))
		{
			CP_Flags.cur_chk_pt->disconnect("team_captured_point", this, "cp_on_chkPt_captured");
		}
	}
	
	
	int rnd_id = rand() % un_caps.size();
	CP_Flags.cur_chk_pt = static_cast<Node2D*>(un_caps[rnd_id]);
	CP_Flags.cur_chk_pt->connect("team_captured_point", this, "cp_on_chkPt_captured");
	CP_Flags.cur_chk_pt_holding_team = (1 - team_id);
	return true;
}


// Function to get captured CP
bool Bot::cp_get_caped_chkPt()
{
	Array caped_pts;
	for(int i = 0; i < CP_Flags.check_points.size(); i++)
	{
		int chk_pt_team_id = static_cast<Node *>(CP_Flags.check_points[i])->get("holding_team");
		if (chk_pt_team_id == team_id)
		{
			caped_pts.append(CP_Flags.check_points[i]);
		}
	}

	if (caped_pts.empty())
	{
		return false;
	}

	if (CP_Flags.cur_chk_pt)
	{
		if (CP_Flags.cur_chk_pt->is_connected("team_captured_point", this, "cp_on_chkPt_captured"))
		{
			CP_Flags.cur_chk_pt->disconnect("team_captured_point", this, "cp_on_chkPt_captured");
		}
	}
	
	
	int rnd_id = rand() % caped_pts.size();
	CP_Flags.cur_chk_pt = static_cast<Node2D*>(caped_pts[rnd_id]);
	CP_Flags.cur_chk_pt->connect("team_captured_point", this, "cp_on_chkPt_captured");
	CP_Flags.cur_chk_pt_holding_team = team_id;
	return true;
}



// Called when selected CP gets captured
void Bot::cp_on_chkPt_captured(Node *_point)
{
	// Switch holding team
	CP_Flags.cur_chk_pt_holding_team = 1 - CP_Flags.cur_chk_pt_holding_team;

	// Enimies captureed our CP, Head towards CP
	if (CP_Flags.cur_chk_pt_holding_team != team_id)
		return;
	
	// CP captured by our Team, Select new CP
	CP_Flags.cur_chk_pt->disconnect("team_captured_point", this, "cp_on_chkPt_captured");
	CP_Flags.cur_chk_pt = nullptr;

	if (!cp_get_uncaped_chkPt())
		cp_get_caped_chkPt();

	current_state = STATE::ROAM;
	
	navigation_state->clearPlaces();
	if (CP_Flags.cur_chk_pt)
		navigation_state->addPlace(CP_Flags.cur_chk_pt->get_position());
}


Bot::~Bot()
{
}