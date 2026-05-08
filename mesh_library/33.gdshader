shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(0.9, 0.95, 1.0, 0.15);
uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float refraction_scale : hint_range(-1.0, 1.0) = 0.05;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    ALBEDO = albedo.rgb;
    ALPHA = albedo.a;
    ROUGHNESS = roughness;
    METALLIC = 0.0;
    SPECULAR = 0.5;

    // Refraction
    vec2 offset = NORMAL.xy * refraction_scale;
    EMISSION = texture(screen_texture, SCREEN_UV + offset).rgb * (1.0 - albedo.a);
}