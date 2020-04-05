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


    if (current_enemy != old_enemy)
        reaction_timer->start();

    Godot::print("looking for enemies");
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

    cool_down_timer = Timer()._new();
    cool_down_timer->set_one_shot(true);
    cool_down_timer->set_wait_time(_bot->bot_attribute.spray_delay);
    _bot->add_child(cool_down_timer);
}

void Attack::resetTimers()
{
    reaction_timer->set_wait_time(_bot->bot_attribute.reaction_time);
    burst_timer->set_wait_time(_bot->bot_attribute.spray_time);
    cool_down_timer->set_wait_time(_bot->bot_attribute.spray_delay);
}

void Attack::engageEnemy()
{
    if (!current_enemy)
        return;

    _bot->point_to_position = current_enemy->get_position();

    if (reaction_timer->is_stopped() && cool_down_timer->is_stopped())
    {
        if (burst_timer->is_stopped())
        {

            burst_timer->start();
        }
        
        if (!burst_timer->is_stopped())
        {
            static_cast<Node *>(_parent->get("selected_gun"))->call("fireGun");
        }
    }
    /*
    else if (!cool_down_timer->is_stopped())
    {
        burst_timer->start();
    }*/
}

Attack::~Attack()
{

}