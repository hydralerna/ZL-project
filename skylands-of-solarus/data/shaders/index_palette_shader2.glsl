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


// The input texture containing the original image. The main input texture (the screen.)
//uniform sampler2D tex;
uniform sampler2D sol_texture;

// The size of the core game screen (for example: 320 x 240)
uniform vec2 sol_input_size;

// The current scale of the screen. (1x, 2x, etc)
uniform float screenScale; 
#define screenScale 1

// The texel size of the input texture
// uniform vec2 tex_size;
// The size of the game window.
vec2 screenSizeScaled = screenScale * sol_input_size;

// The image containing the palette colors
uniform sampler2D palette;

// The size of the palette image in pixels
uniform vec2 palette_size;
#define palette_size 4

// The number of colors in the palette
uniform int palette_colors;
#define palette_colors 4

// The color to use when a pixel cannot be matched to a palette color
// uniform vec4 fallback_color;
uniform vec4 fallback_color = vec4(1.0, 0.0, 0.0, 1.0);


// The output fragment color
vec4 color;

void main() {
  // Calculate the texel coordinates of the current fragment
  // vec2 texel = gl_FragCoord.xy / tex_size;
  vec2 texel = gl_FragCoord.xy / screenSizeScaled;

  // Sample the color of the current fragment from the input texture
  // vec4 original_color = texture(tex, texel);
  vec4 original_color = texture(sol_texture, texel);

  // Check each color in the palette to see if it matches the original color
  for (int i = 0; i < palette_colors; i++) {
    // Calculate the texel coordinates of the current palette color
    vec2 palette_texel = vec2(float(i) / float(palette_colors), 0.5) / palette_size;

    // Sample the color of the current palette color
    vec4 palette_color = texture(palette, palette_texel);

    // If the palette color matches the original color, use it as the output color
    if (palette_color == original_color) {
      color = palette_color;
      return;
    }
  }

  // If no matching palette color was found, use the fallback color as the output color
  color = fallback_color;
}
