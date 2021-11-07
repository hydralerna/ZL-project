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

uniform sampler2D sol_texture; // The main input texture (the screen.)
uniform sampler2D palette; // The palette texture.
//palette = "shaders/palette.png";
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;
uniform float shift; // The shift amount on the palette texture.
#define shift 1
uniform float screenScale; // The current scale of the screen. (1x, 2x, etc)
#define screenScale 1
uniform vec2 sol_input_size; // The size of the core game screen (for example: 320 x 240)

 
void main() {
    // The size of the game window.
    vec2 screenSizeScaled = screenScale * sol_input_size;
    // The pixel coordinate being operated on.
    vec2 pixpos = sol_vtex_coord.xy;
 
    // Get dither pixel
    vec2 overlayCoord = floor(sol_vtex_coord.xy / screenScale);
    // Get 1 or 0 based on the pixel location.
    float overlayPixelColor = mod(overlayCoord.x + overlayCoord.y, 2);
    // Dither is black and white every other pixel.
    vec4 overlayPixel = vec4(overlayPixelColor, overlayPixelColor, overlayPixelColor, 1);
  
    // Get base color.
    vec4 pixcol = COMPAT_TEXTURE(sol_texture, pixpos);
 
    // Mix dither texture.
    pixcol = mix(pixcol, overlayPixel, 0.1);
 
    // Determine the brightness of the pixel in a dumb way.
    //float gray = (pixcol.r + pixcol.g + pixcol.b) / 3;
    float colorMax = max(max(pixcol.r,pixcol.g), pixcol.b);
    float colorMin = min(min(pixcol.r,pixcol.g), pixcol.b);
    //float luminance = (colorMax + colorMin) / 2;
    float gray = round((pixcol.r + pixcol.g + pixcol.b + colorMax + colorMin) / 5);

    // Round it to the nearest 0.25.
    //gray = round(gray / 0.25) * 0.25;
 
    // Map the palette to the pixel based on the brightness and shift.
    //pixcol = COMPAT_TEXTURE(palette, vec2(gray, shift));
    pixcol = COMPAT_TEXTURE(palette, vec2(gray, shift));
 
    // Multiply through the gl_Color for final output.
    FragColor = pixcol * sol_vcolor;
}