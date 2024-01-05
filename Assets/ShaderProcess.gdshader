shader_type canvas_item;

uniform sampler2D island_tex;
uniform float test;

void fragment(){
	
	vec2 uvn=abs(UV-0.5) * 1.83;
	float maxc=max(uvn.y,uvn.x);
	vec3 mate=vec3(maxc);
	
	vec4 island = texture(island_tex, UV);
	
	float noise = 1.0;
	vec2 uv_noise = vec2(noise, 1);
	
	
	vec3 isl = island.xyz - mate;
	vec3 grad = texture(TEXTURE, isl.xy).xyz;
	
	vec4 color = vec4(grad, 3);

	COLOR = vec4(0.76 - color.rgb, color.a);
}