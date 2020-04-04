#ifndef BOTFLAGS_H
#define BOTFLAGS_H

namespace godot
{
    struct BotFlags
    {
        bool took_low_hp_measures;
        bool took_low_ap_measures;

        BotFlags()
        {
            resetDefaults();
        }

        void resetDefaults()
        {
            took_low_ap_measures = false;
            took_low_hp_measures = false;
        }
    };
    
}

#endif