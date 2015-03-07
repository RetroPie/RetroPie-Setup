
// Animated Border Cg shader
// Copyright (c) 2014 Mudlord licensed under the WTFPL.

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
        float2 sp = (tex.xy*(IN.texture_size.xy/IN.video_size.xy));
        float2 p = sp*PARAM1 - float2(PARAM2);
        float2 i = p;
        float c = 1.0;
        float inten = PARAM6;//0.01;
        float t = 0.01 * PARAM3 * IN.frame_count* (1.0 - (3.0 / float(0+1)));
        i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.2/length(float2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
        c /= PARAM5;//1.5;
        c = PARAM4-sqrt(c);
	float4 color = float4(R,G,B,1.0);//(float4(tex2D(s0, float2(0.3 * IN.video_size / IN.texture_size)).rgb, 1.0));

	//float4(R,G,B,1.0);

	float4 mudscape = float4(float3(c*c*c*c), 9999.0) + color;
	
	float4 frame = tex2D(s0, tex);
   float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, mudscape, background.a);
}
