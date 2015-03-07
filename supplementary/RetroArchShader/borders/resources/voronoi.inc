
// Based on Voronoi - smooth Shadertoy - https://www.shadertoy.com/view/ldB3zc
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

float hash1( float n ) { return frac(sin(n)*43758.5453); }
float2  hash2( float2  p ) { p = float2( dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)) ); return frac(sin(p)*43758.5453); }

float4 voronoi( in float2 x, float w )
{
    float2 n = floor( x );
    float2 f = frac( x );

	float4 m = float4( 8.0, 0.0, 0.0, 0.0 );
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 g = float2( float(i),float(j) );
        float2 o = hash2( n + g );
		
		// animate
        o = 0.5 + 0.5*sin( 0.01 * IN_global.frame_count + 6.2831*o );

        // distance to cell		
		float d = length(g - f + o);
		
        // do the smooth min for colors and distances		
		float3 col = 0.5 + 0.5*sin( hash1(dot(n+g,float2(7.0,113.0)))*2.5 + 3.5 + float3(2.0,3.0,0.0));
		float h = smoothstep( 0.0, 1.0, 0.5 + 0.5*(m.x-d)/w );
		
	    m.x   = mix( m.x,     d, h ) - h*(1.0-h)*w/(1.0+3.0*w); // distance
		m.yzw = mix( m.yzw, col, h ) - h*(1.0-h)*w/(1.0+3.0*w); // cioloe
    }
	
	return m;
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
   s0_global = s0;
   IN_global = IN;

    float2 p = 500.0 * (tex.xy*(IN.texture_size.xy/IN.video_size.xy))/IN.texture_size.yy;
	
	float k = 2.0 + 70.0 * pow( 0.5 + 0.5*sin(0.25*6.2831*0.03 * IN.frame_count), 4.0 );
	k = 0.5 - 0.5*cos(0.25*6.2831*0.03 * IN.frame_count);
    float4 c = voronoi( 6.0*p, k );

    float3 col = c.yzw;
	
	col *= 1.0 - 0.8*c.x*step(p.y,0.33);
	col *= mix(c.x,1.0,step(p.y,0.66));
	
	col *= smoothstep( 0.005, 0.007, abs(p.y-0.33) );
	col *= smoothstep( 0.005, 0.007, abs(p.y-0.66) );
	
	float4 hexscape = float4( col, 1.0 );
	
	float4 frame = tex2D(s0, tex);
   float4 background = conv_background(tex2D(bg, tex_border), tex_border, IN.frame_count);
   return lerp(frame, hexscape, background.a);
}
