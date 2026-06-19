shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_shallow : source_color = vec4(0.1, 0.6, 0.65, 1.0); // CS2 sığ/berrak su tonu
uniform vec4 color_deep : source_color = vec4(0.02, 0.18, 0.32, 1.0);  // CS2 derin su tonu
uniform float camera_depth_fade : hint_range(0.1, 10.0) = 3.5;
uniform float beers_law : hint_range(0.1, 5.0) = 1.2;

uniform sampler2D wave_bump : hint_normal, repeat_enable; // Godot 4.6 için normal ipucu
uniform vec2 wave_speed = vec2(0.02, 0.02);
uniform float wave_scale : hint_range(0.01, 1.0) = 0.15;
uniform float roughness : hint_range(0.0, 1.0) = 0.03; // CS2 gibi pürüzsüz parıltı için düşük tutun

// Godot 4.6 dahili doku tanımlamaları
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
	// CS2 tarzı akışkanlık için zıt yönlere kayan iki normal haritası karışımı
	vec2 time_offset1 = TIME * wave_speed;
	vec2 time_offset2 = TIME * vec2(-wave_speed.y, wave_speed.x) * 0.75;
	
	vec3 normal1 = texture(wave_bump, UV * wave_scale + time_offset1).rgb * 2.0 - 1.0;
	vec3 normal2 = texture(wave_bump, UV * wave_scale * 1.3 + time_offset2).rgb * 2.0 - 1.0;
	vec3 normal_mix = normalize(normal1 + normal2);
	
	NORMAL_MAP = normal_mix * 0.5 + 0.5;
	ROUGHNESS = roughness;
	METALLIC = 0.05;
	SPECULAR = 0.7; // Güneş ışığının parlak patlaması için yüksek specular

	// CS2 Tarzı Ekran Alanı Kırılması (Refraction)
	vec2 refraction_uv = SCREEN_UV + (normal_mix.xy * 0.02);
	
	// Godot 4.6 Derinlik Tamponu (Depth Buffer) Çözümlemesi
	float depth_raw = texture(depth_texture, refraction_uv).x;
	vec3 ndc = vec3(refraction_uv, depth_raw) * 2.0 - 1.0;
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_pos = world.xyz / world.w;
	
	float depth_dist = distance((INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz, world_pos);
	float depth_factor = clamp(exp(-depth_dist / camera_depth_fade * beers_law), 0.0, 1.0);

	// CS2 Suyu berraktır, arkasındaki dünyayı kendi rengiyle çarparak gösterir
	vec3 screen_color = texture(screen_texture, refraction_uv).rgb;
	vec3 water_color = mix(color_deep.rgb, color_shallow.rgb, depth_factor);
	
	// Nihai renk birleştirmesi
	ALBEDO = mix(water_color, screen_color * water_color * 1.8, depth_factor * 0.6);
}