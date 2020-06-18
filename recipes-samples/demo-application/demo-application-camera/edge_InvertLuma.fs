/*
 * Original shader from: https://www.shadertoy.com/view/MdGXDy
 *
 * Automatically converted by st-to-gstsh script
 * See: https://github.com/jolivain/gst-shadertoy
 */

#ifdef GL_ES
precision mediump float;
#endif

// gst-glshader uniforms
uniform float time;
uniform float width;
uniform float height;
uniform sampler2D tex;

// shadertoy globals
float iGlobalTime = 0.0;
float iTime = 0.0;
vec3  iResolution = vec3(0.0);
vec3  iMouse = vec3(0.0);
vec4  iDate = vec4(0.0);

#define iChannel0 tex
#define texture(t,c) texture2D(t,c)
#if (__VERSION__ < 300)
# define textureLod(s, uv, l) texture2D(s, uv)
#endif

// Protect gst-glshader names
#define time        gstemu_time
#define width       gstemu_width
#define height      gstemu_height

// --------[ Original ShaderToy begins here ]---------- //
const float gamma = 2.2;

float gamma2linear( float v )
{
    return pow( v, gamma );
}

float linear2gamma( float v )
{
    return pow( v, 1./gamma );
}

float min3( float a, float b, float c )
{
    return min( min( a, b ), c );
}

float max3( float a, float b, float c )
{
    return max( max( a, b ), c );
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 convertRGBtoHSL( vec3 col )
{
    float red   = col.r;
    float green = col.g;
    float blue  = col.b;

    float minc  = min3( col.r, col.g, col.b );
    float maxc  = max3( col.r, col.g, col.b );
    float delta = maxc - minc;

    float lum = (minc + maxc) * 0.5;
    float sat = 0.0;
    float hue = 0.0;

    if (lum > 0.0 && lum < 1.0) {
        float mul = (lum < 0.5)  ?  (lum)  :  (1.0-lum);
        sat = delta / (mul * 2.0);
    }

    vec3 masks = vec3(
        (maxc == red   && maxc != green) ? 1.0 : 0.0,
        (maxc == green && maxc != blue)  ? 1.0 : 0.0,
        (maxc == blue  && maxc != red)   ? 1.0 : 0.0
    );

    vec3 adds = vec3(
              ((green - blue ) / delta),
        2.0 + ((blue  - red  ) / delta),
        4.0 + ((red   - green) / delta)
    );

    float deltaGtz = (delta > 0.0) ? 1.0 : 0.0;

    hue += dot( adds, masks );
    hue *= deltaGtz;
    hue /= 6.0;

    if (hue < 0.0)
        hue += 1.0;

    return vec3( hue, sat, lum );
}

vec3 convertHSLtoRGB( vec3 col )
{
    const float onethird = 1.0 / 3.0;
    const float twothird = 2.0 / 3.0;
    const float rcpsixth = 6.0;

    float hue = col.x;
    float sat = col.y;
    float lum = col.z;

    vec3 xt = vec3(
        rcpsixth * (hue - twothird),
        0.0,
        rcpsixth * (1.0 - hue)
    );

    if (hue < twothird) {
        xt.r = 0.0;
        xt.g = rcpsixth * (twothird - hue);
        xt.b = rcpsixth * (hue      - onethird);
    } 

    if (hue < onethird) {
        xt.r = rcpsixth * (onethird - hue);
        xt.g = rcpsixth * hue;
        xt.b = 0.0;
    }

    xt = min( xt, 1.0 );

    float sat2   =  2.0 * sat;
    float satinv =  1.0 - sat;
    float luminv =  1.0 - lum;
    float lum2m1 = (2.0 * lum) - 1.0;
    vec3  ct     = (sat2 * xt) + satinv;

    vec3 rgb;
    if (lum >= 0.5)
         rgb = (luminv * ct) + lum2m1;
    else rgb =  lum    * ct;

    return rgb;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 sample = texture( iChannel0, uv ).rgb;
    
    vec3 s2 = convertRGBtoHSL( sample );
    
    //s2.b = gamma2linear( s2.b );
    s2.b = ( s2.b * -1.0 ) + 1.0;
    //s2.b = linear2gamma( s2.b  );
    
    vec3 s3 = convertHSLtoRGB( s2 );
	fragColor = vec4(s3, 1.0);
}
// --------[ Original ShaderToy ends here ]---------- //

#undef time
#undef width
#undef height

void main(void)
{
  iResolution = vec3(width, height, 0.0);
  iGlobalTime = time;
  iTime = time;
  iDate.w = time;

  mainImage(gl_FragColor, gl_FragCoord.xy);
}
