shader_type spatial;

void fragment() {
	ALBEDO = mix(vec3(0.2, 0.5, 0.1), vec3(0.06, 0.02, 0.01), smoothstep(1.0, 0.8, (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).y));
}
