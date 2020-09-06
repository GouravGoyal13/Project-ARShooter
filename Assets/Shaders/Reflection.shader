Shader "GLU/Reflection" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", CUBE) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
		
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			samplerCUBE _MainTex;
			float _RotationSpeed;
		
			struct VertOut
			{
				float4 position : POSITION;
				float3 viewDir : TEXCOORD0;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL )
			{
				VertOut OUT;
				
				float3 worldPos = mul( _Object2World, position ).xyz;
				float3 viewDir = worldPos - _WorldSpaceCameraPos.xyz;
				
				float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
				
				float3 reflection = reflect( viewDir, normalVec );
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.viewDir = reflection;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				OUT.color = texCUBE( _MainTex, input.viewDir );
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
