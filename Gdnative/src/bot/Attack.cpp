#include <Attack.h>
#include <Bot.h>
#include <SceneTree.hpp>
#include <Viewport.hpp>

using namespace godot;
 
Attack::Attack()
{
	//_attack_pause_timer.set_one_shot(true);
	//_attack_pause_timer.set_wait_time(2.f);
	//_attack_pause_timer.connect("timeout", this, "on_attack_pause_timer_Timeout");
}

void Attack::startState()
{
	_bot->use_mov_vct_for_rotation = false;

	_attack_pause_timer = Timer()._new();
	_attack_pause_timer->set_one_shot(true);
	_attack_pause_timer->set_wait_time(0.2f);
	_bot->add_child(_attack_pause_timer);

	_attack_timer = Timer()._new();
	_attack_timer->set_one_shot(true);
	_attack_timer->set_wait_time(0.4f);
	_bot->add_child(_attack_timer);

	_block_state_change = true;

	_parent->call("switchToPrimaryGun");
	
}

void Attack::stopState()
{
	_attack_pause_timer->queue_free();
	_attack_pause_timer = nullptr;
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

	_attack_enemy();

	on_attack_pause_timer_Timeout();
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


void Attack::on_attack_pause_timer_Timeout()
{
	if (!_current_enemy)
		_block_state_change = false;
}

void Attack:: _attack_enemy()
{
	if (!_current_enemy)
		return;

	_bot->point_to_position = _current_enemy->get_position();

	if ( _bot->angle_left_to_rotate < _bot->bot_attribute.accuracy)
	{
		if (!_attack_timer->is_stopped())
		{
			static_cast<Node *>(_parent->get("selected_gun"))->call("fireGun");
			_attack_pause_timer->start();
		}
		else
		{
			if (_attack_pause_timer->is_stopped())
				_attack_timer->start();
		}
	}
}