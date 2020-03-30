#include <Attack.h>
#include <Bot.h>
#include <SceneTree.hpp>
#include <Viewport.hpp>

using namespace godot;
 
Attack::Attack()
{

}

void Attack::initState()
{
	_attack_pause_timer = Timer()._new();
	_attack_pause_timer->set_one_shot(true);
	_bot->add_child(_attack_pause_timer);

	_can_attack_timer = Timer()._new();
	_can_attack_timer->set_one_shot(true);
	_can_attack_timer->set_wait_time(_bot->bot_attribute.spray_time);
	_bot->add_child(_can_attack_timer);
}

void Attack::startState()
{
	_bot->use_mov_vct_for_rotation = false;
	_block_state_change = true;
}

void Attack::stopState()
{
	_attack_pause_timer->stop();
	_can_attack_timer->stop();
	_old_enemy = nullptr;
	_old_dest = Vector2(-9999,-9999);
	_parent->call("switchToPrimaryGun");
}

void Attack::runState()
{
	_getCurrentEnemy();

	//chk if node was freed or not
	if (_current_enemy && !_bot->get_tree()->get_root()->has_node(_current_enemy_path))
	{
		_current_enemy = nullptr;
		return;
	}

	_handleWeapons();
	_attack_enemy();

	if (!_current_enemy)
	{
		if (_headToPosition(_bot->point_to_position))
		{
			/* code */
		}
		else
			_block_state_change = false;
	}
}


bool Attack::isStateReady()
{
	return !_bot->visible_enemies.empty();
}

void Attack::_getCurrentEnemy()
{
	_current_enemy = nullptr;
	_current_enemy_path = "invalid";
	if (BotAttrib::EGetMode::NEAREST == _bot->bot_attribute.enemy_get_mode)
	{
		float min_dist = 99999.f;
		int sz = _bot->visible_enemies.size();

		for (int i = 0; i < sz; i++)
		{
			Vector2 dist_vec = static_cast<Node2D *>(_bot->visible_enemies[i])->get_position() - _parent->get_position();
			float distance = abs(dist_vec.x) + abs(dist_vec.y);

			if (distance < min_dist)
			{
				min_dist = distance;
				_current_enemy = static_cast<Node2D *>(_bot->visible_enemies[i]);
				_current_enemy_path = _current_enemy->get_path();
			}
		}
	}
	else if (BotAttrib::EGetMode::FARTHEST == _bot->bot_attribute.enemy_get_mode)
	{
		float max_dist = 0.f;
		int sz = _bot->visible_enemies.size();

		for (int i = 0; i < sz; i++)
		{
			Vector2 dist_vec = static_cast<Node2D *>(_bot->visible_enemies[i])->get_position() - _parent->get_position();
			float distance = abs(dist_vec.x) + abs(dist_vec.y);

			if (distance > max_dist)
			{
				max_dist = distance;
				_current_enemy = static_cast<Node2D *>(_bot->visible_enemies[i]);
				_current_enemy_path = _current_enemy->get_path();
			}
		}	
	}
	//Default case
	else
	{
		int sz = _bot->visible_enemies.size();
		int rand_id = rand() % sz;
		_current_enemy = static_cast<Node2D *>(_bot->visible_enemies[rand_id]);
		_current_enemy_path = _current_enemy->get_path();
	}
}




void Attack::_attack_enemy()
{
	if (!_current_enemy)
		return;

	_bot->point_to_position = _current_enemy->get_position();

	if ( _bot->angle_left_to_rotate < _bot->bot_attribute.accuracy)
	{
		if (_old_enemy != _current_enemy)
		{
			_can_attack_timer->stop();
			_attack_pause_timer->start(_bot->bot_attribute.reaction_time);
			_old_enemy = _current_enemy;
		}

		//if can attack timer active, Bot can fire weapon
		if (!_can_attack_timer->is_stopped())
		{
			static_cast<Node *>(_parent->get("selected_gun"))->call("fireGun");
			_attack_pause_timer->start(_bot->bot_attribute.spray_delay);
		}
		else
		{
			if (_attack_pause_timer->is_stopped())
				_can_attack_timer->start();
		}
	}
}


bool Attack::_headToPosition(const Vector2 &pos)
{
	Vector2 position = _parent->get_position();
	
	if (_old_dest != pos)
	{
		if(_bot->get_tree()->get_root()->get_node("game_states")->call("is_Astar_ready"))
		{
			_old_dest = pos;
			_current_dest_id = 0;
			_path_to_dest = _bot->nav->get_simple_path(_parent->get_position(), pos, false);
			
			if (_path_to_dest.size() == 0)
				return false;
		}
		else
			return true;
	}

	Vector2 dest = _path_to_dest[_current_dest_id];
	_parent->set("movement_vector", dest - position);

	bool _on_dest;
	if ((dest - position).length() < 1.f)
		_on_dest = (++ _current_dest_id >= _path_to_dest.size());

	return !_on_dest;
}

void Attack::_handleWeapons()
{
	return;
	//swith gun in fire fight
	if (static_cast<bool>(static_cast<Node *>(_parent->get("selected_gun"))->get("reloading")))
	{
		if ( static_cast<int>(static_cast<Node *>(_parent->get("unselected_gun"))->get("rounds_left")) > 0)
		{
			_parent->rpc("switchGun");
		}
	}
}
