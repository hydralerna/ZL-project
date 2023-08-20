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
uniform int sol_time;

void main() {

  vec4 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
  float strength = 16.0;
  float x = (sol_vtex_coord.x + 4.0 ) * (sol_vtex_coord.y + 4.0 ) * (sol_time * 10.0);
  vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;

  // Vertical black line:
  if(abs(sol_vtex_coord.x - 0.5) < 0.002)
    texel = vec4(0.0);

  // Right part
  if(sol_vtex_coord.x > 0.5) {
    grain = 1.0 - grain;
		FragColor = texel * grain;
  }
  // Left part
  else {
    FragColor = texel + grain;
  }
}