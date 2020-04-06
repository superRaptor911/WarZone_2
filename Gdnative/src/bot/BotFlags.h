#ifndef BOTFLAGS_H
#define BOTFLAGS_H

namespace godot
{
    struct BotFlags
    {
        bool took_low_hp_measures;
        bool took_low_ap_measures;

        float scout_start_time;
        float evasive_mov_start_time = 0;
        int evasive_mov_dir = 1;

        BotFlags()
        {
            resetDefaults();
        }

        void resetDefaults()
        {
            took_low_ap_measures = false;
            took_low_hp_measures = false;
            scout_start_time = 0.f;
            evasive_mov_start_time = 0.f;
        }
    };
    
}

#endif