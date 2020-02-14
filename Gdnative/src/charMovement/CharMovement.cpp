#include "CharMovement.h"
#include <SceneTree.hpp>
#include <Tween.hpp>
#include <math.h>



using namespace godot;
#define SQUARE_LENGTH(v) v.x * v.x + v.y*v.y



void CharMovement::_register_methods() 
{
	register_method("_process", &CharMovement::_process);
	register_method("_ready", &CharMovement::_ready);
	register_method("interpolate_rotation", &CharMovement::interpolate_rotation);
	register_method("movement", &CharMovement::movement);
	register_method("_changeState", &CharMovement::_changeState);
	register_method("_client_process_vectors", &CharMovement::_client_process_vectors);
	register_method("_server_process_vectors", &CharMovement::_server_process_vectors,GODOT_METHOD_RPC_MODE_REMOTE);
	register_method("_syncVectors", &CharMovement::_syncVectors,GODOT_METHOD_RPC_MODE_REMOTESYNC);
	register_method("_computeStates", &CharMovement::_computeStates);
	register_method("_teleportCharacter", &CharMovement::_teleportCharacter);
	//register_property<GDExample, float>("amplitude", &GDExample::amplitude, 10.0);
	
	register_property<CharMovement, int>("_current_input_id", &CharMovement::_current_input_id, 0);

	register_property<CharMovement, float>("_rotational_speed", &CharMovement::_rotational_speed, 0.1f);
}

CharMovement::CharMovement() 
{
	_current_input_id = 0;
	_rotational_speed = 0.1f;
	_update_delta = 1.f / 25.f;
	_old_rot = 0.f;
	_stateVectors.reserve(20);
}

CharMovement::~CharMovement() 
{
	// add your cleanup here
}

void CharMovement::_ready()
{
	_parent = static_cast<KinematicBody2D *> (get_parent());
}

void CharMovement::_init() 
{
	_Input = Input::get_singleton();
}

void CharMovement::_process(float delta) 
{ 

}

void CharMovement::interpolate_rotation(float delta)
{
	if (!_stateVectors.size())
		return;


	float rotation = _parent->get_rotation();
	float new_rotation = _stateVectors.back().rotation;

	if (abs(rotation - new_rotation) <= 0.04f)
		return;

	//setting domain [0 - 2pi]
	if (new_rotation < 0.f)
		new_rotation += 6.28f;

	if (rotation < 0.f)
		rotation += 6.28f;
	
	if (rotation > 6.28f)
		rotation -= 6.28f;

	if (abs(new_rotation - rotation) <= _rotational_speed * delta ||
		abs(6.28f - abs(new_rotation - rotation)) <= _rotational_speed * delta)
	{	
		rotation = new_rotation;
		_parent->set_rotation(rotation);
		return;
	}

	float aba = new_rotation - rotation;
	if (abs(aba) <= 6.28f - abs(aba))
		rotation += sign(aba) * _rotational_speed * delta;
	else
		rotation += -sign(aba) * _rotational_speed * delta;

	_parent->set_rotation(rotation);
}

void CharMovement::movement(float delta)
{
	//if Character is other peer interpolate its rotation
	//This is used because Tween node failed
	if (!_parent->is_network_master())
		interpolate_rotation(delta);
	//use server update rate (default 25 Hz)
	//game update rate is default 60 Hz 
	_current_time += delta;
	if (_current_time < _update_delta)
		return;
	_current_time -= _update_delta;

	//handle movement locally if this is master
	if (_parent->is_network_master())
	{	
		float rotation = _parent->get_rotation();//static_cast<Node2D *>(_parent->get("skin"))->get_rotation();
		Vector2 movement_vector = _parent->get("movement_vector");
		
		//detect change in inputs
		if (movement_vector.length() || (_old_rot != rotation))
		{		
			_old_rot = rotation;
			//update input ID
			_current_input_id += 1;
			//locally update position (Client side prediction)
			
			_client_process_vectors();

			float speed_multiplier = _parent->get("speed_multiplier");
			
			//Send input data to Server
			if (get_tree()->is_network_server())
			{
				_server_process_vectors(movement_vector,rotation,speed_multiplier,_current_input_id);
			}
			else
			{
				rpc_id(1,"_server_process_vectors",movement_vector,rotation,speed_multiplier,_current_input_id);
			}
		}
	}
	//reset input vectors
	//movement_vector = Vector2(0,0)
	//speed_multiplier = 1
	_parent->set("movement_vector", Vector2(0,0));
	_parent->set("speed_multiplier", 1.f);
}


void CharMovement::_changeState(stateVector *initial_state, Vector2 mov_vct, float rot,float speed_mul,int input_id)
{
	//if no initial state compute as it is
	float speed = _parent->get("speed");
	if (!initial_state)
	{
		_parent->move_and_collide(mov_vct.normalized() * speed_mul * speed * _update_delta);
		_stateVectors.push_back(stateVector(_parent->get_position(), mov_vct, rot, speed_mul, input_id));
		return;
	}

	//////////////////client side prediction////////////////////////////////////////////////////
	//we need to append new state without changing position
	//save old position
	Vector2 old_position = _parent->get_position();
	//set position as initial state pos
	_parent->set_position(initial_state->position);
	//update
	

	_parent->move_and_collide(mov_vct.normalized() * speed_mul * speed * _update_delta);
	
	Vector2 new_position = _parent->get_position();
	//append new state
	_stateVectors.push_back(stateVector(new_position,mov_vct,rot,speed_mul,input_id));
	//revert back to old position
	_parent->set_position(old_position);
}


