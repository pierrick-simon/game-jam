shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec2 mask_position;
uniform vec2 mask_size;
uniform vec2 screen_size;

void fragment() {
    vec2 mask_uv = (SCREEN_UV * screen_size - mask_position) / mask_size;

    float mask_alpha = texture(mask_texture, mask_uv).a;

    vec4 col = texture(TEXTURE, UV);

    // HARD MASK:
    // only fully transparent pixels reveal BG2
    float reveal = step(mask_alpha, 0.0);

    col.a *= 1.0 - reveal;

    COLOR = col;
}