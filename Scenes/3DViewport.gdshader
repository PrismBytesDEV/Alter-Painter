shader_type spatial;

void fragment() {
	vec4 wrld_vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	ALBEDO = wrld_vertex.rgb;
	ALBEDO = NORMAL;
}
