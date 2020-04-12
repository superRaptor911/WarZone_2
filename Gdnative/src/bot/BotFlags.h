#ifndef BOTFLAGS_H
#define BOTFLAGS_H

#include <Vector2.hpp>
#include <Array.hpp>
#include <Node2D.hpp>

namespace godot
{
    struct BotNavFlags
    {
        float scout_start_time = 0.f;
        float evasive_mov_start_time = 0;
        int evasive_mov_dir = 1;
        Node2D *leader = nullptr;

        void resetFlags()
        {
            leader = nullptr;
            evasive_mov_dir = 1;
        }
    };

    struct BotBombingFlags
    {
        Array bomb_sites;
        enum NON_BOMBER_MISSION { FOLLOW_BOMBER, GOTO_BOMBSPOT, GOTO_ENEMY_SPAWN, ROAM};
        NON_BOMBER_MISSION non_bomber_mission = NON_BOMBER_MISSION::FOLLOW_BOMBER;
        Vector2 selected_bombspot;
        Vector2 selected_enemy_spawn;

        //Terrorist flags
        bool bomb_planted = false;
        bool is_bomber = false;

        //Couter Terrorist flags
        bool is_bomb_being_diifused = false;
        bool bomb_site_found = false;
        bool going_to_diffuse = false;
        
        int bomb_site_id;
        float camp_time_start = 0.f;
        float max_camp_time = 35.f;

        void resetFlags()
        {
            bomb_planted = false;
            is_bomber = false;
            is_bomb_being_diifused = false;
            bomb_site_found = false;
            bomb_site_id = 0;
            going_to_diffuse = false;
        }
    };
    

    
    
}

#endif