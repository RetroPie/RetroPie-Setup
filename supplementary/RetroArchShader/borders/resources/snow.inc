
// Snowy Border Cg shader, based on Andrew Baldwin's 'Just Snow' shadertoy, licensed below:
// Copyright (c) 2013 Andrew Baldwin (twitter: baldand, www: http://thndl.com)
// License = Attribution-NonCommercial-ShareAlike (http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US)

// "Just snow"
// Simple (but not cheap) snow made from multiple parallax layers with randomly positioned 
// flakes and directions. Also includes a DoF effect. Pan around with mouse.

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
   float2 corrected_size = float2(in_res_x, in_res_y);
   float2 scale = (IN.output_size / corrected_size) / box_scale;
   float2 middle = location * IN.video_size / IN.texture_size;
   float2 diff = tex.xy - middle;
   oTex = middle + diff * scale;

   middle = float2(0.49999, 0.49999);
   float2 dist = tex_border - middle;
   otex_border = middle + dist * IN.output_size / out_res;
}

#define LAYERS 15.0
#define DEPTH 1.0
#define WIDTH 0.75
#define SPEED -.03

input IN_global;
sampler2D s0_global;

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
   s0_global = s0;
   IN_global = IN;
	const float3x3 p = float3x3(13.323122,21.1212,21.8112,23.5112,28.7312,14.7212,21.71123,11.9312,61.3934);
	float2 uv = tex.xy*(IN.texture_size.xy/IN.video_size.xy);
	float3 acc = float3(0.0);
	float dof = 5.*sin(IN.frame_count*.1);
	for (int i=0;i<LAYERS;i++) {
		float fi = float(i);
		float2 q = uv*(1.+fi*DEPTH);
		q += float2(q.y*(WIDTH*mod(fi*7.238917,1.)-WIDTH*.5),SPEED*IN.frame_count/(1.+fi*DEPTH*.03));
		float3 n = float3(floor(q),31.189+fi);
		float3 m = floor(n)*.00001 + frac(n);
		float3 mp = (31415.9+m)/frac(mul(p,m));
		float3 r = frac(mp);
		float2 s = abs(mod(q,1.)-.5+.9*r.xy-.45);
		s += .01*abs(2.*frac(10.*q.yx)-1.); 
		float d = .6*max(s.x-s.y,s.x+s.y)+max(s.x,s.y)-.01;
		float edge = .05+.05*min(.5*abs(fi-5.-dof),1.);
		acc += float3(smoothstep(edge,-edge,d)*(r.x/(1.+.02*fi*DEPTH)));
	}
	float4 snowscape = float4(float3(acc),1.0);
	
	float4 frame = tex2D(s0, tex);
   float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, snowscape, background.a);
}
