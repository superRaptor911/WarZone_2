#include <Bot.h>
#include <KinematicBody2D.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <SceneTree.hpp>
#include <Array.hpp>
#include <string>


using namespace godot;

Bot::Bot()
{
	current_state = STATE::ROAM;
	game_mode = GMODE::DM; 
}


void Bot::_register_methods()
{
	register_method("_process", &Bot::_process);
	register_method("_ready", &Bot::_ready);
	register_method("updateVision", &Bot::updateVision);
	register_method("setBotDifficulty", &Bot::setBotDifficulty);
	register_method("setGameMode", &Bot::setGameMode);
	register_method("onNewBombingRoundStarted",&Bot::onNewBombingRoundStarted);
	register_method("onBombingRoundEnds",&Bot::onBombingRoundEnds);
	register_method("onBombPlanted",&Bot::onBombPlanted);
	register_method("onSelectedAsBomber",&Bot::onSelectedAsBomber);
	register_method("onKilled",&Bot::onKilled);
	register_method("think",&Bot::think);
	register_method("onEnteredBombSite",&Bot::onEnteredBombSite);
	register_method("onCTnearBomb", &Bot::onCTnearBomb);
	register_method("bombSiteFound",&Bot::bombSiteFound);

	register_property<Bot, Array> ("visible_enemies", &Bot::visible_enemies, Array());
	register_property<Bot, Array> ("visible_friends", &Bot::visible_friends, Array());
}


//Loads & links states
void Bot::_loadStates()
{

}

void Bot::_ready()
{
	//set parent
	_parent = static_cast<KinematicBody2D *> (get_parent());
	_loadStates();

	//get navigation
	Array arr = get_tree()->get_nodes_in_group("Nav");
	if (!arr.empty())
		nav = arr[0];
	else
		Godot::print("Error::Unable_to_get_navigation2D");
	
	navigation_state = std::make_unique<navigate>(_parent, nav, this);
	attack_state = std::make_unique<Attack>(_parent, this);
	team_id = static_cast<int>(static_cast<Node *>(_parent->get("team"))->get("team_id"));
	
	#ifdef DEBUG_MODE
		std::string team_name = "terrorist";
		if (team_id == 1)
			team_name = "counter_terrorist";
		Godot::print(("team is " + team_name).c_str());
	#endif

	current_state = STATE::ROAM;
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
		bot_attribute.spray_time = 0.5f;
		bot_attribute.accuracy = 1.f;
	}
	else if (difficulty == 2)
	{
		bot_attribute.rotational_speed = 2.f;
		bot_attribute.reaction_time = 1.f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.7f;
	}
	else if (difficulty == 3)
	{
		bot_attribute.rotational_speed = 3.f;
		bot_attribute.reaction_time = 0.8f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.5f;
		bot_attribute.enable_evasive_mov = true;
	}
	else if (difficulty == 4)
	{
		bot_attribute.rotational_speed = 5.f;
		bot_attribute.reaction_time = 0.2f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.3f;
		bot_attribute.enable_evasive_mov = true;
	}

	attack_state->resetTimers();
}

void Bot::setGameMode(String gmod)
{
	if (gmod == "FFA")
		game_mode = GMODE::DM;
	else if (gmod == "Bombing")
	{
		game_mode = GMODE::BOMBING;
		BombFlags.bomb_sites = get_tree()->get_nodes_in_group("Bomb_site");
		current_state = STATE::CAMP;
	}
}


