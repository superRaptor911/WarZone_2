shader_type canvas_item;
uniform float speed = 1.0;


void fragment()
{
	float mod_time = TIME * 2.0 * speed;
	COLOR = texture(TEXTURE,UV) * (1.0 + abs(sin(mod_time))); 
}