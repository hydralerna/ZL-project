// Original script named "Index Palette Shader" by Kyle Pulver (http://kpulv.com/368/Index_Palette_Shader/).
// Shader based off of Dan Fessler's HD Index Painting tutorial.
// Script adapted by froggy77 for Solarus Game Engine. Corrected by Llamazing.
// 
// 
// The idea is to take a normal image and render it with an extremely limited palette. Essentially it's like a game boy shader.
// 
// The "shift" uniform in the shader determines the Y coordinate to sample the palette on. A shift of 0 will sample the top most Y, and a shift of 1 will sample the bottom most. You can use this to dynamically change the palette during the game.
//
// The shader needs to have the "screenScale" uniform set to the current scale of the screen. This will make sure that the pixel size is corrected for the dither.
//
// To make the noise change every update the "offset" value should be set to a random float 0 - 1 every update.



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
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;
uniform float shift; // The shift amount on the palette texture.
uniform float screenScale; // The current scale of the screen. (1x, 2x, etc)
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
    float gray = (pixcol.r + pixcol.g + pixcol.b) / 3;


    float colorMax = max(max(pixcol.r,pixcol.g), pixcol.b);
    float colorMin = min(min(pixcol.r,pixcol.g), pixcol.b);
    float luminance = (colorMax + colorMin) / 2;

    // Round it to the nearest 0.25.
    gray = round(gray / 0.25) * 0.25;

    float test = (gray + luminance) / 2;
 
    // Map the palette to the pixel based on the brightness and shift.
    //pixcol = COMPAT_TEXTURE(palette, vec2(gray, shift));
    pixcol = COMPAT_TEXTURE(palette, vec2(gray, shift));
 
    // Multiply through the gl_Color for final output.
    FragColor = pixcol * sol_vcolor;
}