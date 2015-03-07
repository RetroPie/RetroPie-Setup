
// Based on Iterations - shiny Shadertoy - https://www.shadertoy.com/view/MslXz8
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

input IN_global;
sampler2D s0_global;

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
	float2 pc = (1000.0* SCALE * (tex.xy*(IN.texture_size.xy/IN.video_size.xy)).xy-IN.texture_size.xy)/min(IN.texture_size.y,IN.texture_size.x);

	float2 pa = pc + float2(0.04,0.0);
	float2 pb = pc + float2(0.0,0.04);
	
    // shape (3 times for diferentials); Had to unroll this function, as IN_global.frame_count apparently doesn't iterate :/
	float2 zc = pc;
	float3 fc = float3( 0.0 );
	for( int i=0; i<8; i++ ) 
	{
        // transform		
		zc += cos(zc.yx + cos(zc.yx + cos(zc.yx+IN.frame_count * 0.01 * SPEED) ) );

        // orbit traps		
		float d = dot( zc-pc, zc-pc ); 
		fc.x += 1.0/(1.0+d);
		fc.y += d;
		fc.z += sin(atan(zc.y-pc.y,zc.x-pc.x));
	}
	fc /= 8.0;
	float3 sc = fc;
	
	float2 za = pa;
	float3 fa = float3( 0.0 );
		for( int i=0; i<8; i++ ) 
	{
        // transform		
		za += cos(za.yx + cos(za.yx + cos(za.yx+IN.frame_count * 0.01 * SPEED) ) );

        // orbit traps		
		float d = dot( za-pa, za-pa ); 
		fa.x += 1.0/(1.0+d);
		fa.y += d;
		fa.z += sin(atan(za.y-pa.y,za.x-pa.x));
	}
	fa /= 8.0;
	float3 sa = fa;
	
	float2 zb = pb;
	float3 fb = float3( 0.0 );
		for( int i=0; i<8; i++ ) 
	{
        // transform		
		zb += cos(zb.yx + cos(zb.yx + cos(zb.yx+IN.frame_count * 0.01 * SPEED) ) );

        // orbit traps		
		float d = dot( zb-pb, zb-pb ); 
		fb.x += 1.0/(1.0+d);
		fb.y += d;
		fb.z += sin(atan(zb.y-pb.y,zb.x-pb.x));
	}
	fb /= 8.0;
	float3 sb = fb;

    // color	
	float3 col = mix( float3(0.08,0.02,0.15), float3(0.6,1.1,1.6), sc.x );
	col = mix( col, col.zxy, smoothstep(-0.5,0.5,cos(0.01*IN.frame_count * COL_SHFT)) );
	col *= 0.15*sc.y;
	col += 0.4*abs(sc.z) - 0.1;

    // light	
	float3 nor = normalize( float3( sa.x-sc.x, 0.01, sb.x-sc.x ) );
	float dif = clamp(0.5 + 0.5*dot( nor,float3(0.5773) ),0.0,1.0);
	col *= 1.0 + 0.7*dif*col;
	col += 0.3 * pow(nor.y,128.0);

    // vignetting	
	col *= 1.0 - 0.1*length(pc);

	float4 effect = float4( col, 1.0 );
	
	float4 frame = tex2D(s0, tex);
   float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, effect, background.a);
}
