#include <State.h>
#include <Bot.h>

void State::runState()
{
	//
}

State *State::chkForStateChange()
{
	for (auto &i : _connected_states)
	{
		if (i->isStateReady())
		{
			return i;
		}
	}

	return nullptr;
}

bool State::isStateReady()
{
	return false;
}