Shader "GUI/UITransformColor"
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskTex("Texture", 2D) = "white" {}
		_PatternTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
		_BrightnessMask("BrightnessMask", Float) = 1.0
		_Brightness("Brightness", Float) = 1.0
		_Desaturate("Desaturate", Float) = 0.0
		_Additive("Additive", Float) = 0.0
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog { Mode Off }
		
		Pass
	    {	
			
			CGPROGRAM
			#pragma vertex vertexMain
			#pragma fragment pixelMain
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _PatternTex;
			float4 _PatternTex_ST;
			float4 _Color;
			float _Brightness;
			float _BrightnessMask;
			float _Desaturate;
			float _Additive;

			struct Input
			{
				float4 vertex : POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR0;
			};
			
			struct Vertex
			{
				float4 position : POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float4 color : COLOR0;
			};
			
			Vertex vertexMain(Input input)
			{
				Vertex vertex;
				vertex.position = mul(UNITY_MATRIX_MVP, input.vertex);
				
				vertex.texcoord = input.texcoord;
				vertex.texcoord1 = TRANSFORM_TEX(input.texcoord, _PatternTex);
				vertex.color = _Color;
					
				return vertex;
			}
			
			struct Pixel
			{
				float4 color : COLOR;
			};

			Pixel pixelMain(Vertex vertex)
			{
				Pixel pixel;  
	
				float4 t = tex2D(_MainTex, vertex.texcoord);
				float4 p = tex2D(_PatternTex, vertex.texcoord1);
				float3 m = tex2D(_MaskTex, vertex.texcoord);
				//m.b - mask channel
				//m.g - additive channel

				float3 mixed = (t.rgb + _Additive) * p * vertex.color.rgb * m.b * _BrightnessMask + m.g;

				mixed = lerp(t.rgb + _Additive, mixed, m.r);
				mixed = lerp(mixed, dot(mixed, float3(0.3, 0.59, 0.11)), _Desaturate);

				pixel.color = float4(mixed * _Brightness, t.a);
		
				return pixel;
			}
			ENDCG
		}
	}
}       