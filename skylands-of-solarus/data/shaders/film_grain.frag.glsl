/*
 * FILM GRAIN shader
 * Made by froggy77 for Solarus - http://www.solarus-games.org
 * with the help of ChatGPT AI - https://chat.openai.com
 * GLSL rand() function by Andy Gryc (ajgryc) - http://byteblacksmith.com
 * Animation from "Film grain" shader by jcant0n - https://www.shadertoy.com/view/4sXSWs
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
 */
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
uniform int sol_time;

uniform bool sepia = false;
uniform bool gray = false;
uniform bool grey = false;
uniform bool mycolor = false;
uniform vec3 color = vec3(1.0, 0.85, 0.55);

uniform float opacity1 = 0.2;
uniform bool merge1 = false;
uniform bool add1 = false;
uniform bool screen1 = false;
uniform bool overlay1 = false;
uniform bool multiply1 = false;

uniform float opacity2 = 0.3;
uniform bool merge2 = false;
uniform bool add2 = false;
uniform bool screen2 = false;
uniform bool overlay2 = false;
uniform bool multiply2 = false;

uniform bool animation1 = false;
uniform bool animation2 = false;
uniform float strength = 16.0;

uniform bool hq2x = true;

COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.1415);
    return fract(sin(sn) * c);
}


// Different blend mode function
// 'a' is the bAse, 'b' is Blend, 's' is the Strenght

vec4 blend_add(vec4 a, vec4 b) {
    return a + b;
}

vec4 blend_screen(vec4 a, vec4 b) {
    return 1.0 - (1.0 - a) * (1.0 - b);
}

vec4 blend_multiply(vec4 a, vec4 b) {
    return a * b;
}

vec4 blend_overlay(vec4 a, vec4 b, float s) {
    return any(lessThan(a, vec4(0.5))) ? (2.0 * a * b * s) : (1.0 - 2.0 * (1.0 - a) * (1.0 - b) * s);
}
// --

// h2qx
uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

const float mx = 0.325;      // start smoothing wt.
const float k = -0.250;      // wt. decrease factor
const float max_w = 0.25;    // max filter weight
const float min_w =-0.05;    // min filter weight
const float lum_add = 0.25;  // effects smoothing

vec2 texcoord = sol_vtex_coord;
// --

