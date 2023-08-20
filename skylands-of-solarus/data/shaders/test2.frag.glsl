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
uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;
uniform int blurRadius = 1;
uniform int kernelSize = 3;


#define BLUR_RADIUS 1
#define KERNEL_SIZE (2 * BLUR_RADIUS + 1)


vec4 blend_screen(vec4 a, vec4 b) {
    return 1.0 - (1.0 - a) * (1.0 - b);
}

vec4 blend_multiply(vec4 a, vec4 b) {
    return a * b;
}

vec4 blend_overlay(vec4 base, vec4 blend, float strength) {
    return any(lessThan(base, vec4(0.5))) ? (2.0 * base * blend * strength) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend) * strength);
}



void main() {
    vec4 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    FragColor = vec4(texel.x,texel.y,texel.z, 1.0);
    vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
    //vec4 mixedColor = mix(texel, color, 0.6);
    //vec4 mixedColor = blend_screen(texel, color);
    //vec4 mixedColor = blend_multiply(texel, color);
    vec4 mixedColor = blend_overlay(texel, color, 0.5);
    FragColor = mixedColor;





  //vec4 sum = vec4(0.0);
  //for (int i = -blurRadius; i <= blurRadius; i++) {
  //  sum += COMPAT_TEXTURE(sol_texture, sol_vtex_coord + vec2(i, 0.0) / sol_texture_size);
  //}
  //FragColor = sum / kernelSize;




   // vec4 sum = vec4(0.0);
   // vec2 tex_offset = 1.0 / sol_texture_size;

   // for (int i = -BLUR_RADIUS; i <= BLUR_RADIUS; i++) {
   //     for (int j = -BLUR_RADIUS; j <= BLUR_RADIUS; j++) {
   //         sum += COMPAT_TEXTURE(sol_texture, sol_vtex_coord + vec2(i, j) * tex_offset) / (KERNEL_SIZE * KERNEL_SIZE);
   //     }
   // }

   // FragColor = sum;

}
