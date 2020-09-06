Shader "GLU/Refraction With Turbulence Map And Transparent Rim" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", CUBE) = "white" {}
		_RefractionMap ("Refraction Map", 2D) = "white" {}
		_MinRefractionIndex ("Minimum Refraction Index", Float) = 0.10
		_MaxRefractionIndex ("Maximum Refraction Index", Float) = 1.00
		_TransparentRimThresholdInDegrees ("Transparent Rim Threshold In Degrees", Float) = 40
		_TransparencyPower ("Transparency Power", Float) = 10
		_DistanceFromOriginFade ("Distance From Model Origin Threshold", Float) = 0.5
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
			float _TransparentRimThresholdInDegrees;
			float _TransparencyPower;
			float _DistanceFromOriginFade;
		
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
				
				float3 worldModelOrigin = mul( _Object2World, float4(0,0,0,1.0) ).xyz;
				float3 worldOriginToVert = input.worldPos - worldModelOrigin.xyz;
				float dist = length( worldOriginToVert );
				
				float3 worldNormal = normalize( input.worldNormal );
				
				float4 fractionColor = tex2D( _RefractionMap, input.uv);
				float refractionIndex = lerp( _MinRefractionIndex, _MaxRefractionIndex, fractionColor.x );
				
				float3 viewDir = normalize( input.worldPos - _WorldSpaceCameraPos.xyz );
				float3 refraction = normalize( refract( viewDir, worldNormal, refractionIndex ) );
				
				float4 finalColor = texCUBE( _MainTex, refraction );
				
				float dt = clamp( dot( -viewDir, worldNormal ), 0.00, 1.0 );
				float transparentRimThresholdInRadians = (_TransparentRimThresholdInDegrees * 3.14159) / 180.0;
				if( dt < transparentRimThresholdInRadians )
				{
					float t = (transparentRimThresholdInRadians - dt) / transparentRimThresholdInRadians;
					t = clamp( 1.0 - pow( 1.0 - t, _TransparencyPower ), 0.000, 1.0 );
					finalColor.a = lerp( finalColor.a, 0.00, t );
					//Debug View
					//finalColor = lerp( finalColor, float4(1.0, 0.0, 0.0, 1.0), t );
				}
				
				if( dist > _DistanceFromOriginFade )
				{
					float t = abs( (_DistanceFromOriginFade - dist) ) / _DistanceFromOriginFade;
					finalColor.a = lerp( finalColor.a, 0.00, t );
					//Debug View
					//finalColor = lerp( finalColor, float4(0.0, 0.0, 1.0, 1.0), t );
				}
				
				OUT.color = finalColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
