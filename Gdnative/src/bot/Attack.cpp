#include <Attack.h>
#include <Bot.h>

using namespace godot;

void Attack::getEnemy()
{
    Node2D *old_enemy = current_enemy;
    current_enemy = nullptr;
    if (_bot->visible_enemies.empty())
        return;

    //get nearest enemy
    if (_bot->bot_attribute.enemy_get_mode == BotAttrib::EGetMode::NEAREST)
    {
        float min_dist = navigate::sq(999.f);
        int no_enemies = _bot->visible_enemies.size();
        int _id = 0;
        Vector2 position = _parent->get_position();

        for (size_t i = 0; i < no_enemies; i++)
        {
            Vector2 epos = static_cast<Node2D *>(_bot->visible_enemies[i])->get_position();
            float distance = navigate::sqDistance(position, epos);
            if (distance < min_dist)
            {
                min_dist = distance;
                _id = i;
            }            
        }

        current_enemy = static_cast<Node2D *>(_bot->visible_enemies[_id]);
    }

    //get nearest to aim enemy
    else if (_bot->bot_attribute.enemy_get_mode == BotAttrib::EGetMode::NEAREST_AIM)
    {
        float min_tan = 999999.f;
        int no_enemies = _bot->visible_enemies.size();
        int _id = 0;
        Vector2 position = _parent->get_position();

        for (size_t i = 0; i < no_enemies; i++)
        {
            Vector2 epos = static_cast<Node2D *>(_bot->visible_enemies[i])->get_position();
            Vector2 vct = epos - position;
            float _tan = vct.y / (std::max(0.00001f, vct.x));
            if (_tan < min_tan)
            {
                min_tan = _tan;
                _id = i;
            }            
        }

        current_enemy = static_cast<Node2D *>(_bot->visible_enemies[_id]);
    }

    if (current_enemy != old_enemy)
        reaction_timer->start();
}


Attack::Attack(Node2D *par, Bot *bot)
{
    _bot = bot; _parent = par;

    reaction_timer = Timer()._new();
    reaction_timer->set_one_shot(true);
    reaction_timer->set_wait_time(_bot->bot_attribute.reaction_time);
    _bot->add_child(reaction_timer);

    burst_timer = Timer()._new();
    burst_timer->set_one_shot(true);
    burst_timer->set_wait_time(_bot->bot_attribute.spray_time);
    _bot->add_child(burst_timer);

}

void Attack::resetTimers()
{
    reaction_timer->set_wait_time(_bot->bot_attribute.reaction_time);
    burst_timer->set_wait_time(_bot->bot_attribute.spray_time);
}

void Attack::engageEnemy()
{
    if (!current_enemy)
        return;

    enemy_position = current_enemy->get_position();
    _bot->point_to_dir = enemy_position - _parent->get_position();

    if (reaction_timer->is_stopped())
    {
        if (_bot->time_elapsed - last_fire_time  < _bot->bot_attribute.spray_time)
        {
            static_cast<Node *>(_parent->get("selected_gun"))->call("fireGun");
            last_delay_time = _bot->time_elapsed;
        }
        else
        {
            if (_bot->time_elapsed - last_delay_time > _bot->bot_attribute.spray_delay)
            {
                last_fire_time = _bot->time_elapsed;
            }            
        }
    }
}

Attack::~Attack()
{

}