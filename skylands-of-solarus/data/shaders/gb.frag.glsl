#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D sol_texture;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

uniform vec2 sol_input_size;
uniform sampler2D previous;
uniform float persistence;

const float brighten_scanlines = 8.0;
const float brighten_lcd = 8.0;
const vec3 offsets = 3.141592654 * vec3(2,2,2);// vec3(1.0/2.0,1.0/2.0 - 2.0/3.0,1.0/2.0-4.0/3.0);
void main() {
    vec2 angle = sol_vtex_coord * 3.1415 * 2.0 * sol_input_size;

    float yfactor = (brighten_scanlines + sin(angle.y)) / (brighten_scanlines + 1.0);
    vec3 xfactors = (brighten_lcd + sin(angle.x + offsets)) / (brighten_lcd + 1.0);
    vec4 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    vec3 tex_color = texel.rgb;
    vec3 sepia = vec3(tex_color.x,tex_color.y,tex_color.z);

    sepia.r = dot(tex_color, vec3(.393, .769, .189));
    sepia.g = dot(tex_color, vec3(.349, .686, .168));
    sepia.b = dot(tex_color, vec3(.272, .534, .131));

    sepia *= vec3(0.7,1,0.7)*1.3;
    sepia = sepia*1.3 -vec3(0.2);

    vec3 previous_col = COMPAT_TEXTURE(previous, sol_vtex_coord).rgb;    

    FragColor.rgb = yfactor*xfactors* sepia * sol_vcolor.rgb;
    
    FragColor.rgb = previous_col * persistence + FragColor.rgb * (1.0-persistence);

    //FragColor.rgb = vec3(1,0,0);
    FragColor.a = 1.0;
}