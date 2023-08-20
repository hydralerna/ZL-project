/*
 * Copyright (C) 2018 Solarus - http://www.solarus-games.org
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
uniform sampler2D blend_texture;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;
uniform float time;

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

vec4 blend_add(vec4 a, vec4 b) {
    return a + b;
}

vec4 blend_screen(vec4 a, vec4 b) {
    return 1.0 - (1.0 - a) * (1.0 - b);
}

vec4 blend_overlay(vec4 base, vec4 blend, float strength) {
    return any(lessThan(base, vec4(0.5))) ? (2.0 * base * blend * strength) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend) * strength);
}

vec4 blend_merge(vec4 base, vec4 blend, float strength) {
    return mix(base, blend, strength);
}


#define KERNEL_SIZE 5

const float kernel[KERNEL_SIZE] = float[](0.06136, 0.24477, 0.38774, 0.24477, 0.06136);

vec4 blend_test(sampler2D tex, vec2 texCoord, float strength) {
    vec4 sum = vec4(0.0);
    for (int i = -2; i <= 2; i++) {
        float offset = float(i) / float(KERNEL_SIZE);
        sum += texture(tex, texCoord + offset) * kernel[i + 2];
    }
    return mix(texture(tex, texCoord), sum, strength);
}

void main() {
    //vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;
    vec4 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    //vec3 blend_texel = COMPAT_TEXTURE(blend_texture, sol_vtex_coord).rgb;
    //vec4 blend_texel = COMPAT_TEXTURE(blend_texture, sol_vtex_coord);
    //FragColor = vec4(texel.x,texel.y,texel.z, 1.0);
    //FragColor.r = dot(texel, vec3(.5, .5, .5));
    //FragColor.g = dot(texel, vec3(.7, .7, .7));
    //FragColor.b = dot(texel, vec3(.9, .9, .9));
    float randomValue = rand(vec2(sol_vtex_coord.xy));
    FragColor.rgb += randomValue;
    //FragColor.r += randomValue;
    vec4 blend_texel = FragColor;
    //FragColor.g += randomValue;
    //FragColor.b += randomValue;
    //FragColor.rgb += randomValue;
    //FragColor = blend_add(FragColor, vec4(blend_texel, 1.0));
    //FragColor = blend_overlay(texel, blend_texel);
    //FragColor = blend_overlay(texel, blend_texel) * 0.5;
    //FragColor = blend_add(texel, blend_texel);
    //FragColor = blend_overlay(texel, blend_texel, 0.5);
    FragColor = blend_merge(texel, blend_texel, 0.1);
}
