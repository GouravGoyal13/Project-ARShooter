// Simplified Additive Particle shader. Differences from regular Additive Particle one:
// - no Tint color
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "GLU/Particles/Additive, (No Fog) (Always Draw In Front)" 
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "black" {}
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		ZTest Always
		ZWrite Off
		Cull Off 
		Blend SrcAlpha One
		Lighting Off 
		Fog {Mode Off}

		Pass
		{
		
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _TintColor;
		
			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				fixed3 color : COLOR;
			};
			
			VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, fixed3 color : COLOR )
			{
				VertOut OUT;
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.uv = (uv * _MainTex_ST.xy) + _MainTex_ST.zw;
				OUT.color = color;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				fixed4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				fixed4 tex = tex2D( _MainTex, input.uv );
				fixed4 finalColor = fixed4(input.color.rgb * tex.rgb, 1.0);
				finalColor.a = tex.a;
				
				OUT.color = finalColor;

				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
