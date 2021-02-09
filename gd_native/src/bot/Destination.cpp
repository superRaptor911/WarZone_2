#include <Destination.h>
#include <SceneTree.hpp>
#include <Viewport.hpp>
#include <string>
#include <Bot.h>
using namespace godot;

Destination::Destination(Node2D *par,Bot *bot, Node *level, const Vector2 &dest)
{
    _parent = par;
    dest_pos = dest;
    _bot = bot;
    _level = level;
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
        //path = _nav->get_simple_path(_parent->get_position(), dest_pos);
        path = static_cast<PoolVector2Array>(_level->call("getPath", _parent->get_position(), dest_pos));
        _cur_node_id = 0;
        #ifdef DEBUG_MODE
            Godot::print("getting path");
        #endif

        _timeStamp_at_node = _bot->time_elapsed;
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
    if (_bot->time_elapsed - _timeStamp_at_node > 50.f)
    {
        #ifdef DEBUG_MODE
            Godot::print("Bot stuck for more than 50 sec at a node");
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
    if (_cur_node_id >= path.size() )
    {
        reached_desination = true;
        #ifdef DEBUG_MODE
            Godot::print("reached destination");
        #endif
        return;
    }

    mov_force = (path[_cur_node_id] - position).normalized() / 20.f;

    if ((path[_cur_node_id] - position).length() < 64.f)
    {
        _cur_node_id++;
        _timeStamp_at_node = _bot->time_elapsed;
    }
}