#include <State.h>
#include <Bot.h>
using namespace godot;

void State::initState()
{
	//pass
}

void State::runState()
{
	//pass
}

State *State::chkForStateChange()
{
	if (_block_state_change)
		return nullptr;

	for (auto &i : _connected_states)
	{
		if (i->isStateReady())
		{
			return i;
		}
	}

	if (prev_state and prev_state->isStateReady())
		return prev_state;

	return nullptr;
}

bool State::isStateReady()
{
	return false;
}

void State::startState()
{
	//pass
}

void State::stopState()
{

}