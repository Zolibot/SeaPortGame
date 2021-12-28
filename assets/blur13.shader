shader_type canvas_item;

uniform float offset: hint_range(0.0, 100.0);
uniform float offset_step: hint_range(0.0, 100.0);

uniform float intensity = 0.5f;
uniform float layers = 5f;
uniform float speed = 4f;

uniform sampler2D noise : hint_albedo;
uniform sampler2D blured : hint_albedo;
uniform sampler2D sprite : hint_albedo;
uniform sampler2D mask : hint_albedo;

float gradient(vec2 uv){
	return (0.5f - distance(vec2(uv.x,uv.y),vec2(0.5 ,0.5))); 
//	return (  distance(vec2(0,uv.y),vec2(0.0 ,0.0))); 
//	return (0.5f - distance(vec2(0,uv.y),vec2(0.0 ,0.5))); 
//	return (  distance(vec2(0,uv.y),vec2(0.0 ,1.0))); 
//	return (0.5f - distance(vec2(0,uv.y),vec2(0.0 ,0.0))); 
}

vec4 colorize(float c,float a){
	vec4 palete = vec4(c,c,c,a);
	return palete;
}

vec4 colorize1(float c,float a){
	vec4 palete = vec4(c,c,c,a);
	palete.r = float(c >= 1f);
//	palete.g = c;//float(c <= 0.1f);
//	palete.b = float(c >= 0.102f);
	return palete;
}

vec4 blur13(sampler2D image,vec2 uv,vec2 resolution,vec2 direction){
        vec4 color = vec4(0.0);
        vec2 off1 = vec2(1.411764705882353) * direction;
        vec2 off2 = vec2(3.2941176470588234) * direction;
        vec2 off3 = vec2(5.176470588235294) * direction;
        color += texture(image, uv) * 0.1964825501511404;
        color += texture(image, uv + (off1 / resolution)) * 0.2969069646728344;
        color += texture(image, uv - (off1 / resolution)) * 0.2969069646728344;
        color += texture(image, uv + (off2 / resolution)) * 0.09447039785044732;
        color += texture(image, uv - (off2 / resolution)) * 0.09447039785044732;
        color += texture(image, uv + (off3 / resolution)) * 0.010381362401148057;
        color += texture(image, uv - (off3 / resolution)) * 0.010381362401148057;
        return color;
} 


vec4 blur5(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.3333333333333333) * direction;
    color += texture(image, uv) * 0.29411764705882354;
    color += texture(image, uv + (off1 / resolution)) * 0.35294117647058826;
    color += texture(image, uv - (off1 / resolution)) * 0.35294117647058826;
    return color;
}



vec4 blur9(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.3846153846) * direction;
    vec2 off2 = vec2(3.2307692308) * direction;
    color += texture(image, uv) * 0.2270270270;
    color += texture(image, uv + (off1 / resolution)) * 0.3162162162;
    color += texture(image, uv - (off1 / resolution)) * 0.3162162162;
    color += texture(image, uv + (off2 / resolution)) * 0.0702702703;
    color += texture(image, uv - (off2 / resolution)) * 0.0702702703;
    return color;
}

vec3 offset_blur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction, float iter,float _offset,float _offset_step){
	int s = 0;
	vec3 color;
	float di = _offset / _offset_step;
	for (float i=-_offset;i<_offset;i+=di){
		color += blur5(image,uv,resolution,vec2(sin(i) * i,cos(i) * i)).rgb;
		s+=1;
	}
	return color /= float(s);
}

void fragment(){
	COLOR = vec4(0);
	COLOR.a = 1.0;

	COLOR = texture(TEXTURE,UV);
	COLOR.rgb = 1.0 - COLOR.rgb;

	float value = COLOR.r;
	vec4 bg = texture(noise,vec2(UV.x,UV.y + TIME / speed));

	COLOR.rgb = vec3(value);
	COLOR.r *= 1.0 - gradient(UV);  
	COLOR.r = clamp(COLOR.r * bg.r * intensity * 10f,0f,1f);
	COLOR.r = floor(COLOR.r * layers) / layers;

	COLOR = colorize1(COLOR.r,COLOR.a);
	COLOR.b = smoothstep(0f-0.8,1.0,COLOR.b);
	COLOR -= 1.0 - texture(mask, UV);
//	COLOR.rgb += texture(sprite,UV).rgb;
}