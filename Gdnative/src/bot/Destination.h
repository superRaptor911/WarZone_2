#ifndef DESTINATION_H
#define DESTINATION_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <Vector2.hpp>
#include <Navigation2D.hpp>


namespace godot
{
    class Bot;
    
    class Destination
    {
    private:
    
        Node2D *_parent;
        Node *_level;
        Bot *_bot;
        int _cur_node_id {0};
        Vector2 _old_pos;
        float _timeStamp_at_node = 0.f;

    public:
        
        Vector2 dest_pos;
        Vector2 mov_force;
        bool reached_desination {false};
        bool has_path_to_destination {false};
        PoolVector2Array path;

        const float max_displacement_limit = 64.f;

    public:
        Destination(Node2D *_par,Bot *bot, Node *level, const Vector2 &dest);
        void getPathToDestination();
        void traverse();
        ~Destination();
    };
    
}

#endif