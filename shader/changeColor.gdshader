shader_type canvas_item;
 
uniform vec4 target_color : source_color;
uniform vec4 replace_color : source_color; 
uniform float tolerance : hint_range(0, 1); 
 
void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
 
    float dist = distance(tex_color.rgb, target_color.rgb);
 
    if (dist < tolerance) {
        vec3 offset = tex_color.rgb - target_color.rgb;
        tex_color.rgb = clamp(replace_color.rgb + offset, 0.0, 1.0);
    }
 
    COLOR = tex_color;
}