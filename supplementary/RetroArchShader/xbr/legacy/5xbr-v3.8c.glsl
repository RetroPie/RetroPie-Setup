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
COMPAT_VARYING     vec2 _texCoord11;
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
    vec2 _texCoord11;
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
    _ret_0._texCoord11 = _texCoord;
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
    TEX0.xy = _ret_0._texCoord11;
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
COMPAT_VARYING     vec2 _texCoord1;
COMPAT_VARYING     vec4 _color;
struct input_dummy {
    vec2 _video_size;
    vec2 _texture_size;
    vec2 _output_dummy_size;
};
struct out_vertex {
    vec4 _color;
    vec2 _texCoord1;
    vec4 _t1;
    vec4 _t2;
    vec4 _t3;
    vec4 _t4;
    vec4 _t5;
    vec4 _t6;
    vec4 _t7;
};
vec4 _ret_0;
vec3 _TMP48;
vec3 _TMP46;
vec3 _TMP44;
vec3 _TMP42;
vec3 _TMP47;
vec3 _TMP45;
vec3 _TMP43;
vec3 _TMP41;
vec4 _TMP40;
vec4 _TMP33;
vec4 _TMP32;
vec4 _TMP55;
bvec4 _TMP31;
bvec4 _TMP30;
bvec4 _TMP29;
bvec4 _TMP28;
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
vec2 _x0070;
vec4 _r0114;
vec4 _r0124;
vec4 _r0134;
vec4 _r0144;
vec4 _r0154;
vec4 _r0164;
vec4 _TMP175;
vec4 _a0178;
vec4 _TMP181;
vec4 _a0184;
vec4 _TMP187;
vec4 _a0190;
vec4 _TMP193;
vec4 _a0196;
vec4 _TMP199;
vec4 _a0202;
vec4 _TMP205;
vec4 _a0208;
vec4 _TMP211;
vec4 _a0214;
vec4 _TMP217;
vec4 _a0220;
vec4 _TMP223;
vec4 _a0226;
vec4 _TMP229;
vec4 _a0232;
vec4 _TMP235;
vec4 _a0238;
vec4 _x0240;
vec4 _TMP241;
vec4 _x0248;
vec4 _TMP249;
vec4 _x0256;
vec4 _TMP257;
vec4 _TMP265;
vec4 _a0268;
vec4 _TMP269;
vec4 _a0272;
vec4 _TMP273;
vec4 _a0276;
vec4 _TMP277;
vec4 _a0280;
vec4 _TMP281;
vec4 _a0284;
vec4 _TMP287;
vec4 _a0290;
vec4 _TMP291;
vec4 _a0294;
vec4 _TMP295;
vec4 _a0298;
vec4 _TMP299;
vec4 _a0302;
vec4 _TMP303;
vec4 _a0306;
vec4 _TMP307;
vec4 _a0310;
vec4 _TMP311;
vec4 _a0314;
vec4 _TMP315;
vec4 _a0318;
vec4 _TMP319;
vec4 _a0322;
vec4 _TMP323;
vec4 _a0326;
vec4 _TMP327;
vec4 _a0330;
float _t0336;
float _t0340;
float _t0344;
float _t0348;
vec4 _r0352;
vec4 _TMP361;
vec4 _a0364;
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
    _x0070 = TEX0.xy*TextureSize;
    _fp = fract(_x0070);
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
    _r0114.x = dot(_TMP4.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0114.y = dot(_TMP6.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0114.z = dot(_TMP10.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0114.w = dot(_TMP8.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0124.x = dot(_TMP5.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0124.y = dot(_TMP3.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0124.z = dot(_TMP9.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0124.w = dot(_TMP11.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0134.x = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0134.y = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0134.z = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0134.w = dot(_TMP7.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0144.x = dot(_TMP20.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0144.y = dot(_TMP2.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0144.z = dot(_TMP15.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0144.w = dot(_TMP12.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0154.x = dot(_TMP14.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0154.y = dot(_TMP18.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0154.z = dot(_TMP0.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0154.w = dot(_TMP17.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0164.x = dot(_TMP13.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0164.y = dot(_TMP19.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0164.z = dot(_TMP1.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0164.w = dot(_TMP16.xyz, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _fx = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 1.00000000E+00, 1.00000000E+00, -1.00000000E+00, -1.00000000E+00)*_fp.x;
    _fx_left = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 5.00000000E-01, 2.00000000E+00, -5.00000000E-01, -2.00000000E+00)*_fp.x;
    _fx_up = vec4( 1.00000000E+00, -1.00000000E+00, -1.00000000E+00, 1.00000000E+00)*_fp.y + vec4( 2.00000000E+00, 5.00000000E-01, -2.00000000E+00, -5.00000000E-01)*_fp.x;
    _a0178 = _r0114.wxyz - _r0114;
    _TMP175 = abs(_a0178);
    _TMP21 = bvec4(_TMP175.x < 1.50000000E+01, _TMP175.y < 1.50000000E+01, _TMP175.z < 1.50000000E+01, _TMP175.w < 1.50000000E+01);
    _a0184 = _r0114.wxyz - _r0124;
    _TMP181 = abs(_a0184);
    _TMP22 = bvec4(_TMP181.x < 1.50000000E+01, _TMP181.y < 1.50000000E+01, _TMP181.z < 1.50000000E+01, _TMP181.w < 1.50000000E+01);
    _a0190 = _r0114.zwxy - _r0114.yzwx;
    _TMP187 = abs(_a0190);
    _TMP23 = bvec4(_TMP187.x < 1.50000000E+01, _TMP187.y < 1.50000000E+01, _TMP187.z < 1.50000000E+01, _TMP187.w < 1.50000000E+01);
    _a0196 = _r0114.zwxy - _r0124.zwxy;
    _TMP193 = abs(_a0196);
    _TMP24 = bvec4(_TMP193.x < 1.50000000E+01, _TMP193.y < 1.50000000E+01, _TMP193.z < 1.50000000E+01, _TMP193.w < 1.50000000E+01);
    _a0202 = _r0134 - _r0124.wxyz;
    _TMP199 = abs(_a0202);
    _TMP25 = bvec4(_TMP199.x < 1.50000000E+01, _TMP199.y < 1.50000000E+01, _TMP199.z < 1.50000000E+01, _TMP199.w < 1.50000000E+01);
    _a0208 = _r0114.wxyz - _r0164.yzwx;
    _TMP205 = abs(_a0208);
    _TMP26 = bvec4(_TMP205.x < 1.50000000E+01, _TMP205.y < 1.50000000E+01, _TMP205.z < 1.50000000E+01, _TMP205.w < 1.50000000E+01);
    _a0214 = _r0114.wxyz - _r0144;
    _TMP211 = abs(_a0214);
    _TMP27 = bvec4(_TMP211.x < 1.50000000E+01, _TMP211.y < 1.50000000E+01, _TMP211.z < 1.50000000E+01, _TMP211.w < 1.50000000E+01);
    _a0220 = _r0114.zwxy - _r0164;
    _TMP217 = abs(_a0220);
    _TMP28 = bvec4(_TMP217.x < 1.50000000E+01, _TMP217.y < 1.50000000E+01, _TMP217.z < 1.50000000E+01, _TMP217.w < 1.50000000E+01);
    _a0226 = _r0114.zwxy - _r0154;
    _TMP223 = abs(_a0226);
    _TMP29 = bvec4(_TMP223.x < 1.50000000E+01, _TMP223.y < 1.50000000E+01, _TMP223.z < 1.50000000E+01, _TMP223.w < 1.50000000E+01);
    _a0232 = _r0134 - _r0124.zwxy;
    _TMP229 = abs(_a0232);
    _TMP30 = bvec4(_TMP229.x < 1.50000000E+01, _TMP229.y < 1.50000000E+01, _TMP229.z < 1.50000000E+01, _TMP229.w < 1.50000000E+01);
    _a0238 = _r0134 - _r0124;
    _TMP235 = abs(_a0238);
    _TMP31 = bvec4(_TMP235.x < 1.50000000E+01, _TMP235.y < 1.50000000E+01, _TMP235.z < 1.50000000E+01, _TMP235.w < 1.50000000E+01);
    _interp_restriction_lv1 = bvec4(_r0134.x != _r0114.w && _r0134.x != _r0114.z && (!_TMP21.x && !_TMP22.x || !_TMP23.x && !_TMP24.x || _TMP25.x && (!_TMP26.x && !_TMP27.x || !_TMP28.x && !_TMP29.x) || _TMP30.x || _TMP31.x), _r0134.y != _r0114.x && _r0134.y != _r0114.w && (!_TMP21.y && !_TMP22.y || !_TMP23.y && !_TMP24.y || _TMP25.y && (!_TMP26.y && !_TMP27.y || !_TMP28.y && !_TMP29.y) || _TMP30.y || _TMP31.y), _r0134.z != _r0114.y && _r0134.z != _r0114.x && (!_TMP21.z && !_TMP22.z || !_TMP23.z && !_TMP24.z || _TMP25.z && (!_TMP26.z && !_TMP27.z || !_TMP28.z && !_TMP29.z) || _TMP30.z || _TMP31.z), _r0134.w != _r0114.z && _r0134.w != _r0114.y && (!_TMP21.w && !_TMP22.w || !_TMP23.w && !_TMP24.w || _TMP25.w && (!_TMP26.w && !_TMP27.w || !_TMP28.w && !_TMP29.w) || _TMP30.w || _TMP31.w));
    _interp_restriction_lv2_left = bvec4(_r0134.x != _r0124.z && _r0114.y != _r0124.z, _r0134.y != _r0124.w && _r0114.z != _r0124.w, _r0134.z != _r0124.x && _r0114.w != _r0124.x, _r0134.w != _r0124.y && _r0114.x != _r0124.y);
    _interp_restriction_lv2_up = bvec4(_r0134.x != _r0124.x && _r0114.x != _r0124.x, _r0134.y != _r0124.y && _r0114.y != _r0124.y, _r0134.z != _r0124.z && _r0114.z != _r0124.z, _r0134.w != _r0124.w && _r0114.w != _r0124.w);
    _x0240 = ((_fx + vec4( 2.00000003E-01, 2.00000003E-01, 2.00000003E-01, 2.00000003E-01)) - vec4( 1.50000000E+00, 5.00000000E-01, -5.00000000E-01, 5.00000000E-01))/vec4( 4.00000006E-01, 4.00000006E-01, 4.00000006E-01, 4.00000006E-01);
    _TMP55 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0240);
    _TMP241 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP55);
    _x0248 = ((_fx_left + vec4( 1.00000001E-01, 2.00000003E-01, 1.00000001E-01, 2.00000003E-01)) - vec4( 1.00000000E+00, 1.00000000E+00, -5.00000000E-01, 0.00000000E+00))/vec4( 2.00000003E-01, 4.00000006E-01, 2.00000003E-01, 4.00000006E-01);
    _TMP55 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0248);
    _TMP249 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP55);
    _x0256 = ((_fx_up + vec4( 2.00000003E-01, 1.00000001E-01, 2.00000003E-01, 1.00000001E-01)) - vec4( 2.00000000E+00, 0.00000000E+00, -1.00000000E+00, 5.00000000E-01))/vec4( 4.00000006E-01, 2.00000003E-01, 4.00000006E-01, 2.00000003E-01);
    _TMP55 = min(vec4( 1.00000000E+00, 1.00000000E+00, 1.00000000E+00, 1.00000000E+00), _x0256);
    _TMP257 = max(vec4( 0.00000000E+00, 0.00000000E+00, 0.00000000E+00, 0.00000000E+00), _TMP55);
    _a0268 = _r0134 - _r0124;
    _TMP265 = abs(_a0268);
    _a0272 = _r0134 - _r0124.zwxy;
    _TMP269 = abs(_a0272);
    _a0276 = _r0124.wxyz - _r0164;
    _TMP273 = abs(_a0276);
    _a0280 = _r0124.wxyz - _r0164.yzwx;
    _TMP277 = abs(_a0280);
    _a0284 = _r0114.zwxy - _r0114.wxyz;
    _TMP281 = abs(_a0284);
    _TMP32 = _TMP265 + _TMP269 + _TMP273 + _TMP277 + 4.00000000E+00*_TMP281;
    _a0290 = _r0114.zwxy - _r0114.yzwx;
    _TMP287 = abs(_a0290);
    _a0294 = _r0114.zwxy - _r0154;
    _TMP291 = abs(_a0294);
    _a0298 = _r0114.wxyz - _r0144;
    _TMP295 = abs(_a0298);
    _a0302 = _r0114.wxyz - _r0114;
    _TMP299 = abs(_a0302);
    _a0306 = _r0134 - _r0124.wxyz;
    _TMP303 = abs(_a0306);
    _TMP33 = _TMP287 + _TMP291 + _TMP295 + _TMP299 + 4.00000000E+00*_TMP303;
    _edr = bvec4(_TMP32.x < _TMP33.x && _interp_restriction_lv1.x, _TMP32.y < _TMP33.y && _interp_restriction_lv1.y, _TMP32.z < _TMP33.z && _interp_restriction_lv1.z, _TMP32.w < _TMP33.w && _interp_restriction_lv1.w);
    _a0310 = _r0114.wxyz - _r0124.zwxy;
    _TMP307 = abs(_a0310);
    _a0314 = _r0114.zwxy - _r0124;
    _TMP311 = abs(_a0314);
    _edr_left = bvec4((2.00000000E+00*_TMP307).x <= _TMP311.x && _interp_restriction_lv2_left.x && _edr.x, (2.00000000E+00*_TMP307).y <= _TMP311.y && _interp_restriction_lv2_left.y && _edr.y, (2.00000000E+00*_TMP307).z <= _TMP311.z && _interp_restriction_lv2_left.z && _edr.z, (2.00000000E+00*_TMP307).w <= _TMP311.w && _interp_restriction_lv2_left.w && _edr.w);
    _a0318 = _r0114.wxyz - _r0124.zwxy;
    _TMP315 = abs(_a0318);
    _a0322 = _r0114.zwxy - _r0124;
    _TMP319 = abs(_a0322);
    _edr_up = bvec4(_TMP315.x >= (2.00000000E+00*_TMP319).x && _interp_restriction_lv2_up.x && _edr.x, _TMP315.y >= (2.00000000E+00*_TMP319).y && _interp_restriction_lv2_up.y && _edr.y, _TMP315.z >= (2.00000000E+00*_TMP319).z && _interp_restriction_lv2_up.z && _edr.z, _TMP315.w >= (2.00000000E+00*_TMP319).w && _interp_restriction_lv2_up.w && _edr.w);
    _fx45 = vec4(float(_edr.x), float(_edr.y), float(_edr.z), float(_edr.w))*_TMP241;
    _fx30 = vec4(float(_edr_left.x), float(_edr_left.y), float(_edr_left.z), float(_edr_left.w))*_TMP249;
    _fx60 = vec4(float(_edr_up.x), float(_edr_up.y), float(_edr_up.z), float(_edr_up.w))*_TMP257;
    _a0326 = _r0134 - _r0114.wxyz;
    _TMP323 = abs(_a0326);
    _a0330 = _r0134 - _r0114.zwxy;
    _TMP327 = abs(_a0330);
    _px = bvec4(_TMP323.x <= _TMP327.x, _TMP323.y <= _TMP327.y, _TMP323.z <= _TMP327.z, _TMP323.w <= _TMP327.w);
    _TMP40 = max(_fx30, _fx60);
    _maximo = max(_TMP40, _fx45);
    _t0336 = float(_px.x);
    _TMP41 = _TMP10.xyz + _t0336*(_TMP8.xyz - _TMP10.xyz);
    _TMP42 = _TMP7.xyz + _maximo.x*(_TMP41 - _TMP7.xyz);
    _t0340 = float(_px.y);
    _TMP43 = _TMP8.xyz + _t0340*(_TMP4.xyz - _TMP8.xyz);
    _TMP44 = _TMP7.xyz + _maximo.y*(_TMP43 - _TMP7.xyz);
    _t0344 = float(_px.z);
    _TMP45 = _TMP4.xyz + _t0344*(_TMP6.xyz - _TMP4.xyz);
    _TMP46 = _TMP7.xyz + _maximo.z*(_TMP45 - _TMP7.xyz);
    _t0348 = float(_px.w);
    _TMP47 = _TMP6.xyz + _t0348*(_TMP10.xyz - _TMP6.xyz);
    _TMP48 = _TMP7.xyz + _maximo.w*(_TMP47 - _TMP7.xyz);
    _r0352.x = dot(_TMP42, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0352.y = dot(_TMP44, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0352.z = dot(_TMP46, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _r0352.w = dot(_TMP48, vec3( 1.43519993E+01, 2.81760006E+01, 5.47200012E+00));
    _a0364 = _r0352 - _r0134;
    _TMP361 = abs(_a0364);
    _res = _TMP42;
    _mx = _TMP361.x;
    if (_TMP361.y > _TMP361.x) { 
        _res = _TMP44;
        _mx = _TMP361.y;
    } 
    if (_TMP361.z > _mx) { 
        _res = _TMP46;
        _mx = _TMP361.z;
    } 
    if (_TMP361.w > _mx) { 
        _res = _TMP48;
    } 
    _ret_0 = vec4(_res.x, _res.y, _res.z, 1.00000000E+00);
    FragColor = _ret_0;
    return;
} 
#endif
