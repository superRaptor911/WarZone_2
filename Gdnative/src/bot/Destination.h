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

    public:
        
        Vector2 dest_pos;
        bool reached_desination {false};
        bool has_path_to_destination {false};

    public:
        Destination(Node2D *_par, Navigation2D *nav);
        ~Destination();
    };
    
    Destination::Destination(Node2D *par, Navigation2D *nav)
    {
        _parent = par;
        _nav = nav;
    }
    
    Destination::~Destination()
    {
    }
    
}

#endif