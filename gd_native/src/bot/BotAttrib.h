#ifndef BOTATTRIB_H
#define BOTATTRIB_H


struct BotAttrib
{
	enum EGetMode
	{
		NEAREST = 0, NEAREST_AIM, FARTHEST
	};

	int enemy_get_mode = EGetMode::NEAREST;
	float spray_time = 0.3f;
	float accuracy = 0.5f;
	float spray_delay = 0.4f;
	float rotational_speed = 2.f;
	float reaction_time = 1.f;

	bool enable_evasive_mov = false;
	bool is_coward = false;
};

#endif