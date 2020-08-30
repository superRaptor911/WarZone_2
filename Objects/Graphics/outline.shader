shader_type canvas_item;

uniform vec4 clr : hint_color;
uniform vec2 tex_size = vec2(64.0,64.0);
uniform float out_size = 1.0;
uniform float use = 0.0;

void fragment()
{
	vec4 color = clr * use;
	vec2 size = out_size / tex_size * use;
    vec4 sprite_color = texture(TEXTURE, UV);
   
    float alpha = sprite_color.a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
   
    vec3 final_color = mix(color.rgb, sprite_color.rgb, sprite_color.a + 0.3);
    COLOR = vec4(final_color, clamp(alpha, 0.0, 1.0));
}