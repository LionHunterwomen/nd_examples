shader_type spatial;

render_mode skip_vertex_transform;

uniform sampler2D noise_texture_1;
uniform sampler2D noise_texture_2;
uniform vec3 color: source_color;

void vertex() {
	vec2 uv = UV;
	uv.y += TIME * 0.05;
	uv.y *= 15.0;
	
	float noise_1 = texture(noise_texture_1, uv).r;
	
	uv.x += TIME * 0.5;
	
	float noise_2 = texture(noise_texture_2, uv).r;
	
	float noise = noise_1 * noise_2;
	
	VERTEX.xz *= 1.0 + noise * 0.8;
	NORMAL *= 1.0 + noise * 0.8;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = MODELVIEW_NORMAL_MATRIX * NORMAL;
}


void fragment() {
	vec2 uv = UV;
	uv.y += TIME * 0.05;
	uv.y *= 15.0;
	
	float noise_1 = texture(noise_texture_1, uv).r;
	
	uv.x += TIME * 0.5;
	
	float noise_2 = texture(noise_texture_2, uv).r;
	
	//float noise = mix(noise_1, noise_2, 0.5);
	float noise = noise_1 * noise_2;
	
	ALBEDO = vec3(color + noise);
	
	
}
