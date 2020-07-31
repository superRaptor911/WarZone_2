#ifndef CHARMOVEMENT_H
#define CHARMOVEMENT_H

#include <Godot.hpp>
#include <KinematicBody2D.hpp>
#include <Input.hpp>
#include <vector>
#include <Reference.hpp>
#include <KinematicCollision2D.hpp>
#include <CollisionShape2D.hpp>
#include <Tween.hpp>

namespace godot
{
	class stateVector :public Reference
	{
		GODOT_CLASS(stateVector, Reference)
	public:
		Vector2 position;
		float rotation;
		int input_id;
		Vector2 movement_vector;

		stateVector()
		{
			position = Vector2(0,0);
			movement_vector = Vector2(0,0);
			rotation = 0.f;
			input_id = 0;
		}

		stateVector(const Vector2 &pos,const Vector2 &mov_vct,float rot,int _input_id)
		{
			position = pos;
			rotation = rot;
			input_id = _input_id;
			movement_vector = mov_vct;
		}

		static void _register_methods()
		{
			register_property<stateVector, Vector2>("position", &stateVector::position, Vector2(0,0));
			register_property<stateVector, Vector2>("movement_vector", &stateVector::movement_vector, Vector2(0,0));
			register_property<stateVector, float>("rotation", &stateVector::rotation, 0.f);
			register_property<stateVector, int>("input_id", &stateVector::input_id, 0);
		}
	};

	template <typename T> 
	int sign(T val) 
	{
    	return (T(0) < val) - (val < T(0));
	}
	

	class CharMovement : public Node
	{
		GODOT_CLASS(CharMovement, Node)

	private:

		Input* _Input;
		KinematicBody2D *_parent;
		Tween *_tween;
		Node *_model;
		//CollisionShape2D *_skin;
		int _current_input_id = 0;
		float _rotational_speed = 0.1f;

		float _update_delta;
		float _current_time = 0.f;
		float _old_rot = 0.f;

		std::vector<stateVector> _stateVectors;

	private:

		void _changeState(stateVector *initial_state, Vector2 mov_vct, float rot,int input_id);
		void _client_process_vectors();
		void _server_process_vectors(Vector2 mov_vct,float rot,int input_id);
		void _syncVectors(Vector2 pos,float rot,bool is_walking,int input_id);
		void _computeStates(Vector2 pos);
		void _teleportCharacter(Vector2 pos);

	public:
		static void _register_methods();

		CharMovement();
		~CharMovement();

		void _init(); // our initializer called by Godot

		void _ready();

		void _process(float delta);

		void movement(float delta);

		void interpolate_rotation(float delta);
		
	};
}

#endif