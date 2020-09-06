Shader "GLU/Emissive Vertex Color Only (No Alpha Blending)" 
{
	Properties 
	{

	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector"="True" }   

		Pass
		{
			Fog { Mode Off }
			
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			struct VertOut
			{
				float4 position : POSITION;
				float4 vertColor : TEXCOORD0;
			};
			
			VertOut v( float4 position : POSITION, float4 vertColor : COLOR )
			{
				VertOut OUT;
				
				OUT.position = mul( UNITY_MATRIX_MVP, position ); 
				OUT.vertColor = vertColor;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				OUT.color = input.vertColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}

