// GLSL shader autogenerated by cg2glsl.py.
#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif
vec4 _oPosition1;
vec4 _r0009;
COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 TEX0;
 
uniform mat4 MVPMatrix;
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
void main()
{
    vec2 _oTex;
    _r0009 = VertexCoord.x*MVPMatrix[0];
    _r0009 = _r0009 + VertexCoord.y*MVPMatrix[1];
    _r0009 = _r0009 + VertexCoord.z*MVPMatrix[2];
    _r0009 = _r0009 + VertexCoord.w*MVPMatrix[3];
    _oPosition1 = _r0009;
    _oTex = TexCoord.xy;
    gl_Position = _r0009;
    TEX0.xy = TexCoord.xy;
} 
#elif defined(FRAGMENT)

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
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif
vec4 _ret_0;
vec3 _TMP7;
float _TMP6;
float _TMP5;
float _TMP4;
float _TMP3;
vec4 _TMP0;
uniform sampler2D Texture;
vec3 _TMP32;
COMPAT_VARYING vec4 TEX0;
 
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
void main()
{
    vec3 _res;
    _TMP0 = COMPAT_TEXTURE(Texture, TEX0.xy);
    _TMP3 = dot(_TMP0.xyz, vec3( 2.12599993E-01, 7.15200007E-01, 7.22000003E-02));
    _res = vec3(_TMP3, _TMP3, _TMP3) + (_TMP0.xyz - vec3(_TMP3, _TMP3, _TMP3));
    _TMP4 = pow(_res.x, 1.13636363E+00);
    _TMP5 = pow(_res.y, 1.13636363E+00);
    _TMP6 = pow(_res.z, 1.13636363E+00);
    _res = vec3(_TMP4, _TMP5, _TMP6);
    _TMP7 = min(vec3( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _res);
    _TMP32 = max(vec3( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP7);
    _ret_0 = vec4(_TMP32.x, _TMP32.y, _TMP32.z, 1.00000000E+00);
    FragColor = _ret_0;
    return;
} 
#endif
