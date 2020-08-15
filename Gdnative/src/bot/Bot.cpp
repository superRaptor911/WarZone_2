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

	//bombing mode
	register_method("on_new_round_starts",&Bot::on_new_round_starts);
	register_method("on_bomber_selected",&Bot::on_bomber_selected);
	register_method("on_bomb_dropped",&Bot::on_bomb_dropped);
	register_method("on_bomb_planted",&Bot::on_bomb_planted);

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
	else if (game_mode == GMODE::BOMBING)
		gamemodeBombing();
	else if (game_mode == GMODE::ZM)
		gamemodeZm();
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
		bot_attribute.enable_evasive_mov = true;
		bot_attribute.enemy_get_mode = BotAttrib::EGetMode::NEAREST_AIM;
	}
	else if (difficulty == 3)
	{
		bot_attribute.rotational_speed = 3.f;
		bot_attribute.reaction_time = 0.5f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.5f;
		bot_attribute.enable_evasive_mov = true;
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

	else if (gmod == "Bombing")
	{
		game_mode = GMODE::BOMBING;
	
		Array sites = get_tree()->get_nodes_in_group("Bomb_site");
		int count = sites.size();
		for (int i = 0; i < count; i++)
		{
			BombFlags.bomb_sites.append(static_cast<Node2D *>(sites[i])->get_position());
			DEBUG_PRINT(std::to_string(static_cast<Node2D *>(sites[i])->get_position().x).c_str());
		}

			if (count == 0)
				DEBUG_PRINT("Error : no bombsite in bombing mode");


		Array poi_s = get_tree()->get_nodes_in_group("POI");
		if (!poi_s.empty())
		{
			Array points = static_cast<Node *>(poi_s[0])->get_children();
			count = points.size();
			for (int i = 0; i < count; i++)
			{
				if ( static_cast<int>(static_cast<Node2D *>(points[i])->get("team_id")) == team_id)
				{
					BombFlags.poi_s.append(static_cast<Node2D *>(points[i])->get_position());
				}				
			}

			if (count == 0)
				DEBUG_PRINT("Error : pois not found");
		}
		
		current_state = STATE::CAMP;
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
		if (chance(100))
			navigation_state->getRandomLocation();
		else
		{
			
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
	else if (time_elapsed - NavFlags.leader_srch_start_time > 20)
	{
		NavFlags.leader_srch_start_time = time_elapsed;
		auto players = get_tree()->get_nodes_in_group("User");
		int player_count = players.size();

		// Select a random leader
		if (player_count > 0)
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


void Bot::gamemodeBombing()
{
	if (current_state == STATE::ROAM)
	{	
		navigation_state->move();
		if (navigation_state->on_final_destination)
		{
			if (BombFlags.mission == BotBombingFlags::MISSION::GOTO_BOMBSPOT)
			{
				int id = BombFlags.selected_bombSite_id;
				if ( (_parent->get_position() - BombFlags.bomb_sites[id]).length() < 64.f)
				{
					BombFlags.mission = BotBombingFlags::MISSION::NOTHING;
					if (BombFlags.is_bomber)
					{
						current_state = STATE::BOMB_PLANT;
						BombFlags.camp_time_start = time_elapsed;
					}
					else if (team_id == 1 && BombFlags.bomb_planted)
					{
						Node2D *c4 = get_tree()->get_nodes_in_group("C4Bomb")[0];
						if ( (c4->get_position() - _parent->get_position()).length() < 220.f)
						{
							if ((c4->get_position() - _parent->get_position()).length() > 64.f)
							{
								current_state = STATE::ROAM;
								navigation_state->addPlace(c4->get_position());
								BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
								#ifdef DEBUG_MODE
									DEBUG_PRINT("i am not near Bomb");
								#endif
							}
							else
							{
								current_state = STATE::BOMB_DIFF;
								BombFlags.camp_time_start = time_elapsed;
								#ifdef DEBUG_MODE
									DEBUG_PRINT("i am Bomb diffusing");
								#endif
							}
						}
						else
						{
							#ifdef DEBUG_MODE
								DEBUG_PRINT("i am at wrong bomb site");
							#endif

							BombFlags.selected_bombSite_id += 1;
							if (BombFlags.selected_bombSite_id >= BombFlags.bomb_sites.size())
								BombFlags.selected_bombSite_id = 0;
							
							navigation_state->addPlace(BombFlags.bomb_sites[BombFlags.selected_bombSite_id]);
						}
					}
					else
					{
						if (chance(60))
						{
							current_state = STATE::CAMP;
							BombFlags.camp_time_start = time_elapsed;
						}
						else
							navigation_state->getRandomLocation();
					}			
				}
				else
				{
					navigation_state->addPlace(BombFlags.bomb_sites[id]);
				}
			}
			else if (BombFlags.mission == BotBombingFlags::MISSION::GET_BOMB)
			{
				Node2D *c4 = get_tree()->get_nodes_in_group("C4Bomb")[0];
				navigation_state->addPlace(c4->get_position());
			}
			else
			{
				if (chance(75) && (BombFlags.poi_s.size() != 0))
				{

					int rand_id = rand() % BombFlags.poi_s.size();
					navigation_state->addPlace(BombFlags.poi_s[rand_id]);
				}
				else
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
	else if (current_state == STATE::CAMP)
	{
		if (time_elapsed - BombFlags.camp_time_start > BombFlags.max_camp_time)
			current_state = STATE::ROAM;
		
		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("changing state to attack");
			#endif
		}
	}
	else if (current_state == STATE::ATTACK)
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
			if (team_id == 1 && BombFlags.bomb_planted)
			{
				navigation_state->addPlace(BombFlags.bomb_sites[BombFlags.selected_bombSite_id]);
				current_state = STATE::ROAM;
				#ifdef DEBUG_MODE
					DEBUG_PRINT("i must diffuse bomb");
				#endif
				return;
			}
			
			navigation_state->clearPlaces();
			navigation_state->addPlace(attack_state->enemy_position);
			current_state = STATE::SCOUT;
			NavFlags.scout_start_time = time_elapsed;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("changing state to scout");
			#endif
		}		
	}
	else if (current_state == STATE::SCOUT)
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
		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("changing state to attack");
			#endif
		}
		//stay in this mode for 30 seconds
		if (time_elapsed - NavFlags.scout_start_time > 20.f)
		{
			current_state = STATE::ROAM;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("changing state to Roam");
			#endif
		}
	}
	else if (current_state == STATE::BOMB_PLANT)
	{
		if (time_elapsed - BombFlags.camp_time_start > 3.0) 
		{
			Node *gameMode = get_tree()->get_nodes_in_group("GameMode")[0];
			gameMode->rpc_id(1,"S_peerPlantedBomb");
			current_state = STATE::ROAM;
			BombFlags.is_bomber = false;
		}
		
		else if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("changing state to attack from planting");
			#endif
		}
	}
	else if (current_state == STATE::BOMB_DIFF)
	{
		if (time_elapsed - BombFlags.camp_time_start > 5.0) 
		{
			Node *gameMode = get_tree()->get_nodes_in_group("GameMode")[0];
			gameMode->rpc_id(1,"S_peerDiffusedBomb");
			current_state = STATE::ROAM;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("i diffused bomb !!!");
			#endif
		}
	}
	else if (current_state == STATE::FOLLOW)
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
		else if ((_parent->get_position() - NavFlags.leader->get_position()).length() > 250.f)
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
	
}

//called when new round starts
void Bot::on_new_round_starts()
{
	BombFlags.resetFlags();
	current_state = STATE::ROAM;
	
	if (chance(60))
	{
		if (team_id == 0)
		{
			BombFlags.mission = BotBombingFlags::MISSION::FOLLOW_BOMBER;
			current_state = STATE::FOLLOW;
			#ifdef DEBUG_MODE
				DEBUG_PRINT("BOT::Rounded started and following bomber");
			#endif
		}
		else
		{
			BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
			BombFlags.selected_bombSite_id = rand() % BombFlags.bomb_sites.size();
			navigation_state->addPlace(BombFlags.bomb_sites[ BombFlags.selected_bombSite_id ]);
			#ifdef DEBUG_MODE
				DEBUG_PRINT("BOT::Rounded started and going to bombsite");
			#endif
		}
		
	}
	else
	{
		if (team_id == 1)
		{
			BombFlags.mission = BotBombingFlags::MISSION::GOTO_ENEMY_SPAWN;
			if (BombFlags.poi_s.size() != 0)
			{
				int rand_id = rand() % BombFlags.poi_s.size();
				navigation_state->addPlace(BombFlags.poi_s[rand_id]);
			}			
		}
		else
		{
			BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
			BombFlags.selected_bombSite_id = rand() % BombFlags.bomb_sites.size();
			navigation_state->addPlace(BombFlags.bomb_sites[ BombFlags.selected_bombSite_id ]);
			#ifdef DEBUG_MODE
				DEBUG_PRINT("BOT::Rounded started and going to bombsite");
			#endif
		}
	}
}

void Bot::on_selected_as_bomber()
{
	BombFlags.is_bomber = true;
	BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
	current_state = STATE::ROAM;
	navigation_state->clearPlaces();
	BombFlags.selected_bombSite_id = rand() % BombFlags.bomb_sites.size();
	navigation_state->addPlace(BombFlags.bomb_sites[ BombFlags.selected_bombSite_id ]);
			DEBUG_PRINT("selected as bomber, going to plant");
	#ifdef DEBUG_MODE
		DEBUG_PRINT("selected as bomber, going to plant");
	#endif
}

void Bot::on_bomber_selected(Node2D *bomber)
{
	BombFlags.bomber = bomber;
	if (bomber == _parent)
	{
		on_selected_as_bomber();
	}
	else if (BombFlags.mission == BotBombingFlags::MISSION::FOLLOW_BOMBER)
	{
		NavFlags.leader = bomber;
		current_state = STATE::FOLLOW;
	}
	else if (BombFlags.mission == BotBombingFlags::MISSION::GET_BOMB)
	{
		if (chance(60))
		{
			BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
			current_state = STATE::ROAM;
			BombFlags.selected_bombSite_id = rand() % BombFlags.bomb_sites.size();
			navigation_state->addPlace(BombFlags.bomb_sites[ BombFlags.selected_bombSite_id ]);
		}
		else
		{
			BombFlags.mission = BotBombingFlags::MISSION::FOLLOW_BOMBER;
			NavFlags.leader = bomber;
			current_state = STATE::FOLLOW;
		}		
	}
	
}


void Bot::on_bomb_planted()
{
	BombFlags.bomb_planted = true;
	if (team_id == 1)
	{
		current_state = STATE::ROAM;
		BombFlags.mission = BotBombingFlags::MISSION::GOTO_BOMBSPOT;
		navigation_state->clearPlaces();
		int id = rand() % BombFlags.bomb_sites.size();
		BombFlags.selected_bombSite_id = id;
		navigation_state->addPlace(BombFlags.bomb_sites[id]);
		
		#ifdef DEBUG_MODE
			DEBUG_PRINT("bomb planted goting to bombsite");
		#endif
	}
}


void Bot::on_bomb_dropped()
{
	if (team_id == 0)
	{
		BombFlags.mission = BotBombingFlags::MISSION::GET_BOMB;
		current_state = STATE::ROAM;
		navigation_state->clearPlaces();
		Node2D *c4 = get_tree()->get_nodes_in_group("C4Bomb")[0];
		navigation_state->addPlace(c4->get_position());
		BombFlags.bomber = nullptr;
	}	
}


Bot::~Bot()
{

}