void Bot::gamemodeDeathmath()
{
	if (current_state == STATE::ROAM)
	{	
		navigation_state->move();
		if (navigation_state->on_final_destination)
		{
			if (chance(40))
				navigation_state->getRandomLocation();
			else
			{
				
			}
		}

		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
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
			navigation_state->clearPlaces();
			navigation_state->addPlace(attack_state->enemy_position);
			current_state = STATE::SCOUT;
			NavFlags.scout_start_time = time_elapsed;
			#ifdef DEBUG_MODE
				Godot::print("changing state to scout");
			#endif
		}
		else if (bot_attribute.is_coward && static_cast<float>(_parent->get("HP")) < 35.f)
		{
			current_state = STATE::FLEE;
			#ifdef DEBUG_MODE
				Godot::print("changing state to flee");
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
			
			Vector2 pos = nav->get_closest_point(_parent->get_position() + rand_pos);
			navigation_state->addPlace(pos);
		}
		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
			#endif
		}
		//stay in this mode for 30 seconds
		if (time_elapsed - NavFlags.scout_start_time > 20.f)
		{
			current_state = STATE::ROAM;
			#ifdef DEBUG_MODE
				Godot::print("changing state to Roam");
			#endif
		}
	}	
	else if (current_state == STATE::FLEE)
	{
		
	}
}

void Bot::gamemodeBombing()
{
	if (current_state == STATE::ROAM)
	{	
		navigation_state->move();
		
		//nowhere to go
		if (navigation_state->on_final_destination)
		{
			//follow leader
			if (NavFlags.leader && static_cast<bool>(NavFlags.leader->get("alive")) &&
				(_parent->get_position() - NavFlags.leader->get_position()).length() < 250.f )
			{
				current_state = STATE::FOLLOW;
				#ifdef DEBUG_MODE
					Godot::print("changing state to follow");
				#endif
				return;
			}
			//follow bomber
			if (BombFlags.non_bomber_mission == BotBombingFlags::NON_BOMBER_MISSION::FOLLOW_BOMBER)
			{
				Array bombers = get_tree()->get_nodes_in_group("bomber");
				if (!bombers.empty() && _parent != static_cast<Node2D *>(bombers[0]))
				{
					NavFlags.leader = static_cast<Node2D *>(bombers[0]);
					current_state = STATE::FOLLOW;
					#ifdef DEBUG_MODE
						Godot::print("changing state to follow");
					#endif
					return;					
				}
			}

			if (team_id == 1)
			{
				if (BombFlags.bomb_planted && !BombFlags.is_bomb_being_diifused)
				{
					if (BombFlags.going_to_diffuse)
					{
						BombFlags.camp_time_start = time_elapsed;
						current_state = STATE::BOMB_DIFF;
					}
					
				}
				
			}
			

			navigation_state->getRandomLocation();
		}

		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
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
			//bomber goto bombsite
			if (BombFlags.is_bomber)
			{
				navigation_state->clearPlaces();
				navigation_state->addPlace(BombFlags.selected_bombspot);
				current_state = STATE::ROAM;
				#ifdef DEBUG_MODE
					Godot::print("changing state to goto site");
				#endif
			}
			//follow bomber if was following bomber
			else if (team_id == 0 && BombFlags.non_bomber_mission == BotBombingFlags::NON_BOMBER_MISSION::FOLLOW_BOMBER)
			{
				navigation_state->clearPlaces();
				current_state = STATE::FOLLOW;
				#ifdef DEBUG_MODE
					Godot::print("changing state to follow bomber");
				#endif
			}			
			else
			{
				navigation_state->clearPlaces();
				navigation_state->addPlace(attack_state->enemy_position);
				current_state = STATE::SCOUT;
				NavFlags.scout_start_time = time_elapsed;
				#ifdef DEBUG_MODE
					Godot::print("changing state to scout");
				#endif
			}
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
			
			Vector2 pos = nav->get_closest_point(_parent->get_position() + rand_pos);
			navigation_state->addPlace(pos);
		}
		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
			#endif
		}
		//stay in this mode for 30 seconds
		if (time_elapsed - NavFlags.scout_start_time > 20.f)
		{
			current_state = STATE::ROAM;
			#ifdef DEBUG_MODE
				Godot::print("changing state to Roam");
			#endif
		}
	}
	else if (current_state == STATE::CAMP)
	{
		if (time_elapsed - BombFlags.camp_time_start > BombFlags.max_camp_time)
		{
			current_state = STATE::ROAM;
			#ifdef DEBUG_MODE
				Godot::print("changing state to Roam");
			#endif	
		}

		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
			#endif
		}		
	}
	else if (current_state == STATE::BOMB_PLANT)
	{
		if (time_elapsed - BombFlags.camp_time_start > 4.f)
		{
			_parent->call("plantBomb");
			navigation_state->clearPlaces();
			current_state = STATE::ROAM;	
		}
		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			#ifdef DEBUG_MODE
				Godot::print("changing state to attack");
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
				Godot::print("changing state to attack");
			#endif
		}
	}
	else if (current_state == STATE::BOMB_DIFF)
	{
		if (time_elapsed - BombFlags.camp_time_start > 4.f)
		{
			_parent->call("diffuseBomb");
		}
		
	}
	
}

