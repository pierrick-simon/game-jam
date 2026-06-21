shader_type canvas_item;

uniform float offset;

void fragment() {
    COLOR = texture(TEXTURE, UV + vec2(offset, 0));
}