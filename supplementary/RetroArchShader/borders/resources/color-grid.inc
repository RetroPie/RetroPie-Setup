
// Based on Color Grid Shadertoy - https://www.shadertoy.com/view/4dBSRK
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

struct input
{
   float2 video_size;
   float2 texture_size;
   float2 output_size;
   float frame_count;
   float frame_direction;
   float frame_rotation;
};

void main_vertex
(
   float4 position : POSITION,
   out float4 oPosition : POSITION,
   uniform float4x4 modelViewProj,

   float4 color : COLOR,
   out float4 oColor : COLOR,

   float2 tex : TEXCOORD,
   out float2 oTex : TEXCOORD,

   float2 tex_border : TEXCOORD1,
   out float2 otex_border : TEXCOORD1,

   uniform input IN
)
{
   oPosition = mul(modelViewProj, position);
   oColor = color;
   
   float2 out_res = float2(out_res_x, out_res_y);
   float2 corrected_size = float2(in_res_x, in_res_y) * (box_scale / box_scale);
   float2 scale = (IN.output_size / corrected_size) / box_scale;
   float2 middle = location * IN.video_size / IN.texture_size;
   float2 diff = tex.xy - middle;
   oTex = middle + diff * scale;

   middle = float2(0.49999, 0.49999);
   float2 dist = tex_border - middle;
   otex_border = middle + dist * IN.output_size / out_res;
}

float4 conv_background(float4 back, float2 coord, float frame_count)
{
   return float4(back.rgb, back.a);
}

float4 main_fragment (
   float2 tex : TEXCOORD0, float2 tex_border : TEXCOORD1,
   uniform sampler2D s0 : TEXUNIT0,
   uniform sampler2D bg,
   uniform input IN) : COLOR
{
    float2  px = 1000.0 *(-IN.texture_size.xy + 2.0 * ZOOM * (tex.xy*(IN.texture_size.xy/IN.video_size.xy)).xy) / IN.texture_size.y;
	
    float id = 0.5 + 0.5*cos(IN.frame_count * 0.01 * SPEED + sin(dot(floor(px+0.5),float2(113.1,17.81)))*43758.545);
    
    float3  co = 0.5 + 0.5*cos(IN.frame_count * 0.01 + 3.5*id + float3(0.0,1.57,3.14) );
    
    float2  pa = smoothstep( 0.0, 0.2, id*(0.5 + 0.5*cos(6.2831*px)) );

	float4 colorgrid = float4( co*pa.x*pa.y, 1.0 );
	
	float4 frame = tex2D(s0, tex);
   float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, colorgrid, background.a);
}
