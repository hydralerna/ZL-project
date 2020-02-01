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

const float brighten_scanlines = 16.0;
const float brighten_lcd = 4.0;
const vec3 offsets = 3.141592654 * vec3(1.0/2.0,1.0/2.0 - 2.0/3.0,1.0/2.0-4.0/3.0);
void main() {
    vec2 angle = sol_vtex_coord * 3.1415 * 2.0 * sol_input_size;

    float yfactor = (brighten_scanlines + sin(angle.y)) / (brighten_scanlines + 1.0);
    vec3 xfactors = (brighten_lcd + sin(angle.x + offsets)) / (brighten_lcd + 1.0);

    vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    FragColor.rgb = yfactor*xfactors*tex_color.rgb * sol_vcolor.rgb;
    FragColor.a = 1.0;
}
