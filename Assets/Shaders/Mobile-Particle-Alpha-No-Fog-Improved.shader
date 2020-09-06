// Simplified Alpha Blended Particle shader. Differences from regular Alpha Blended Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "GLU/Particles/Alpha Blended (No Fog) IMPROVED" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog { Mode Global }

		Pass
		{
		
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			sampler2D _MainTex;
			float4 _MainTex_ST;
		
			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR0;
			};
			
			VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, float4 color : COLOR )
			{
				VertOut OUT;
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
				OUT.color = color;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float4 color = tex2D( _MainTex, input.uv ) * input.color;
				
				OUT.color = color;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
