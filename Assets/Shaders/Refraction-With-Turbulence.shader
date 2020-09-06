Shader "GLU/Refraction With Turbulence Map" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", CUBE) = "white" {}
		_RefractionMap ("Refraction Map", 2D) = "white" {}
		_MinRefractionIndex ("Minimum Refraction Index", Float) = 0.10
		_MaxRefractionIndex ("Maximum Refraction Index", Float) = 1.00
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
			sampler2D _RefractionMap;
			float4 _MainTex_ST;
			float _MinRefractionIndex;
			float _MaxRefractionIndex;
		
			struct VertOut
			{
				float4 position : POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD3;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
			{
				VertOut OUT;
				
				float3 worldPos = mul( _Object2World, position ).xyz;
				float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.worldPos = worldPos;
				OUT.worldNormal = normalVec;
				OUT.uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float4 fractionColor = tex2D( _RefractionMap, input.uv);
				float refractionIndex = lerp( _MinRefractionIndex, _MaxRefractionIndex, fractionColor.x );
				
				float3 viewDir = normalize( input.worldPos - _WorldSpaceCameraPos.xyz );
				float3 refraction = normalize( refract( viewDir, normalize( input.worldNormal ), refractionIndex ) );
				
				OUT.color = texCUBE( _MainTex, refraction );
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
