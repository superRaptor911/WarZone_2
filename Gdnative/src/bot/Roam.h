#ifndef ROAM_H
#define ROAM_H

#include <State.h>
#include <Array.hpp>

class Roam : public State
{
private:

	bool _on_dest = true;
	int _current_dest_id = 0;

	godot::Array _path_to_dest;



private:

	void headToDest();

public:

	virtual void runState();

};

#endif