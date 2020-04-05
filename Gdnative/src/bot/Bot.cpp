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
}

void Bot::_init()
{
	//pass
}

void Bot::_process(float delta)
{
	if ( !static_cast<bool>(_parent->get("alive")) )
		return;
		
	interpolate_rotation(delta);
	if (game_mode == GMODE::DM)
		gamemodeDeathmath();
}

void Bot::updateVision()
{
	attack_state->getEnemy();
}

//rotate the bot smoothly
void Bot::interpolate_rotation(float delta)
{
	float rotation = _parent->get_rotation();
	float new_rotation = (point_to_position - _parent->get_position()).angle() + 1.57f;

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
	}
	else if (difficulty == 4)
	{
		bot_attribute.rotational_speed = 5.f;
		bot_attribute.reaction_time = 0.2f;
		bot_attribute.spray_time = 0.4f;
		bot_attribute.accuracy = 0.3f;
	}

	attack_state->resetTimers();
}

void Bot::setGameMode(String gmod)
{
	if (gmod == "FFA")
		game_mode = GMODE::DM;
	else if (gmod == "Bombing")
		game_mode = GMODE::BOMBING;	
}


void Bot::gamemodeDeathmath()
{
	if (current_state == STATE::ROAM)
	{	
		navigation_state->move();
		if (navigation_state->on_final_destination)
		{
			navigation_state->getRandomLocation();
		}

		if (!visible_enemies.empty())
		{
			current_state = STATE::ATTACK;
			Godot::print("changing state to attack");
		}
		
	}
	else if (current_state == STATE::ATTACK)
	{
		attack_state->engageEnemy();
		
		if (!attack_state->current_enemy)
		{
			navigation_state->addPlace(point_to_position);
			current_state = STATE::ROAM;
			Godot::print("changing state to roam");	
		}		
	}
	
}

Bot::~Bot()
{

}
