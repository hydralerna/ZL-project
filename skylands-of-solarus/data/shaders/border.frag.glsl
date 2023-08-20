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
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

// Calculate the distance from the current pixel to the nearest corner.
float corner_distance(vec2 coord) {
  vec2 d = min(coord, sol_input_size - coord);
  return length(d);
}

void main() {

  // Get the texture coordinates of the current pixel
  vec2 tex_coord = sol_vtex_coord;

  // Set the border size (in pixels)
  float size = 64.0;
  float border_size = size  / (max(sol_input_size.x, sol_input_size.y));
  float width_border_size = size / sol_input_size.x;
  float height_border_size = size / sol_input_size.y;

  // Calculate the distance from the current pixel to the nearest corner.
  float distance = corner_distance(sol_vtex_coord);


  // Calculate the distance from the edges of the image
  float dist_left = abs(sol_vtex_coord.x);
  float dist_right = abs(1.0 - sol_vtex_coord.x);
  float dist_top = abs(sol_vtex_coord.y);
  float dist_bottom = abs(1.0 - sol_vtex_coord.y);

  // If the pixel is within the border size of the edge, set it to black
  if (dist_left < width_border_size || dist_right < width_border_size || dist_top < height_border_size || dist_bottom < height_border_size) {
    float distance = min(min(dist_left, dist_right), min(dist_top, dist_bottom));
    float alpha = smoothstep(border_size, 0.0, distance); // Calculate the alpha value for the gradient based on the distance from the edges
    //float alpha = smoothstep(32.0, 0.0, distance); // Use smoothstep to create a gradient for the border.
    vec4 base = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    vec4 blend = vec4(.0, .0, .0, 1.0);
    FragColor = mix(base, blend, alpha);
  }
  else {
  // Otherwise, set it to the texture color
    FragColor = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
  }
}