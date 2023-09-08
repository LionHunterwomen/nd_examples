shader_type spatial;

uniform sampler2D TEXTURE;
uniform bool flashing;

void fragment() {
	ALBEDO = texture(TEXTURE, UV).rgb;
	if (flashing) {
		ALBEDO *= 2.0;
	}
}
