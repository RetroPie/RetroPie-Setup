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
COMPAT_VARYING     vec4 _t7;
COMPAT_VARYING     vec4 _t6;
COMPAT_VARYING     vec4 _t5;
COMPAT_VARYING     vec4 _t4;
COMPAT_VARYING     vec4 _t3;
COMPAT_VARYING     vec4 _t2;
COMPAT_VARYING     vec4 _t1;
COMPAT_VARYING     vec2 _texCoord2;
COMPAT_VARYING     vec4 _color1;
COMPAT_VARYING     vec4 _position1;
struct input_dummy {
    vec2 _video_size;
    vec2 _texture_size;
    vec2 _output_dummy_size;
};
struct out_vertex {
    vec4 _position1;
    vec4 _color1;
    vec2 _texCoord2;
    vec4 _t1;
    vec4 _t2;
    vec4 _t3;
    vec4 _t4;
    vec4 _t5;
    vec4 _t6;
    vec4 _t7;
};
out_vertex _ret_0;
input_dummy _IN1;
vec4 _r0008;
COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec4 TEX1;
COMPAT_VARYING vec4 TEX2;
COMPAT_VARYING vec4 TEX3;
COMPAT_VARYING vec4 TEX4;
COMPAT_VARYING vec4 TEX5;
COMPAT_VARYING vec4 TEX6;
COMPAT_VARYING vec4 TEX7;
 
