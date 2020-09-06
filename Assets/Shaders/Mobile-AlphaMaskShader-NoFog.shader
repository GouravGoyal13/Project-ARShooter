Shader "GLU/Alpha Mask Shader ( No Fog )" 
{
	Properties 
	{
		_MainTex ("Base (RGB + Alpha Mask)", 2D) = "white" {}
		_MaskTex ("Grayscale Mask", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaTest Greater .01
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off
		Fog { Mode Off }
		

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
		
			struct VertOut
			{
				float4 position 		: POSITION;
				float2 baseUV 			: TEXCOORD0;
				float2 maskUV 			: TEXCOORD1;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
			{
				VertOut OUT;
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.baseUV = uv * _MainTex_ST.xy + _MainTex_ST.zw;
				OUT.maskUV = uv * _MaskTex_ST.xy + _MaskTex_ST.zw;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float4 baseColor = tex2D( _MainTex, input.baseUV );
				float4 maskColor = tex2D( _MaskTex, input.maskUV );
				
				float4 finalColor = baseColor;
				finalColor.a = baseColor.a * maskColor.r;
				
				OUT.color = finalColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
