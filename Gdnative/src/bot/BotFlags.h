#ifndef BOTFLAGS_H
#define BOTFLAGS_H

#include <Vector2.hpp>

namespace godot
{
    struct BotNavFlags
    {
        float scout_start_time = 0.f;
        float evasive_mov_start_time = 0;
        int evasive_mov_dir = 1;

        enum NON_BOMBER_MISSION { FOLLOW_BOMBER, GOTO_BOMBSPOT, GOTO_ENEMY_SPAWN};
        NON_BOMBER_MISSION non_bomber_mission = NON_BOMBER_MISSION::FOLLOW_BOMBER;
        Vector2 selected_bombspot;
        Vector2 selected_enemy_spawn;
        bool bomb_planted = false;
    };

    
    
}

#endif