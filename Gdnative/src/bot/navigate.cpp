#include <navigate.h>
#include <Bot.h>
#include <SceneTree.hpp>
#include <TileMap.hpp>
using namespace godot;

navigate::navigate(Node2D *par, Navigation2D *nav, Bot *bot)
{
    _parent = par;
    _nav = nav;
    _bot = bot;
    _rays.push_back(static_cast<RayCast2D *>(_parent->get_node("RayCast_up")));
    _rays.push_back(static_cast<RayCast2D *>(_parent->get_node("RayCast_down")));
    _rays.push_back(static_cast<RayCast2D *>(_parent->get_node("RayCast_left")));
    _rays.push_back(static_cast<RayCast2D *>(_parent->get_node("RayCast_right")));

    Node2D *level = _bot->get_tree()->get_nodes_in_group("Level")[0];
    world_size = static_cast<TileMap *>(level->get_node("BaseMap/height"))->get_used_rect().get_size() * Vector2(64, 64);
}
    
navigate::~navigate()
{

}

//add a new location to visit.
void navigate::addPlace(const Vector2 &place)
{
    //clear if limit reached
    if(_places.size() >= _max_places )
        _places = std::stack<Destination>();
    
    if (!_places.empty())
        _places.top().has_path_to_destination = false;
    
    _places.push(Destination(_parent,_bot,_nav,place));
    on_final_destination = false;
}

void navigate::clearPlaces()
{
    _places = std::stack<Destination>();
}

//move to specified location.
void navigate::move()
{
    if (!_places.empty())
    {
        force_vect = Vector2(0,0);
        mov_vct = mov_vct.normalized();
        
        handleCollision();
        _places.top().traverse();
        force_vect += _places.top().mov_force;

        mov_vct += force_vect;
        _parent->set("movement_vector", mov_vct);
        _bot->point_to_dir = mov_vct;
        if (_places.top().reached_desination)
            _places.pop();
    }
    else
    {
        on_final_destination = true;
        #ifdef DEBUG_MODE
            Godot::print("on destination");
        #endif
    }
    
}

void navigate::followLeader()
{
    if (!_bot->NavFlags.leader)
        return;

    Vector2 leader_pos = _bot->NavFlags.leader->get_position();
    Vector2 position = _parent->get_position();
    if (sqDistance(leader_pos, position) > sq(60.f))
    {
        force_vect = Vector2(0,0);
        mov_vct = mov_vct.normalized();
            
        handleCollision();
        force_vect += (leader_pos - position).normalized() / 20.f;
        mov_vct += force_vect;
        _parent->set("movement_vector", mov_vct);
        _bot->point_to_dir = mov_vct;
    }
}

//generates a random location to visit.
void navigate::getRandomLocation()
{
    Vector2 random_position = Vector2(rand() % (int)world_size.x, rand() % (int)world_size.y);
    random_position = _nav->get_closest_point(random_position);
    addPlace(random_position);
}

//returns square of distanec between 2 points.
float navigate::sqDistance(const Vector2 &v1, const Vector2 &v2)
{
	Vector2 diff = v2 - v1;
	return (diff.x * diff.x + diff.y * diff.y);
}

//This function prevents bots from being stuck when they collide with each other.
void navigate::handleCollision()
{
    for(auto &it : _rays)
    {
        if (it->is_colliding())
        {
            Vector2 coll_norm = it->get_collision_normal();
            float scale = 60.f / (it->get_collision_point() - it->get_global_position()).length();
            force_vect += (coll_norm / 25.f) * scale;
        }        
    }
}