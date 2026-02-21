shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec4 glow_color : source_color = vec4(0.6, 1.0, 0.6, 1.0); // green-ish
uniform float glow_strength = 0.0;
uniform float glow_width = 2.0;

void fragment() {
	float rim = pow(1.0 - dot(NORMAL, VIEW), glow_width);
	EMISSION = glow_color.rgb * rim * glow_strength;
	ALBEDO = vec3(0.0); // don't paint white
}