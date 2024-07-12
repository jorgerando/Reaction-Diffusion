// file: render.frag

#version 150

out vec4 fragColor;

uniform vec2 wh_rcp;
uniform sampler2D tex;

vec3 hsb2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main () {
  vec2 val = texture(tex, gl_FragCoord.xy * wh_rcp).rg;
  
  vec3 color_ = hsb2rgb(vec3(val.g*2.2,1.,1.));

  float a = smoothstep(0.2, 0.1, val.g);

  fragColor = vec4(color_,1);
}
