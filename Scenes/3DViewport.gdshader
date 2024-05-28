shader_type spatial;



void fragment() {
	vec4 wrld_vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	ALBEDO = wrld_vertex.rgb;
	
//	vec4 invcamx = MODEL_NORMAL_MATRIX.x;
//	vec4 invcamy = VIEW_MATRIX.y;
//	vec4 invcamz = VIEW_MATRIX.z;
//	vec4 invcamw = VIEW_MATRIX.w;
//
//	mat3 invcam = mat3(invcamx.xyz, invcamy.xyz, invcamz.xyz);
//
//	vec3 world_normal = NORMAL * invcam;
}
