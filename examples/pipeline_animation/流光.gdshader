shader_type spatial;

uniform vec3 color: source_color;
uniform sampler2D mask;
uniform sampler2D noise;


void fragment() {
	ALBEDO = color;
	
	EMISSION = color * 2.0;
	
	vec2 uv = UV;
	uv.y *= 5.0;
	uv += TIME * 0.5;
	ALPHA = min(texture(mask, uv).r * 1.2, 1.0);
}
