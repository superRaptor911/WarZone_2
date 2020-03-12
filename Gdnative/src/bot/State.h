#ifndef STATE_H
#define STATE_H

#include <vector>
#include <Godot.hpp>
#include <Node2D.hpp>

namespace godot
{
	class Bot;

	class State
	{		
	protected:

		godot::Node2D *_parent;
		godot::Bot *_bot;
		std::vector<State *> _connected_states;
		bool _block_state_change = false;

	public:

		State *prev_state = nullptr;

	public:

		static void _register_methods(){}
		
		virtual void runState();
		virtual bool isStateReady();
		virtual void startState();
		virtual void stopState();
		State *chkForStateChange();

		void setParentAndBot(godot::Node2D *parent, godot::Bot *bot) {_parent = parent; _bot = bot;}
		void connect(State *state) {_connected_states.push_back(state);}
	};
}




#endif