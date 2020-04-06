#include <navigate.h>
#include <Bot.h>
using namespace godot;

navigate::navigate(Node2D *par, Navigation2D *nav, Bot *bot)
{
    _parent = par;
     _nav = nav;
     _bot = bot;
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
        _bot->point_to_position = _places.top().mov_vct + _parent->get_position();

        if(!_handleCollisionWithFriend())
            _places.top().traverse();

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
bool navigate::_handleCollisionWithFriend()
{
    int sz = _bot->visible_enemies.size();
    float min_dist = 50.f;
    Vector2 position = _parent->get_position();
    Node2D *friend_node = nullptr;
    for (size_t i = 0; i < sz; i++)
    {
        float distance = sqDistance(position, static_cast<Node2D *>(_bot->visible_enemies[i])->get_position() ) ;
        if (distance < min_dist * min_dist)
        {
            friend_node = static_cast<Node2D *>(_bot->visible_enemies[i]);
        }                
    }

    if (friend_node)
    {
        _parent->set("movement_vector", _places.top().mov_vct.rotated(0.785f));
        _bot->point_to_position = _places.top().mov_vct.rotated(0.785f) + _parent->get_position();
        return true;
    }

    return false;
}