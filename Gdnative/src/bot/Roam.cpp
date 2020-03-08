#include <Roam.h>
#include <Bot.h>
#include <Vector2.hpp>
#include <Godot.hpp>
#include <KinematicBody2D.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <SceneTree.hpp>
#include <Viewport.hpp>
using namespace godot;

void Roam::runState()
{
	headToDest();
}



void Roam::headToDest()
{
	if (_on_dest)
	{
		if(_bot->get_tree()->get_root()->get_node("game_states")->call("is_Astar_ready"))
		{
			_on_dest = false;
			_current_dest_id = 0;
			int random_point = rand() % _bot->points_of_interest.size();
			_path_to_dest = _bot->nav->get_simple_path(_parent->get_position(), _bot->points_of_interest[random_point]);

		}
		else
			return;
	}

	Vector2 dest = _path_to_dest[_current_dest_id];
	Vector2 position = _parent->get_position();
	_parent->set("movement_vector", dest - position);

	//rotational code here
	//
	//
	//////////////////////
	
	
	if ((dest - position).length() < 1.f)
		_on_dest = (++ _current_dest_id >= _path_to_dest.size());
}



