#include <Destination.h>
#include <SceneTree.hpp>
#include <Viewport.hpp>
#include <string>
#include <Bot.h>
using namespace godot;

Destination::Destination(Node2D *par, Navigation2D *nav, const Vector2 &dest)
{
    _parent = par;
    _nav = nav;
    dest_pos = dest;
}
    
Destination::~Destination()
{
}


void Destination::getPathToDestination()
{
    Node *game_states = _parent->get_tree()->get_root()->get_node("game_states");
    if(game_states->call("is_Astar_ready"))
    {
        has_path_to_destination = true;
        path = _nav->get_simple_path(_parent->get_position(), dest_pos);
        _cur_pos_id = 0;
        #ifdef DEBUG_MODE
            Godot::print("getting path");
        #endif
    }
}

void Destination::traverse()
{
    Vector2 position = _parent->get_position();
    
    //check displacement errors
    if ((position - _old_pos).length() > max_displacement_limit)
    {
        #ifdef DEBUG_MODE
            Godot::print(std::to_string((position - _old_pos).length()).c_str());
            Godot::print("error displacement");
        #endif
        has_path_to_destination = false;
    }
    _old_pos = position;

    //if no path, get path
    if (!has_path_to_destination)
    {
        getPathToDestination();
        return;
    }
           
    //if index reaches end of the path then the journey ends 
    if (_cur_pos_id >= path.size() )
    {
        reached_desination = true;
        #ifdef DEBUG_MODE
            Godot::print("reached destination");
        #endif
        return;
    }

  //  mov_vct = static_cast<Vector2>(_parent->get("movement_vector")).normalized();
    mov_vct = (path[_cur_pos_id] - position).normalized() / 20.f;

//    Vector2 steering_vct = desired_vct - mov_vct;
    
//    _parent->set("movement_vector", desired_vct + mov_vct);

    //if near next point 
    if ((path[_cur_pos_id] - position).length() < 10.f)
        _cur_pos_id++;    
}