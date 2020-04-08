#include <navigate.h>
#include <Bot.h>
using namespace godot;

navigate::navigate(Node2D *par, Navigation2D *nav, Bot *bot)
{
    _parent = par;
    _nav = nav;
    _bot = bot;
    _ray = static_cast<RayCast2D *>(_parent->get_node("RayCast2D"));
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
    
    _places.push(Destination(_parent,_nav,place));
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
        
        _handleCollisionWithFriend();
        _places.top().traverse();
        force_vect += _places.top().mov_vct;

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
void navigate::_handleCollisionWithFriend()
{/*
    int sz = _bot->visible_friends.size();
    float min_dist = 50.f;
    Vector2 position = _parent->get_position();
    Node2D *friend_node = nullptr;
    for (size_t i = 0; i < sz; i++)
    {
        float distance = sqDistance(position, static_cast<Node2D *>(_bot->visible_friends[i])->get_position() ) ;
        if (distance < min_dist * min_dist)
        {
            friend_node = static_cast<Node2D *>(_bot->visible_friends[i]);
        }                
    }

    if (friend_node)
    {
        force_vect += ((position + mov_vct * 2.0) - friend_node->get_position()).normalized() * 3.0;
        return true;
    }*/

    if (_ray->is_colliding())
    {
        Vector2 coll_norm = _ray->get_collision_normal();
        force_vect += coll_norm / 15.f;
    }
}