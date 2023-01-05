/*
 * DISTORTION shader (version 1.0 - January 05, 2023)
 *
 * Made by froggy77 for Solarus - http://www.solarus-games.org
 * with the help of ChatGPT AI  - https://chat.openai.com
 * From some lines of script by Kyle Pulver  - http://kpulv.com/tag/shaders/page/5/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * -- Example usage in the Solarus script:
 *
 * local shader = sol.shader.create("distortion")
 *
 * shader:set_uniform("bgcolor", {0.0, 0.0, 0.0, 1.0})
 * shader:set_uniform("cos_x", false)
 * shader:set_uniform("cos_y", true)
 * shader:set_uniform("slowness", 50.0)
 * shader:set_uniform("distortion_x", 5.0)
 * shader:set_uniform("distortion_y", 2.5)
 * shader:set_uniform("scale_x", 7.0)
 * shader:set_uniform("scale_y", 3.0)
 *
 * sol.video.set_shader(shader)
 * 
 * ----
 *
 * The "shader:set_uniform(uniform_name, value)" lines are not needed if you leave the defaults.
 * So these two lines are enough unless you want other values:
 *
 * local shader = sol.shader.create("distortion")
 *
 * sol.video.set_shader(shader)
 *
 * ----
 */
#if VERSION >= 130
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

uniform sampler2D sol_texture;      // Texture.
uniform int sol_time;               // Time variable.
uniform vec4 bgcolor = vec4(0.0, 0.0, 0.0, 1.0); // (black) Default background color to be used if the image is distorted outside the screen.
uniform bool cos_x = false;         // Boolean variable to determine if the x coordinate should use cosine or sine.
uniform bool cos_y = true;          // Boolean variable to determine if the y coordinate should use cosine or sine.
uniform float slowness = 50.0;      // Variable to control the speed at which the distortion occurs. (eg: 10.0 is fast, 100.0 slower)
uniform float distortion_x = 5.0;   // Variable to control the amount of distortion on the x coordinate.
uniform float distortion_y = 2.5;   // Variable to control the amount of distortion on the y coordinate.
uniform float scale_x = 7.0;        // Variable to control the scale of the distortion on the x coordinate.
uniform float scale_y = 3.0;        // Variable to control the scale of the distortion on the y coordinate.

// Declare the texture coordinates and color to be used in the shader.
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;


void main() {
  // Initialize the texture coordinate.
  vec2 coord = sol_vtex_coord.xy;

  // Distort the x coordinate based on the time, the y coordinate, and the cosine or sine function.
  coord.x += cos_x ? cos(radians(sol_time / slowness + coord.y * distortion_x * 100)) * (scale_x / 100.0) : sin(radians(sol_time / slowness + coord.y * distortion_x * 100)) * (scale_x / 100.0);

  // Distort the y coordinate based on the time, the x coordinate, and the cosine or sine function.
  coord.y += cos_y ? cos(radians(sol_time / slowness + coord.x * distortion_y * 100)) * (scale_y / 100.0) : sin(radians(sol_time / slowness + coord.x * distortion_y * 100)) * (scale_y / 100.0);

  // Get the color of the texture at the distorted coordinate.
  vec4 tex_color = COMPAT_TEXTURE(sol_texture, coord);

  // If the x coordinate is out of bounds, set the fragment color to the background color.
  if (coord.x < 0.0 || coord.x > 1.0) {
    FragColor = bgcolor;
  } 
  // If the y coordinate is out of bounds, set the fragment color to the background color.
  else if (coord.y < 0.0 || coord.y > 1.0) {
    FragColor = bgcolor;
  }
  // Otherwise, set the fragment color to the color of the texture.
  else {
    vec4 tex_color = COMPAT_TEXTURE(sol_texture, coord);
    FragColor = tex_color;
  }
}