void main() {

  float randomValue = rand(vec2(sol_vtex_coord));
  if (sepia) {
    vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;
    FragColor = vec4(texel.x, texel.y, texel.z, 1.0);
    FragColor.r = mix(dot(texel, vec3(.393, .769, .189)), randomValue, opacity1);
    FragColor.g = mix(dot(texel, vec3(.349, .686, .168)), randomValue, opacity1);
    FragColor.b = mix(dot(texel, vec3(.272, .534, .131)), randomValue, opacity1);
  }
  else if (gray || grey) {
    vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;
    FragColor = vec4(texel.x, texel.y, texel.z, 1.0);
    FragColor.r = mix(dot(texel, vec3(.2382, .6797, .082)), randomValue, opacity1);
    FragColor.g = mix(dot(texel, vec3(.2382, .6797, .082)), randomValue, opacity1);
    FragColor.b = mix(dot(texel, vec3(.2382, .6797, .082)), randomValue, opacity1);
  }
  else if (mycolor) {
    vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;
    vec4 base = vec4(texel, 1.0);
    vec4 blend = vec4(0.0, 0.0, 0.0, 1.0);
    FragColor = vec4(texel.x, texel.y, texel.z, 1.0);
    if (merge1) {
      blend = mix(vec4(color, 1.0), vec4(randomValue, randomValue, randomValue, 1.0), opacity1);
    }
    else if (add1) {
      blend = blend_add(vec4(color, 1.0), vec4(randomValue, randomValue, randomValue, 1.0));
    }
    else if (screen1) {
      blend = blend_screen(vec4(color, 1.0), vec4(randomValue, randomValue, randomValue, 1.0));
    }
    else if (overlay1) {
      blend = blend_overlay(vec4(color, 1.0), vec4(randomValue, randomValue, randomValue, 1.0), opacity1);
    }
    else if (multiply1) {
      blend = blend_multiply(vec4(color, 1.0), vec4(randomValue, randomValue, randomValue, opacity1));
    }
    if (merge1 || add1 || screen1 || overlay1 || multiply1) {
      if (merge2) {
       FragColor = mix(base, blend, opacity2);
      }
      else if (add2) {
        FragColor = blend_add(base, blend);
      }
      else if (screen2) {
        FragColor = blend_screen(base, blend);
      }
      else if (overlay2) {
        FragColor = blend_overlay(base, blend, opacity2);
      }
      else if (multiply2) {
        FragColor = blend_multiply(base, blend);
      }
      else {
        FragColor =  mix(base, blend, opacity1);
      }
    }
    else {
      float gr3y = (texel.r + texel.g + texel.b) / 3.0;
      FragColor.r = mix(gr3y * color.r, randomValue, opacity1);
      FragColor.g = mix(gr3y * color.g, randomValue, opacity1);
      FragColor.b = mix(gr3y * color.b, randomValue, opacity1);
      vec4 blend = FragColor;
    }
  }
  // my_color is false
  else {
    vec4 base = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    FragColor.rgb += randomValue;
    vec4 blend = FragColor;
    FragColor = mix(base, blend, opacity1);
  }

  // Animation
  if (animation1 || animation2) {
    float x = (sol_vtex_coord.x + 4.0 ) * (sol_vtex_coord.y + 4.0 ) * (sol_time * 10.0);
    vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
    if(animation1) {
      grain = 1.0 - grain;
		  FragColor = FragColor * grain;
    }
    else {
      FragColor = FragColor + grain;
    }
  }

  // hq2x
  if (hq2x) {
    float x = 0.5 / sol_texture_size.x;
    float y = 0.5 / sol_texture_size.y;
    vec2 dg1 = vec2( x, y);
    vec2 dg2 = vec2(-x, y);
    vec2 dx = vec2(x, 0.0);
    vec2 dy = vec2(0.0, y);
 
    vec4 texcolor = COMPAT_TEXTURE(sol_texture, texcoord);

    vec3 c00 = COMPAT_TEXTURE(sol_texture, texcoord - dg1).xyz;
    vec3 c10 = COMPAT_TEXTURE(sol_texture, texcoord - dy).xyz;
    vec3 c20 = COMPAT_TEXTURE(sol_texture, texcoord - dg2).xyz;
    vec3 c01 = COMPAT_TEXTURE(sol_texture, texcoord - dx).xyz;
    vec3 c11 = texcolor.xyz;
    vec3 c21 = COMPAT_TEXTURE(sol_texture, texcoord + dx).xyz;
    vec3 c02 = COMPAT_TEXTURE(sol_texture, texcoord + dg2).xyz;
    vec3 c12 = COMPAT_TEXTURE(sol_texture, texcoord + dy).xyz;
    vec3 c22 = COMPAT_TEXTURE(sol_texture, texcoord + dg1).xyz;
    vec3 dt = vec3(1.0, 1.0, 1.0);

    float md1 = dot(abs(c00 - c22), dt);
    float md2 = dot(abs(c02 - c20), dt);

    float w1 = dot(abs(c22 - c11), dt) * md2;
    float w2 = dot(abs(c02 - c11), dt) * md1;
    float w3 = dot(abs(c00 - c11), dt) * md2;
    float w4 = dot(abs(c20 - c11), dt) * md1;

    float t1 = w1 + w3;
    float t2 = w2 + w4;
    float ww = max(t1, t2) + 0.0001;

    c11 = (w1 * c00 + w2 * c20 + w3 * c22 + w4 * c02 + ww * c11) / (t1 + t2 + ww);

    float lc1 = k / (0.12 * dot(c10 + c12 + c11, dt) + lum_add);
    float lc2 = k / (0.12 * dot(c01 + c21 + c11, dt) + lum_add);

    w1 = clamp(lc1 * dot(abs(c11 - c10), dt) + mx, min_w, max_w);
    w2 = clamp(lc2 * dot(abs(c11 - c21), dt) + mx, min_w, max_w);
    w3 = clamp(lc1 * dot(abs(c11 - c12), dt) + mx, min_w, max_w);
    w4 = clamp(lc2 * dot(abs(c11 - c01), dt) + mx, min_w, max_w);

    FragColor = vec4(w1 * c10 + w2 * c21 + w3 * c12 + w4 * c01 + (1.0 - w1 - w2 - w3 - w4) * c11, 1.0);
    float gr3y = (FragColor.r + FragColor.g + FragColor.b) / 3.0;
    FragColor.r = mix(gr3y * color.r, randomValue, 0.1);
    FragColor.g = mix(gr3y * color.g, randomValue, 0.1);
    FragColor.b = mix(gr3y * color.b, randomValue, 0.1);

  }

}
