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
	//pass 
}


void Bot::_register_methods()
{
	register_method("_process", &Bot::_process);
	register_method("_ready", &Bot::_ready);
	register_method("setBotDifficulty", &Bot::setBotDifficulty);

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
}

void Bot::_init()
{
	//pass
}

void Bot::_process(float delta)
{

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
}


Bot::~Bot()
{

}

