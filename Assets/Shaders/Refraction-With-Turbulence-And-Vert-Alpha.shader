Shader "GLU/Refraction With Turbulence Map And Vert Alpha" 
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
		Tags { "Queue"="Transparent" }
		LOD 200

		Pass
		{
		
			Blend SrcAlpha OneMinusSrcAlpha
		
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
				float4 vertColor : COLOR;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0, float4 vertColor : COLOR )
			{
				VertOut OUT;
				
				float3 worldPos = mul( _Object2World, position ).xyz;
				float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.worldPos = worldPos;
				OUT.worldNormal = normalVec;
				OUT.uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
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
				
				float3 worldModelOrigin = mul( _Object2World, float4(0,0,0,1.0) ).xyz;
				float3 worldOriginToVert = input.worldPos - worldModelOrigin.xyz;
				float dist = length( worldOriginToVert );
				
				float3 worldNormal = normalize( input.worldNormal );
				
				float4 fractionColor = tex2D( _RefractionMap, input.uv);
				float refractionIndex = lerp( _MinRefractionIndex, _MaxRefractionIndex, fractionColor.x );
				
				float3 viewDir = normalize( input.worldPos - _WorldSpaceCameraPos.xyz );
				float3 refraction = normalize( refract( viewDir, worldNormal, refractionIndex ) );
				
				float4 finalColor = texCUBE( _MainTex, refraction );
				
				finalColor.a = input.vertColor.a;
				
				OUT.color = finalColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