void CharMovement::_client_process_vectors()
{
	stateVector *last_state = nullptr;
	if (_stateVectors.size())
		last_state = &_stateVectors.back();

	Vector2 movement_vector = _parent->get("movement_vector");
	float speed_multiplier = _parent->get("speed_multiplier");

	_changeState(last_state,movement_vector,_parent->get_rotation(),speed_multiplier,_current_input_id);
	//#if movement update position and animation
	
	if (movement_vector.length())
	{
		Tween *ptween = static_cast<Tween *> (_parent->get_node("ptween"));

		ptween->interpolate_property(_parent, "position", _parent->get_position(), _stateVectors.back().position,
				_update_delta, Tween::TRANS_LINEAR,Tween::EASE_OUT_IN);
		
		ptween->start();

		//_parent->get_node("skin")->set("multiplier",speed_multiplier);
	}
}

//Server side Input data processor
void CharMovement::_server_process_vectors(Vector2 mov_vct,float rot,float speed_mul,int input_id)
{
	//safety check is it really server or not
	if (get_tree()->is_network_server())
	{
		bool is_walking = mov_vct.length();
		//if it is server's Character no need to recompute vectors
		if (_parent->is_network_master())
		{
			stateVector *last_state = nullptr;
			if (!_stateVectors.empty())
			{
				last_state = &_stateVectors.back();
				if (!last_state)
				{
					Godot::print("Error at  aserver");
				}
				float speed_multiplier = get("speed_multiplier");

				rpc("_syncVectors",last_state->position,last_state->rotation,speed_multiplier,
					is_walking,input_id);
			}
		}
		//Compute Input data
		else
		{
			stateVector *last_state = nullptr;
			if (!_stateVectors.empty())
			{
				last_state = &_stateVectors.back();
			}
			_changeState(last_state,mov_vct,rot,speed_mul,input_id);
			if (_stateVectors.size())
			{
				rpc("_syncVectors",_stateVectors.back().position,rot,speed_mul,
					 is_walking,input_id);
			}
		}
	}
	else
		Godot::print("Func (_server_process_vectors) called on peer");

}


stateVector *getStateVector(std::vector<stateVector> &_stateVectors,const int &input_id)
{
	for (auto it = _stateVectors.begin(); it != _stateVectors.end(); it++)
	{
		if (it->input_id == input_id)
		{
			return &(*it);
		}
	}
	return nullptr;
}

void removePreviousStateVectors(std::vector<stateVector> &_stateVectors,const int &input_id)
{
	std::vector<stateVector> new_vectors(_stateVectors.size());
	for (auto it = _stateVectors.begin(); it != _stateVectors.end(); it++)
	{
		if (it->input_id >= input_id)
		{
			new_vectors.push_back(*it);
		}
	}

	_stateVectors = new_vectors;
}

void CharMovement::_computeStates(Vector2 pos)
{
	Godot::print("called computeStates");
	_parent->set_position(pos);
	for (auto it = _stateVectors.begin(); it != _stateVectors.end(); it++)
	{
		it->position = _parent->get_position();
		_parent->move_and_collide(it->movement_vector * static_cast<float>(_parent->get("speed")) * it->speed_multiplier * _update_delta);
	}
}


//sync vectors 
//remotesync
void CharMovement::_syncVectors(Vector2 pos,float rot, float speed_mul,bool is_walking,int input_id)
{
	//Do reconsilation if Character is master
	if (_parent->is_network_master())
	{
		//get stateVector from movement history (stateVector_array)
		stateVector *S_VT = getStateVector(_stateVectors, input_id);
		if (S_VT)
		{			
			//if no error remove previous stateVectors from movement history 
			if ((S_VT->position - pos).length() < 1.25)
				removePreviousStateVectors(_stateVectors, input_id);
			//if error correct error
			else
			{				
				//used for debug will be removed soon
				Godot::print(S_VT->position,pos);
				removePreviousStateVectors(_stateVectors, input_id);
				_computeStates(pos);
			}
		}
		return;
	}
	//if Character is not master interpolate vectors
	Tween *ptween = static_cast<Tween *> (_parent->get_node("ptween"));
	ptween->interpolate_property(_parent,"position", _parent->get_position(), pos,
			_update_delta, Tween::TRANS_LINEAR, Tween::EASE_OUT);
	ptween->start();
	
	//Custom rotation interpolation
	//Tween node failed to produce desirable output So, Custom interpolation is used
	
	float rotation = _parent->get_rotation();
	
	if (rot < 0.f)
		rot += 6.28f;
	else if (rot > 6.28f)
		rot -= 6.28f;

	if (rotation < 0.f)
		rotation += 6.28f;
	else if (rotation > 6.28f)
		rotation -= 6.28f;

	_rotational_speed = abs(rot - rotation) / _update_delta;
	
	_parent->get_node("skin")->set("multiplier",speed_mul);
	_parent->get_node("skin")->set("is_walking",is_walking);
	
	//do not add if network server because state is already added
	if (!get_tree()->is_network_server())
		_stateVectors.push_back(stateVector(Vector2(),Vector2(),rot,0,0));
}


void CharMovement::_teleportCharacter(Vector2 pos)
{
	_parent->set_position(pos);
	_current_input_id += 1;
	_stateVectors.push_back(stateVector(pos,Vector2(0,0),0,1,_current_input_id));
}
