shader_type spatial;

//render_mode shadows_disabled;

uniform float distance_fade_min: hint_range(0.0, 100.0, 0.1) = 3.0;
uniform float distance_fade_max: hint_range(0.0, 100.0, 0.1) = 10.0;

void fragment() {
	ALPHA *= clamp(smoothstep(distance_fade_min, distance_fade_max, length(VERTEX)), 0.0, 1.0);
}
