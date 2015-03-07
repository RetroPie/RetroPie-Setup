struct input
{
   float2 video_size;
   float2 texture_size;
   float2 output_size;
   float frame_count;
   float frame_direction;
   float frame_rotation;
};

struct passprev
{
sampler2D texture : TEXUNIT1;
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

   float2 tex2 : TEXCOORD2,
   out float2 oTex2 : TEXCOORD2,

   uniform input IN
)
{
   oPosition = mul(modelViewProj, position);
   oColor = color;
   oTex2 = (tex2 / border_zoom) + float2(0.05 * border_zoom, 0.05 * border_zoom);  
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
   float2 tex : TEXCOORD0, float2 tex_border : TEXCOORD1, float2 tex2 : TEXCOORD2,
   uniform passprev PASSPREV3,
   uniform sampler2D bg,
   uniform sampler2D s0 : TEXUNIT0,
   uniform input IN) : COLOR
{
 float4 big = float4(tex2D(s0, (tex / border_zoom) + float2(0.3 * IN.video_size / IN.texture_size)));
 float4 frame = tex2D(PASSPREV3.texture, tex);
 float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, big, background.a);
}