void Bot::onNewBombingRoundStarted()
{
	current_state = STATE::ROAM;
	navigation_state->clearPlaces();
	//terrorrist team
	if (team_id == 0)
	{
		if (BombFlags.is_bomber)
		{
			Array bomb_sites = BombFlags.bomb_sites;
			int rand_no = rand() % bomb_sites.size();
			BombFlags.selected_bombspot = static_cast<Node2D *>(bomb_sites[rand_no])->get_position();
			navigation_state->addPlace(BombFlags.selected_bombspot);
		}
		else
		{
			int a = rand() % 4;
			if (a == 0)
				BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::FOLLOW_BOMBER;
			else if (a == 1)
				BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::GOTO_BOMBSPOT;
			else if (a == 2)
				BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::GOTO_ENEMY_SPAWN;
			else if (a == 3)
				BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::ROAM;
			
			if (BombFlags.non_bomber_mission == BotBombingFlags::NON_BOMBER_MISSION::FOLLOW_BOMBER)
			{
				Array bombers = get_tree()->get_nodes_in_group("bomber");
				if (!bombers.empty() && _parent != static_cast<Node2D *>(bombers[0]))
				{
					NavFlags.leader = static_cast<Node2D *>(bombers[0]);
					current_state = STATE::FOLLOW;					
				}

				#ifdef DEBUG_MODE
					Godot::print("following bomber");
				#endif	
			}
			else if (BombFlags.non_bomber_mission == BotBombingFlags::NON_BOMBER_MISSION::GOTO_BOMBSPOT)
			{
				Array bomb_sites = BombFlags.bomb_sites;
				int rand_no = rand() % bomb_sites.size();
				BombFlags.selected_bombspot = static_cast<Node2D *>(bomb_sites[rand_no])->get_position();
				navigation_state->addPlace(BombFlags.selected_bombspot);
				
				#ifdef DEBUG_MODE
					Godot::print("going to bombspot");
				#endif	
			}	
		}	
	}
	//counter terrorist
	else
	{
		int a = rand() % 2;
		if (chance(50))
			BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::GOTO_BOMBSPOT;
		else if (a == 0)
			BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::GOTO_ENEMY_SPAWN;
		else if (a == 1)
			BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::ROAM;

		if (BombFlags.non_bomber_mission == BotBombingFlags::NON_BOMBER_MISSION::GOTO_BOMBSPOT)
		{
			Array bomb_sites = BombFlags.bomb_sites;
			int rand_no = rand() % bomb_sites.size();
			BombFlags.selected_bombspot = static_cast<Node2D *>(bomb_sites[rand_no])->get_position();
			navigation_state->addPlace(BombFlags.selected_bombspot);
				
			#ifdef DEBUG_MODE
				Godot::print("going to bombspot");
			#endif	
		}
	}
}

void Bot::onBombingRoundEnds()
{
	BombFlags.resetFlags();
	BombFlags.camp_time_start = time_elapsed;
	current_state = STATE::CAMP;
}

