#include <Bot.h>
#include <KinematicBody2D.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <SceneTree.hpp>
#include <Array.hpp>
#include <string>

#include <Roam.h>

using namespace godot;

Bot::Bot()
{
 
}


void Bot::_register_methods()
{
	register_method("_process", &Bot::_process);
	register_method("_ready", &Bot::_ready);
	
	register_property<Bot, float> ("_rotational_speed", &Bot::_rotational_speed, 2.f);
	register_property<Bot, Array> ("visible_enemies", &Bot::visible_enemies, Array());
	register_property<Bot, Array> ("visible_friends", &Bot::visible_friends, Array());
}


//Loads & links states
void Bot::_loadStates()
{
	Roam *roam = new Roam;
	roam->setParentAndBot(_parent, this);
	_all_the_states.push_back(roam);


	_current_state = roam;
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
		Godot::print("Error::Unable_to_getnavigation2D");

	//get point of interests
	Array arr2 = get_tree()->get_nodes_in_group("POI");
	if (!arr2.empty())
	{
		//get points inside point of interest
		int arr2_sz = arr2.size();
		for (int i = 0; i < arr2_sz; i++)
		{
			Array children = static_cast<Node2D *>(arr2[i])->get_children();
			int children_sz = children.size();
			if (!children.empty())
			{
				for (int j = 0; j < children_sz; j++)
				{
					Vector2 position = static_cast<Node2D *>(children[j])->get_position();
					points_of_interest.push_back(position);
				}
			}
			else
				Godot::print("Error::Nopoints_in_this_POI");
		}
	}
	else
		Godot::print("Error::There_are_no_POIs");

}

void Bot::_init()
{
	//pass
}

void Bot::_process(float delta)
{
	if (_current_state)
	{
		_current_state->runState();
		State *new_state = _current_state->chkForStateChange();
		
		if (new_state)
			_current_state = new_state;

		interpolate_rotation(delta);
	}
}

//rotate the bot smoothly
void Bot::interpolate_rotation(float delta)
{
	float rotation = _parent->get_rotation();
	float new_rotation = (static_cast<Vector2>(_parent->get("movement_vector"))).angle() + 1.57;

	if (abs(rotation - new_rotation) <= 0.1f)
		return;

	//setting domain [0 - 2pi]
	if (new_rotation < 0.f)
		new_rotation += 6.28f;

	if (rotation < 0.f)
		rotation += 6.28f;
	
	if (rotation > 6.28f)
		rotation -= 6.28f;

	if (abs(new_rotation - rotation) <= _rotational_speed * delta ||
		abs(6.28f - abs(new_rotation - rotation)) <= _rotational_speed * delta)
	{	
		rotation = new_rotation;
		_parent->set_rotation(rotation);
		return;
	}

	float aba = new_rotation - rotation;
	if (abs(aba) <= 6.28f - abs(aba))
		rotation += sign(aba) * _rotational_speed * delta;
	else
		rotation += -sign(aba) * _rotational_speed * delta;

	_parent->set_rotation(rotation);
}


Bot::~Bot()
{
	for(auto i : _all_the_states)
	{
		delete i;
	}
}

