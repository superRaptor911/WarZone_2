#ifndef DESTINATION_H
#define DESTINATION_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <Vector2.hpp>
#include <Navigation2D.hpp>


namespace godot
{
    class Destination
    {
    private:
    
        Node2D *_parent;
        Navigation2D *_nav;
        int _cur_pos_id {0};
        Vector2 _old_pos;

    public:
        
        Vector2 dest_pos;
        Vector2 mov_vct;
        bool reached_desination {false};
        bool has_path_to_destination {false};
        PoolVector2Array path;

        const float max_displacement_limit = 6.f;

    public:
        Destination(Node2D *_par, Navigation2D *nav, const Vector2 &dest);
        void getPathToDestination();
        void traverse();
        ~Destination();
    };
    
}

#endif