void Bot::onEnteredBombSite()
{
	if (BombFlags.is_bomber && !BombFlags.bomb_planted)
	{
		//plant bomb
		BombFlags.camp_time_start = time_elapsed;
		current_state = STATE::BOMB_PLANT;
		#ifdef DEBUG_MODE
			Godot::print("planting bomb");
		#endif
	}
	else
	{
		if (!BombFlags.bomb_planted)
		{
			int chance_to_camp = 33;

			if (BombFlags.bomb_planted)
				chance_to_camp = 66;

			if (team_id == 1)
				chance_to_camp = 100 - chance_to_camp;
			
							
			//change state to camp
			if (chance(chance_to_camp))
			{
				BombFlags.camp_time_start = time_elapsed;
				current_state = STATE::CAMP;
				#ifdef DEBUG_MODE
					Godot::print("changing state to camp");
				#endif
			}
			//change state to roam
			else
			{
				navigation_state->clearPlaces();
				current_state = STATE::ROAM;
				#ifdef DEBUG_MODE
					Godot::print("changing state to roam");
				#endif
			}		
		}
		//bomb planted and counter terrorist
		else if (team_id == 1)
		{
			if (!BombFlags.bomb_site_found)
			{
				Vector2 bomb_pos = static_cast<Node2D *>(get_tree()->get_nodes_in_group("C4Bomb")[0])->get_position();
				if ((_parent->get_position() - bomb_pos).length() < 100.f)
				{
					Array bots = get_tree()->get_nodes_in_group("Bot");
					int sz = bots.size();

					for (int i = 0; i < sz; i++)
					{
						static_cast<Node *>(bots[i])->call("bombSiteFound", BombFlags.bomb_site_id);
					}

					if (!BombFlags.is_bomb_being_diifused)
					{
						BombFlags.going_to_diffuse = true;
						navigation_state->clearPlaces();
						navigation_state->addPlace(bomb_pos);	
					}										
				}
				//wrong bomb site, bomb not here
				else
				{
					BombFlags.bomb_site_id += 1;
					if (BombFlags.bomb_site_id >= BombFlags.bomb_sites.size())
						BombFlags.bomb_site_id = 0;

					navigation_state->clearPlaces();
					navigation_state->addPlace(BombFlags.bomb_sites[BombFlags.bomb_site_id]);			
				}
							
			}		
		}			
	}
}

void Bot::onBombPlanted()
{
	BombFlags.bomb_planted = true;
	BombFlags.is_bomber = false;
	if (team_id == 1)
	{
		int rand_no = rand() % BombFlags.bomb_sites.size();
		navigation_state->clearPlaces();
		navigation_state->addPlace(BombFlags.bomb_sites[rand_no]);
		BombFlags.bomb_site_id = rand_no;
		BombFlags.non_bomber_mission = BotBombingFlags::NON_BOMBER_MISSION::GOTO_BOMBSPOT;
		#ifdef DEBUG_MODE
			Godot::print("Heading towards bomb site");
		#endif
	}
}

void Bot::onCTnearBomb()
{
	BombFlags.camp_time_start = time_elapsed;
	current_state = STATE::BOMB_DIFF;
}

void Bot::onKilled()
{
	navigation_state->clearPlaces();
	NavFlags.resetFlags();
}

void Bot::onSelectedAsBomber()
{
	BombFlags.is_bomber = true;
	#ifdef DEBUG_MODE
		Godot::print("selected as bomber");
	#endif
}

void Bot::bombBeingDiffused(bool val)
{
	BombFlags.is_bomb_being_diifused = val;
	if (team_id == 0 && val)
	{
		if (chance(55))
		{
			current_state = STATE::ROAM;
			navigation_state->clearPlaces();

		}
		
	}
	else if (team_id == 1)
	{
		
	}
}


void Bot::bombSiteFound(int id)
{
	//Counter Terrorist only
	if (team_id == 1)
	{
		BombFlags.bomb_site_found = true;
		if (BombFlags.bomb_site_id != id)
		{
			BombFlags.bomb_site_id = id;
			navigation_state->clearPlaces();
			navigation_state->addPlace(BombFlags.bomb_sites[BombFlags.bomb_site_id]);
		}		
	}
}

Bot::~Bot()
{

}