uniform mat4 MVPMatrix;
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
void main()
{
    out_vertex _OUT;
    vec2 _ps;
    vec2 _texCoord;
    _r0008 = VertexCoord.x*MVPMatrix[0];
    _r0008 = _r0008 + VertexCoord.y*MVPMatrix[1];
    _r0008 = _r0008 + VertexCoord.z*MVPMatrix[2];
    _r0008 = _r0008 + VertexCoord.w*MVPMatrix[3];
    _ps = vec2(1.00000000E+00/TextureSize.x, 1.00000000E+00/TextureSize.y);
    _texCoord = TexCoord.xy + vec2( 1.00000001E-07, 1.00000001E-07);
    _OUT._t1 = _texCoord.xxxy + vec4(-_ps.x, 0.00000000E+00, _ps.x, -2.00000000E+00*_ps.y);
    _OUT._t2 = _texCoord.xxxy + vec4(-_ps.x, 0.00000000E+00, _ps.x, -_ps.y);
    _OUT._t3 = _texCoord.xxxy + vec4(-_ps.x, 0.00000000E+00, _ps.x, 0.00000000E+00);
    _OUT._t4 = _texCoord.xxxy + vec4(-_ps.x, 0.00000000E+00, _ps.x, _ps.y);
    _OUT._t5 = _texCoord.xxxy + vec4(-_ps.x, 0.00000000E+00, _ps.x, 2.00000000E+00*_ps.y);
    _OUT._t6 = _texCoord.xyyy + vec4(-2.00000000E+00*_ps.x, -_ps.y, 0.00000000E+00, _ps.y);
    _OUT._t7 = _texCoord.xyyy + vec4(2.00000000E+00*_ps.x, -_ps.y, 0.00000000E+00, _ps.y);
    _ret_0._position1 = _r0008;
    _ret_0._color1 = COLOR;
    _ret_0._texCoord2 = _texCoord;
    _ret_0._t1 = _OUT._t1;
    _ret_0._t2 = _OUT._t2;
    _ret_0._t3 = _OUT._t3;
    _ret_0._t4 = _OUT._t4;
    _ret_0._t5 = _OUT._t5;
    _ret_0._t6 = _OUT._t6;
    _ret_0._t7 = _OUT._t7;
    gl_Position = _r0008;
    COL0 = COLOR;
    TEX0.xy = _texCoord;
    TEX1 = _OUT._t1;
    TEX2 = _OUT._t2;
    TEX3 = _OUT._t3;
    TEX4 = _OUT._t4;
    TEX5 = _OUT._t5;
    TEX6 = _OUT._t6;
    TEX7 = _OUT._t7;
    return;
    COL0 = _ret_0._color1;
    TEX0.xy = _ret_0._texCoord2;
    TEX1 = _ret_0._t1;
    TEX2 = _ret_0._t2;
    TEX3 = _ret_0._t3;
    TEX4 = _ret_0._t4;
    TEX5 = _ret_0._t5;
    TEX6 = _ret_0._t6;
    TEX7 = _ret_0._t7;
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
COMPAT_VARYING     vec4 _t7;
COMPAT_VARYING     vec4 _t6;
COMPAT_VARYING     vec4 _t5;
COMPAT_VARYING     vec4 _t4;
COMPAT_VARYING     vec4 _t3;
COMPAT_VARYING     vec4 _t2;
COMPAT_VARYING     vec4 _t1;
COMPAT_VARYING     vec2 _texCoord;
COMPAT_VARYING     vec4 _color;
struct input_dummy {
    vec2 _video_size;
    vec2 _texture_size;
    vec2 _output_dummy_size;
};
struct out_vertex {
    vec4 _color;
    vec2 _texCoord;
    vec4 _t1;
    vec4 _t2;
    vec4 _t3;
    vec4 _t4;
    vec4 _t5;
    vec4 _t6;
    vec4 _t7;
};
vec4 _ret_0;
vec3 _TMP44;
vec3 _TMP42;
vec3 _TMP40;
vec3 _TMP38;
vec3 _TMP43;
vec3 _TMP41;
vec3 _TMP39;
vec3 _TMP37;
vec4 _TMP36;
vec4 _TMP29;
vec4 _TMP28;
vec4 _TMP51;
bvec4 _TMP27;
bvec4 _TMP26;
bvec4 _TMP25;
bvec4 _TMP24;
bvec4 _TMP23;
bvec4 _TMP22;
bvec4 _TMP21;
vec4 _TMP20;
vec4 _TMP19;
vec4 _TMP18;
vec4 _TMP17;
vec4 _TMP16;
vec4 _TMP15;
vec4 _TMP14;
vec4 _TMP13;
vec4 _TMP12;
vec4 _TMP11;
vec4 _TMP10;
vec4 _TMP9;
vec4 _TMP8;
vec4 _TMP7;
vec4 _TMP6;
vec4 _TMP5;
vec4 _TMP4;
vec4 _TMP3;
vec4 _TMP2;
vec4 _TMP1;
vec4 _TMP0;
uniform sampler2D Texture;
input_dummy _IN1;
vec2 _x0066;
vec4 _r0110;
vec4 _r0120;
vec4 _r0130;
vec4 _r0140;
vec4 _r0150;
vec4 _r0160;
vec4 _TMP171;
vec4 _a0174;
vec4 _TMP177;
vec4 _a0180;
vec4 _TMP183;
vec4 _a0186;
vec4 _TMP189;
vec4 _a0192;
vec4 _TMP195;
vec4 _a0198;
vec4 _TMP201;
vec4 _a0204;
vec4 _TMP207;
vec4 _a0210;
vec4 _x0212;
vec4 _TMP213;
vec4 _x0220;
vec4 _TMP221;
vec4 _x0228;
vec4 _TMP229;
vec4 _TMP237;
vec4 _a0240;
vec4 _TMP241;
vec4 _a0244;
vec4 _TMP245;
vec4 _a0248;
vec4 _TMP249;
vec4 _a0252;
vec4 _TMP253;
vec4 _a0256;
vec4 _TMP259;
vec4 _a0262;
vec4 _TMP263;
vec4 _a0266;
vec4 _TMP267;
vec4 _a0270;
vec4 _TMP271;
vec4 _a0274;
vec4 _TMP275;
vec4 _a0278;
vec4 _TMP279;
vec4 _a0282;
vec4 _TMP283;
vec4 _a0286;
vec4 _TMP287;
vec4 _a0290;
vec4 _TMP291;
vec4 _a0294;
vec4 _TMP295;
vec4 _a0298;
vec4 _TMP299;
vec4 _a0302;
float _t0308;
float _t0312;
float _t0316;
float _t0320;
vec4 _r0324;
vec4 _TMP333;
vec4 _a0336;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec4 TEX1;
COMPAT_VARYING vec4 TEX2;
COMPAT_VARYING vec4 TEX3;
COMPAT_VARYING vec4 TEX4;
COMPAT_VARYING vec4 TEX5;
COMPAT_VARYING vec4 TEX6;
COMPAT_VARYING vec4 TEX7;
 
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
void main()
{
    bvec4 _edr;
    bvec4 _edr_left;
    bvec4 _edr_up;
    bvec4 _px;
    bvec4 _interp_restriction_lv1;
    bvec4 _interp_restriction_lv2_left;
    bvec4 _interp_restriction_lv2_up;
    vec4 _fx;
    vec4 _fx_left;
    vec4 _fx_up;
    vec2 _fp;
    vec4 _fx45;
    vec4 _fx30;
    vec4 _fx60;
    vec4 _maximo;
    vec3 _res;
    float _mx;
    _x0066 = TEX0.xy*TextureSize;
    _fp = fract(_x0066);
    _TMP0 = COMPAT_TEXTURE(Texture, TEX1.xw);
    _TMP1 = COMPAT_TEXTURE(Texture, TEX1.yw);
    _TMP2 = COMPAT_TEXTURE(Texture, TEX1.zw);
    _TMP3 = COMPAT_TEXTURE(Texture, TEX2.xw);
    _TMP4 = COMPAT_TEXTURE(Texture, TEX2.yw);
    _TMP5 = COMPAT_TEXTURE(Texture, TEX2.zw);
    _TMP6 = COMPAT_TEXTURE(Texture, TEX3.xw);
    _TMP7 = COMPAT_TEXTURE(Texture, TEX3.yw);
    _TMP8 = COMPAT_TEXTURE(Texture, TEX3.zw);
    _TMP9 = COMPAT_TEXTURE(Texture, TEX4.xw);
    _TMP10 = COMPAT_TEXTURE(Texture, TEX4.yw);
    _TMP11 = COMPAT_TEXTURE(Texture, TEX4.zw);
    _TMP12 = COMPAT_TEXTURE(Texture, TEX5.xw);
    _TMP13 = COMPAT_TEXTURE(Texture, TEX5.yw);
    _TMP14 = COMPAT_TEXTURE(Texture, TEX5.zw);
    _TMP15 = COMPAT_TEXTURE(Texture, TEX6.xy);
    _TMP16 = COMPAT_TEXTURE(Texture, TEX6.xz);
    _TMP17 = COMPAT_TEXTURE(Texture, TEX6.xw);
    _TMP18 = COMPAT_TEXTURE(Texture, TEX7.xy);
    _TMP19 = COMPAT_TEXTURE(Texture, TEX7.xz);
    _TMP20 = COMPAT_TEXTURE(Texture, TEX7.xw);
    _r0110.x = dot(_TMP4.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0110.y = dot(_TMP6.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0110.z = dot(_TMP10.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0110.w = dot(_TMP8.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0120.x = dot(_TMP5.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0120.y = dot(_TMP3.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0120.z = dot(_TMP9.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0120.w = dot(_TMP11.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0130.x = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0130.y = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0130.z = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0130.w = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0140.x = dot(_TMP20.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0140.y = dot(_TMP2.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0140.z = dot(_TMP15.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0140.w = dot(_TMP12.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0150.x = dot(_TMP14.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0150.y = dot(_TMP18.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0150.z = dot(_TMP0.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0150.w = dot(_TMP17.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0160.x = dot(_TMP13.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0160.y = dot(_TMP19.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0160.z = dot(_TMP1.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0160.w = dot(_TMP16.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _fx = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 1.00000000E+00, 1.00000000E+00, -1.00000000E+00, -1.00000000E+00)*_fp.x;
    _fx_left = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 5.00000000E-01, 2.00000000E+00, -5.00000000E-01, -2.00000000E+00)*_fp.x;
    _fx_up = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 2.00000000E+00, 5.00000000E-01, -2.00000000E+00, -5.00000000E-01)*_fp.x;
    _a0174 = _r0110.wxyz - _r0110;
    _TMP171 = abs(_a0174);
    _TMP21 = bvec4(_TMP171.x < 1.50000000E+01, _TMP171.y < 1.50000000E+01, _TMP171.z < 1.50000000E+01, _TMP171.w < 1.50000000E+01);
    _a0180 = _r0110.zwxy - _r0110.yzwx;
    _TMP177 = abs(_a0180);
    _TMP22 = bvec4(_TMP177.x < 1.50000000E+01, _TMP177.y < 1.50000000E+01, _TMP177.z < 1.50000000E+01, _TMP177.w < 1.50000000E+01);
    _a0186 = _r0130 - _r0120.wxyz;
    _TMP183 = abs(_a0186);
    _TMP23 = bvec4(_TMP183.x < 1.50000000E+01, _TMP183.y < 1.50000000E+01, _TMP183.z < 1.50000000E+01, _TMP183.w < 1.50000000E+01);
    _a0192 = _r0110.wxyz - _r0140;
    _TMP189 = abs(_a0192);
    _TMP24 = bvec4(_TMP189.x < 1.50000000E+01, _TMP189.y < 1.50000000E+01, _TMP189.z < 1.50000000E+01, _TMP189.w < 1.50000000E+01);
    _a0198 = _r0110.zwxy - _r0150;
    _TMP195 = abs(_a0198);
    _TMP25 = bvec4(_TMP195.x < 1.50000000E+01, _TMP195.y < 1.50000000E+01, _TMP195.z < 1.50000000E+01, _TMP195.w < 1.50000000E+01);
    _a0204 = _r0130 - _r0120.zwxy;
    _TMP201 = abs(_a0204);
    _TMP26 = bvec4(_TMP201.x < 1.50000000E+01, _TMP201.y < 1.50000000E+01, _TMP201.z < 1.50000000E+01, _TMP201.w < 1.50000000E+01);
    _a0210 = _r0130 - _r0120;
    _TMP207 = abs(_a0210);
    _TMP27 = bvec4(_TMP207.x < 1.50000000E+01, _TMP207.y < 1.50000000E+01, _TMP207.z < 1.50000000E+01, _TMP207.w < 1.50000000E+01);
    _interp_restriction_lv1 = bvec4(_r0130.x != _r0110.w && _r0130.x != _r0110.z && (!_TMP21.x && !_TMP22.x || _TMP23.x && !_TMP24.x && !_TMP25.x || _TMP26.x || _TMP27.x), _r0130.y != _r0110.x && _r0130.y != _r0110.w && (!_TMP21.y && !_TMP22.y || _TMP23.y && !_TMP24.y && !_TMP25.y || _TMP26.y || _TMP27.y), _r0130.z != _r0110.y && _r0130.z != _r0110.x && (!_TMP21.z && !_TMP22.z || _TMP23.z && !_TMP24.z && !_TMP25.z || _TMP26.z || _TMP27.z), _r0130.w != _r0110.z && _r0130.w != _r0110.y && (!_TMP21.w && !_TMP22.w || _TMP23.w && !_TMP24.w && !_TMP25.w || _TMP26.w || _TMP27.w));
    _interp_restriction_lv2_left = bvec4(_r0130.x != _r0120.z && _r0110.y != _r0120.z, _r0130.y != _r0120.w && _r0110.z != _r0120.w, _r0130.z != _r0120.x && _r0110.w != _r0120.x, _r0130.w != _r0120.y && _r0110.x != _r0120.y);
    _interp_restriction_lv2_up = bvec4(_r0130.x != _r0120.x && _r0110.x != _r0120.x, _r0130.y != _r0120.y && _r0110.y != _r0120.y, _r0130.z != _r0120.z && _r0110.z != _r0120.z, _r0130.w != _r0120.w && _r0110.w != _r0120.w);
    _x0212 = ((_fx + vec4( 3.33333343E-01, 3.33333343E-01, 3.33333343E-01, 3.33333343E-01)) - vec4( 1.50000000E+00, 5.00000000E-01, -5.00000000E-01, 5.00000000E-01))/vec4( 6.66666687E-01, 6.66666687E-01, 6.66666687E-01, 6.66666687E-01);
    _TMP51 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0212);
    _TMP213 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP51);
    _x0220 = ((_fx_left + vec4( 1.66666672E-01, 3.33333343E-01, 1.66666672E-01, 3.33333343E-01)) - vec4( 1.00000000E+00, 1.00000000E+00, -5.00000000E-01, 0.00000000E+00))/vec4( 3.33333343E-01, 6.66666687E-01, 3.33333343E-01, 6.66666687E-01);
    _TMP51 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0220);
    _TMP221 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP51);
    _x0228 = ((_fx_up + vec4( 3.33333343E-01, 1.66666672E-01, 3.33333343E-01, 1.66666672E-01)) - vec4( 2.00000000E+00, 0.00000000E+00, -1.00000000E+00, 5.00000000E-01))/vec4( 6.66666687E-01, 3.33333343E-01, 6.66666687E-01, 3.33333343E-01);
    _TMP51 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0228);
    _TMP229 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP51);
    _a0240 = _r0130 - _r0120;
    _TMP237 = abs(_a0240);
    _a0244 = _r0130 - _r0120.zwxy;
    _TMP241 = abs(_a0244);
    _a0248 = _r0120.wxyz - _r0160;
    _TMP245 = abs(_a0248);
    _a0252 = _r0120.wxyz - _r0160.yzwx;
    _TMP249 = abs(_a0252);
    _a0256 = _r0110.zwxy - _r0110.wxyz;
    _TMP253 = abs(_a0256);
    _TMP28 = _TMP237 + _TMP241 + _TMP245 + _TMP249 + 4.00000000E+00*_TMP253;
    _a0262 = _r0110.zwxy - _r0110.yzwx;
    _TMP259 = abs(_a0262);
    _a0266 = _r0110.zwxy - _r0150;
    _TMP263 = abs(_a0266);
    _a0270 = _r0110.wxyz - _r0140;
    _TMP267 = abs(_a0270);
    _a0274 = _r0110.wxyz - _r0110;
    _TMP271 = abs(_a0274);
    _a0278 = _r0130 - _r0120.wxyz;
    _TMP275 = abs(_a0278);
    _TMP29 = _TMP259 + _TMP263 + _TMP267 + _TMP271 + 4.00000000E+00*_TMP275;
    _edr = bvec4(_TMP28.x < _TMP29.x && _interp_restriction_lv1.x, _TMP28.y < _TMP29.y && _interp_restriction_lv1.y, _TMP28.z < _TMP29.z && _interp_restriction_lv1.z, _TMP28.w < _TMP29.w && _interp_restriction_lv1.w);
    _a0282 = _r0110.wxyz - _r0120.zwxy;
    _TMP279 = abs(_a0282);
    _a0286 = _r0110.zwxy - _r0120;
    _TMP283 = abs(_a0286);
    _edr_left = bvec4((2.00000000E+00*_TMP279).x <= _TMP283.x && _interp_restriction_lv2_left.x && _edr.x, (2.00000000E+00*_TMP279).y <= _TMP283.y && _interp_restriction_lv2_left.y && _edr.y, (2.00000000E+00*_TMP279).z <= _TMP283.z && _interp_restriction_lv2_left.z && _edr.z, (2.00000000E+00*_TMP279).w <= _TMP283.w && _interp_restriction_lv2_left.w && _edr.w);
    _a0290 = _r0110.wxyz - _r0120.zwxy;
    _TMP287 = abs(_a0290);
    _a0294 = _r0110.zwxy - _r0120;
    _TMP291 = abs(_a0294);
    _edr_up = bvec4(_TMP287.x >= (2.00000000E+00*_TMP291).x && _interp_restriction_lv2_up.x && _edr.x, _TMP287.y >= (2.00000000E+00*_TMP291).y && _interp_restriction_lv2_up.y && _edr.y, _TMP287.z >= (2.00000000E+00*_TMP291).z && _interp_restriction_lv2_up.z && _edr.z, _TMP287.w >= (2.00000000E+00*_TMP291).w && _interp_restriction_lv2_up.w && _edr.w);
    _fx45 = vec4(float(_edr.x), float(_edr.y), float(_edr.z), float(_edr.w))*_TMP213;
    _fx30 = vec4(float(_edr_left.x), float(_edr_left.y), float(_edr_left.z), float(_edr_left.w))*_TMP221;
    _fx60 = vec4(float(_edr_up.x), float(_edr_up.y), float(_edr_up.z), float(_edr_up.w))*_TMP229;
    _a0298 = _r0130 - _r0110.wxyz;
    _TMP295 = abs(_a0298);
    _a0302 = _r0130 - _r0110.zwxy;
    _TMP299 = abs(_a0302);
    _px = bvec4(_TMP295.x <= _TMP299.x, _TMP295.y <= _TMP299.y, _TMP295.z <= _TMP299.z, _TMP295.w <= _TMP299.w);
    _TMP36 = max(_fx30, _fx60);
    _maximo = max(_TMP36, _fx45);
    _t0308 = float(_px.x);
    _TMP37 = _TMP10.xyz + _t0308*(_TMP8.xyz - _TMP10.xyz);
    _TMP38 = _TMP7.xyz + _maximo.x*(_TMP37 - _TMP7.xyz);
    _t0312 = float(_px.y);
    _TMP39 = _TMP8.xyz + _t0312*(_TMP4.xyz - _TMP8.xyz);
    _TMP40 = _TMP7.xyz + _maximo.y*(_TMP39 - _TMP7.xyz);
    _t0316 = float(_px.z);
    _TMP41 = _TMP4.xyz + _t0316*(_TMP6.xyz - _TMP4.xyz);
    _TMP42 = _TMP7.xyz + _maximo.z*(_TMP41 - _TMP7.xyz);
    _t0320 = float(_px.w);
    _TMP43 = _TMP6.xyz + _t0320*(_TMP10.xyz - _TMP6.xyz);
    _TMP44 = _TMP7.xyz + _maximo.w*(_TMP43 - _TMP7.xyz);
    _r0324.x = dot(_TMP38, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0324.y = dot(_TMP40, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0324.z = dot(_TMP42, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0324.w = dot(_TMP44, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _a0336 = _r0324 - _r0130;
    _TMP333 = abs(_a0336);
    _res = _TMP38;
    _mx = _TMP333.x;
    if (_TMP333.y > _TMP333.x) { 
        _res = _TMP40;
        _mx = _TMP333.y;
    } 
    if (_TMP333.z > _mx) { 
        _res = _TMP42;
        _mx = _TMP333.z;
    } 
    if (_TMP333.w > _mx) { 
        _res = _TMP44;
    } 
    _ret_0 = vec4(_res.x, _res.y, _res.z, 1.00000000E+00);
    FragColor = _ret_0;
    return;
} 
#endif
