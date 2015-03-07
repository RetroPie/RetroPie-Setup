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
COMPAT_VARYING     float _frame_rotation;
struct input_dummy {
    vec2 _video_size;
    vec2 _texture_size;
    vec2 _output_dummy_size;
    float _frame_count;
    float _frame_direction;
    float _frame_rotation;
};
vec4 _oPosition1;
vec4 _r0006;
COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_VARYING vec4 COL0;
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
    vec4 _oColor;
    vec2 _oTexCoord;
    _r0006 = VertexCoord.x*MVPMatrix[0];
    _r0006 = _r0006 + VertexCoord.y*MVPMatrix[1];
    _r0006 = _r0006 + VertexCoord.z*MVPMatrix[2];
    _r0006 = _r0006 + VertexCoord.w*MVPMatrix[3];
    _oPosition1 = _r0006;
    _oColor = COLOR;
    _oTexCoord = TexCoord.xy;
    gl_Position = _r0006;
    COL0 = COLOR;
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
COMPAT_VARYING     float _frame_rotation;
struct input_dummy {
    vec2 _video_size;
    vec2 _texture_size;
    vec2 _output_dummy_size;
    float _frame_count;
    float _frame_direction;
    float _frame_rotation;
};
vec4 _ret_0;
float _TMP9;
float _TMP8;
float _TMP7;
float _TMP6;
vec4 _TMP5;
float _TMP13;
float _TMP12;
float _TMP11;
float _TMP10;
vec4 _TMP3;
vec4 _TMP2;
vec4 _TMP1;
vec4 _TMP0;
uniform sampler2D Texture;
input_dummy _IN1;
vec2 _c0029;
vec2 _c0041;
vec2 _c0043;
vec4 _a0045;
float _c0055;
float _a0057;
vec4 _a0075;
COMPAT_VARYING vec4 TEX0;
 
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
void main()
{
    vec4 _res;
    vec4 _color;
    float _y;
    _TMP0 = COMPAT_TEXTURE(Texture, TEX0.xy);
    _TMP6 = pow(_TMP0.x, 2.20000005E+00);
    _TMP7 = pow(_TMP0.y, 2.20000005E+00);
    _TMP8 = pow(_TMP0.z, 2.20000005E+00);
    _TMP9 = pow(_TMP0.w, 2.20000005E+00);
    _res = vec4(_TMP6, _TMP7, _TMP8, _TMP9);
    if (InputSize.y > 4.00000000E+02) { 
        _y = TextureSize.y*TEX0.y + float(FrameCount);
        _c0029 = TEX0.xy + vec2(0.00000000E+00, (1.00000000E+00/TextureSize).y);
        _TMP1 = COMPAT_TEXTURE(Texture, _c0029);
        _TMP6 = pow(_TMP1.x, 2.20000005E+00);
        _TMP7 = pow(_TMP1.y, 2.20000005E+00);
        _TMP8 = pow(_TMP1.z, 2.20000005E+00);
        _TMP9 = pow(_TMP1.w, 2.20000005E+00);
        _res = vec4(_TMP6, _TMP7, _TMP8, _TMP9);
        _c0041 = TEX0.xy - vec2(0.00000000E+00, 5.00000000E-01*(1.00000000E+00/TextureSize).y);
        _TMP2 = COMPAT_TEXTURE(Texture, _c0041);
        _c0043 = TEX0.xy + vec2(0.00000000E+00, 5.00000000E-01*(1.00000000E+00/TextureSize).y);
        _TMP3 = COMPAT_TEXTURE(Texture, _c0043);
        _a0045 = (_TMP2 + _TMP3)/2.00000000E+00;
        _TMP6 = pow(_a0045.x, 2.20000005E+00);
        _TMP7 = pow(_a0045.y, 2.20000005E+00);
        _TMP8 = pow(_a0045.z, 2.20000005E+00);
        _TMP9 = pow(_a0045.w, 2.20000005E+00);
        _color = vec4(_TMP6, _TMP7, _TMP8, _TMP9);
    } else {
        _y = 2.00000000E+00*TextureSize.y*TEX0.y;
        _color = _res;
    } 
    _a0057 = _y/2.00000000E+00;
    _TMP10 = abs(_a0057);
    _TMP11 = fract(_TMP10);
    _TMP12 = abs(2.00000000E+00);
    _c0055 = _TMP11*_TMP12;
    if (_y < 0.00000000E+00) { 
        _TMP13 = -_c0055;
    } else {
        _TMP13 = _c0055;
    } 
    if (_TMP13 > 9.99989986E-01) { 
    } else {
        _TMP5 = COMPAT_TEXTURE(Texture, TEX0.xy);
        _TMP6 = pow(_TMP5.x, 2.20000005E+00);
        _TMP7 = pow(_TMP5.y, 2.20000005E+00);
        _TMP8 = pow(_TMP5.z, 2.20000005E+00);
        _TMP9 = pow(_TMP5.w, 2.20000005E+00);
        _res = vec4(_TMP6, _TMP7, _TMP8, _TMP9);
    } 
    _a0075 = (_res + _color)/2.00000000E+00;
    _TMP6 = pow(_a0075.x, 4.54545438E-01);
    _TMP7 = pow(_a0075.y, 4.54545438E-01);
    _TMP8 = pow(_a0075.z, 4.54545438E-01);
    _TMP9 = pow(_a0075.w, 4.54545438E-01);
    _ret_0 = vec4(_TMP6, _TMP7, _TMP8, _TMP9);
    FragColor = _ret_0;
    return;
} 
#endif
