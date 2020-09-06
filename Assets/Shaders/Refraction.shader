Shader "GLU/Refraction" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", CUBE) = "white" {}
		_IndexOfRefaction ("Index Of Refraction", Float) = 0.05
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
			float _IndexOfRefaction;
		
			struct VertOut
			{
				float4 position : POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL )
			{
				VertOut OUT;
				
				float3 worldPos = mul( _Object2World, position ).xyz;
				float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.worldPos = worldPos;
				OUT.worldNormal = normalVec;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float3 viewDir = normalize( input.worldPos - _WorldSpaceCameraPos.xyz );
				
				float3 refraction = normalize( refract( viewDir, normalize( input.worldNormal ), _IndexOfRefaction ) );
				
				OUT.color = texCUBE( _MainTex, refraction );
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
