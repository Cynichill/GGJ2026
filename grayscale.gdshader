shader_type canvas_item;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	float grayscale = (original_color.r + original_color.g + original_color.b) / 3.0f;
	
	vec3 grayscale_color = vec3(grayscale, grayscale, grayscale);
	
	COLOR.rgb = grayscale_color;
	COLOR.a = original_color.a;
}

