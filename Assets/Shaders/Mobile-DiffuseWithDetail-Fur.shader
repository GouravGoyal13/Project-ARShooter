Shader "GLU/Diffuse With Detail (Fur)" 
{
	Properties
	{
		[Enum(RGBA, 15, RGB, 14)] _ColorWriteMask ("Color Write Mask", float) = 14

		_DiffuseTex ("Diffuse Texture (Alpha Controls Specular Intensity)", 2D) = "white" {}
		[NoScaleOffset] _NormalTex ("Normal Map (Alpha Controls Specular Glossiness)", 2D) = "bump" {}

		_MinSpecularGlossiness ("Minimum Specular Glossiness", Float) = 8.0
		_MaxSpecularGlossiness ("Maximum Specular Glossiness", Float) = 58.0

		_MinDiffuseCoefficient ("Min Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0)) = 0.30
		_MaxDiffuseCoefficient ("Max Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0)) = 0.70

		[Header(Fur)] _FurLength ("Length", Range(0.0, 0.1)) = 0.015
		_FurTrim ("Trim", Range(0.0, 1.0)) = 0.0
		_FurGravity ("Gravity (XYZ)", Vector) = (0.0, -0.02, 0.0, 0.0)
		[NoScaleOffset] _FurTex ("Density (A)", 2D) = "black" {}
		_FurScale ("Scale", Range(0.0, 2.0)) = 1.0
		_FurOffset ("Offset", Range(-1.0, 1.0)) = 0.0

		[Header(Fur Shadow)] [Toggle(FUR_SHADOW)] _FurShadow ("Enable", float) = 0
		_FurStrength ("Strength", Range(0.0, 1.0)) = 0.5
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Opaque" "LightMode"="ForwardBase" "ShadowCaster"="True" }
		LOD 400

		//CGINCLUDE
		////#define EXTRUDE_MAX_LEVEL 30.0
		//ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"			
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 1
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 2
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 3
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 4
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 5
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 6
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 7
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 8
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 9
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 10
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 11
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 12
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 13
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 14
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 15
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 16
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 17
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 18
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 19
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 20
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 21
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 22
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 23
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 24
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 25
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 26
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 27
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 28
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 29
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 30
			#define EXTRUDE_MAX_LEVEL 30.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Opaque" "LightMode"="ForwardBase" "ShadowCaster"="True" }
		LOD 320


		//CGINCLUDE
		//#define EXTRUDE_MAX_LEVEL 15.0
		//ENDCG


		Pass
		{
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"			
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 1
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 2
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 3
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 4
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 5
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 6
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 7
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 8
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 9
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 10
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 11
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 12
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 13
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 14
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			ColorMask [_ColorWriteMask]
			CGPROGRAM
			#pragma vertex v_fur
			#pragma fragment p_fur
			#pragma shader_feature FUR_SHADOW
			#define EXTRUDE_LEVEL 15
			#define EXTRUDE_MAX_LEVEL 15.0
			#include "Mobile-DiffuseWithDetail-Fur.cginc"
			ENDCG
		}
	}

	SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" "LightMode" = "ForwardBase" "ShadowCaster" = "True" }
		LOD 200

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
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" "LightMode" = "ForwardBase" "ShadowCaster" = "True" }
		LOD 100
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

			VertOut v(float4 position : POSITION, float2 uv : TEXCOORD0, fixed3 color : COLOR)
			{
				VertOut OUT;

				OUT.position = mul(UNITY_MATRIX_MVP, position);
				OUT.uv = (uv * _DiffuseTex_ST.xy) + _DiffuseTex_ST.zw;

				return OUT;
			}

			fixed4 p(VertOut input) : COLOR
			{
				fixed4 c = tex2D(_DiffuseTex, input.uv);
				c.a = 1;

				float diffuseCoefficient = (_MinDiffuseCoefficient + _MaxDiffuseCoefficient) * 0.5;

				c.rgb *= _LightColor0 * diffuseCoefficient + UNITY_LIGHTMODEL_AMBIENT.rgb;
				return c;
			}
			ENDCG
		}
	}

	FallBack "GLU/Diffuse With Detail"
}
