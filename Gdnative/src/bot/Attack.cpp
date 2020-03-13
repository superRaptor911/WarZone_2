#include <Attack.h>
#include <Bot.h>
#include <SceneTree.hpp>
#include <Viewport.hpp>

using namespace godot;
 
Attack::Attack()
{
	//_no_target_Timer.set_one_shot(true);
	//_no_target_Timer.set_wait_time(2.f);
	//_no_target_Timer.connect("timeout", this, "on_no_target_Timer_Timeout");
}

void Attack::startState()
{
	_bot->use_mov_vct_for_rotation = false;

	_no_target_Timer = Timer()._new();
	_no_target_Timer->set_one_shot(true);
	_no_target_Timer->set_wait_time(2.f);
	_bot->add_child(_no_target_Timer);
	_no_target_Timer->start();

	_attack_delay_timer = Timer()._new();
	_attack_delay_timer->set_one_shot(true);
	_attack_delay_timer->set_wait_time(0.05);
	_bot->add_child(_attack_delay_timer);

	_block_state_change = true;
}

void Attack::stopState()
{
	_no_target_Timer->queue_free();
	_no_target_Timer = nullptr;
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

	on_no_target_Timer_Timeout();
}


bool Attack::isStateReady()
{
	return !_bot->visible_enemies.empty();
}

void Attack::_getCurrentEnemy()
{
	_current_enemy = nullptr;
	_current_enemy_path = "invalid";
	if (EGetMode::NEAREST == enemy_get_mode)
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
	else if (EGetMode::FARTHEST == enemy_get_mode)
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

	/*if (!_current_enemy)
		_no_target_Timer->start();
	else
		_no_target_Timer->stop();*/
}


void Attack::on_no_target_Timer_Timeout()
{
	if (!_current_enemy)
		_block_state_change = false;
}

void Attack:: _attack_enemy()
{
	if (!_current_enemy)
		return;
	_bot->point_to_position = _current_enemy->get_position();
}