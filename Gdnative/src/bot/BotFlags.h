#ifndef BOTFLAGS_H
#define BOTFLAGS_H

#include <Vector2.hpp>
#include <Array.hpp>
#include <PoolArrays.hpp>
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
        enum MISSION { FOLLOW_BOMBER, GOTO_BOMBSPOT, GOTO_ENEMY_SPAWN, NOTHING};
        MISSION mission = MISSION::FOLLOW_BOMBER;
        Vector2 selected_enemy_spawn;
        PoolVector2Array bomb_sites;

        //Terrorist flags
        bool bomb_planted = false;
        bool is_bomber = false;
        Node2D *bomber;

        //Counter Terrorist flags
        bool is_bomb_being_diifused = false;
        bool bomb_site_found = false;
        bool going_to_diffuse = false;
        
        int selected_bombSite_id;
        float camp_time_start = 0.f;
        float max_camp_time = 35.f;

        void resetFlags()
        {
            bomb_planted = false;
            is_bomber = false;
            is_bomb_being_diifused = false;
            bomb_site_found = false;
            selected_bombSite_id = 0;
            going_to_diffuse = false;
            bomber = nullptr;
        }
    };
    

    
    
}

#endif