#ifndef BOTFLAGS_H
#define BOTFLAGS_H

#include <vector>
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
        float leader_srch_start_time = 0.f;
        int evasive_mov_dir = 1;
        Node2D *leader = nullptr;
        std::vector<Vector2> POIs;

        void resetFlags()
        {
            leader = nullptr;
            evasive_mov_dir = 1;
        }
    };

    struct BotCPFlags
    {
        Array check_points;

        Node2D *cur_chk_pt = nullptr;
        int cur_chk_pt_holding_team = -1;

        float defend_start_time = 0.f;
        const float defend_time = 25.f;
    
    };

}
#endif