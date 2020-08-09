#ifndef NAVIGATE_H
#define NAVIGATE_H

#include <Godot.hpp>
#include <RayCast2D.hpp>
#include <Destination.h>
#include <stack>
#include <vector>

#ifdef DEBUG_MODE
    #define DEBUG_PRINT(x) Godot::print(x); 
#else
    #define DEBUG_PRINT(x) ;
#endif

namespace godot
{
    class Bot;
    class navigate
    {
    private:

        Node2D *_parent;
        Navigation2D *_nav;
        Bot *_bot;
        std::vector<RayCast2D *> _rays;
        std::stack<Destination> _places;

        int _max_places {5};
    
    private:

        //This function prevents bots from being stuck when they collide with each other.
        void handleCollision();
    
    public:

        bool on_final_destination {true};
        Vector2 world_size {Vector2(1500,1500)};
        Vector2 force_vect;
        Vector2 mov_vct;
        
    public:

        navigate(Node2D *par, Navigation2D *nav, Bot *bot);
       
        //add a new location to visit.
        void addPlace(const Vector2 &place);
        
        void clearPlaces();
        
        //move to specified location.
        void move();
        
        //generates a random location to visit.
        void getRandomLocation();

        //Follow the leader
        void followLeader();

        //returns square of distanec between 2 points.
        static float sqDistance(const Vector2 &v1, const Vector2 &v2);
        static float sq(float v) {return v*v;}
        ~navigate();
    };    
}


#endif