shader_type canvas_item;

void fragment() {
    vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	float clr = (c.r + c.g + c.b) / 3.0;
	COLOR = vec4(clr, clr, clr, 1.0);
}