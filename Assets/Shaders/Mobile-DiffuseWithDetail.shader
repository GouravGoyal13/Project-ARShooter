Shader "GLU/Diffuse With Detail"
{
	Properties
	{
		_DiffuseTex ("Diffuse Texture (Alpha Controls Specular Intensity", 2D) = "white" {}
		[NoScaleOffset] _NormalTex ("Normal Map (Alpha Controls Specular Glossiness)", 2D) = "bump" {}

		_MinSpecularGlossiness ("Minimum Specular Glossiness", Float) = 8.0
		_MaxSpecularGlossiness ("Maximum Specular Glossiness", Float) = 58.0

		_MinDiffuseCoefficient ("Min Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0)) = 0.30
		_MaxDiffuseCoefficient ("Max Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0)) = 0.70
	}

	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType"="Opaque" "LightMode"="ForwardBase" "ShadowCaster"="True" }
		LOD 300

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
			#include "Mobile-DiffuseWithDetail.cginc"
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "Queue" = "Geometry" "RenderType"="Opaque" "LightMode"="ForwardBase" "ShadowCaster"="True" }
		LOD 200
		Cull Back
		Lighting Off

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p

			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			float3 _LightColor0; 
			float _MinDiffuseCoefficient;
			float _MaxDiffuseCoefficient;

			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, fixed3 color : COLOR )
			{
				VertOut OUT;

				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.uv = (uv * _DiffuseTex_ST.xy) + _DiffuseTex_ST.zw;

				return OUT;
			}

			fixed4 p ( VertOut input ) : COLOR
			{
				fixed4 c = tex2D( _DiffuseTex, input.uv);
				c.a = 1;

				float diffuseCoefficient = (_MinDiffuseCoefficient + _MaxDiffuseCoefficient) * 0.5;

				c.rgb *= _LightColor0 * diffuseCoefficient + UNITY_LIGHTMODEL_AMBIENT.rgb;
				return c;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
