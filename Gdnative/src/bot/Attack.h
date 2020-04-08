#ifndef ATTACK_H
#define ATTACK_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <Timer.hpp>

namespace godot
{
    class Bot;

    class Attack
    {
    private:

        Bot *_bot;
        Node2D *_parent;
       
    public:

        Node2D *current_enemy = nullptr;

        Vector2 enemy_position;

        //Delay before engaging new enemy
        Timer *reaction_timer;
        
        //For how long bot will press trigger
        Timer *burst_timer;

    public:

        Attack(Node2D *par, Bot *bot);
        
        //Selects an enemy from list of visble enimies.
        void getEnemy();
        
        //Reset combat timers.
        void resetTimers();
        
        void engageEnemy();
        ~Attack();
        
    };   
}

#endif