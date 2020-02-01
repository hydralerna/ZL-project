// Original script named "Index Palette Shader" by Kyle Pulver (http://kpulv.com/368/Index_Palette_Shader/).
// Shader based off of Dan Fessler's HD Index Painting tutorial.
// Script adapted by froggy77 for Solarus Game Engine.
// 
// 
// The idea is to take a normal image and render it with an extremely limited palette. Essentially it's like a game boy shader, and with the help of a dither map texture it actually creates the illusion that there are more colors than there actually are.
// 
// The "shift" uniform in the shader determines the Y coordinate to sample the palette on. A shift of 0 will sample the top most Y, and a shift of 1 will sample the bottom most. You can use this to dynamically change the palette during the game.
//
// The shader needs to have the "screenScale" uniform set to the current scale of the screen. This will make sure that the pixel size is corrected for the dither and the noise. The shader also needs to know the "screenSize" in order for the noise pixels to be the correct size. You can also just set the "noiseAlpha" to 0 if you don't want any of that stuff to show up.
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
uniform float offset; // The offset for the random noise generation.
uniform float screenScale; // The current scale of the screen. (1x, 2x, etc)
uniform vec2 sol_input_size; // The size of the core game screen (for example: 320 x 240)
uniform float noiseAlpha; // The amount of alpha the noise should have.
 
// A weird way to generate a random number with a vec2 seed.
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
 
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
 
    // Scale the frag position to match the screen scale
    vec2 scaledpos = floor(pixpos * screenSizeScaled);
    // Adjust the position based on the scale of the screen.
    scaledpos -= mod(scaledpos, screenScale);
    // Convert back to 0 - 1 coordinate space.
    scaledpos /= screenSizeScaled;
 
    // Get base color.
    vec4 pixcol = COMPAT_TEXTURE(sol_texture, pixpos);
 
    // Mix dither texture.
    pixcol = mix(pixcol, overlayPixel, 0.1);
 
    // Determine the brightness of the pixel in a dumb way.
    float gray = (pixcol.r + pixcol.g + pixcol.b) / 3;
 
    // Round it to the nearest 0.25.
    gray = round(gray / 0.25) * 0.25;
 
    // Add some noise.
    gray += (rand(scaledpos + offset) * 2 - 1) * noiseAlpha;
 
    // Map the palette to the pixel based on the brightness and shift.
    pixcol = COMPAT_TEXTURE(palette, vec2(gray, shift));
 
    // Multiply through the gl_Color for final output.
    FragColor = pixcol * sol_vcolor;
}