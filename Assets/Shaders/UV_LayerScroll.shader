Shader "GLU/FX/UV_LayerScroll"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_UV1Speed("UV1Speed", float) = 0.1
		_UV2Speed("UV2Speed", float) = 0.2
		_UV3Speed("UV3Speed", float) = 0.3
		_color("Color" , color) = (1,1,1,1)

		_UV_UpSpeed("UV3Speed", float) = 0.3
	}
	SubShader
	{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			ZTest on
			ZWrite Off
			Cull Off
			Blend One OneMinusSrcColor
			Lighting Off
			
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			
			#include "UnityCG.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
			};

			struct v2f
			{
				half2 uv1 : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half2 uv3 : TEXCOORD2;
				half4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST;
			half _UV1Speed;
			half _UV2Speed;
			half _UV3Speed;
			half4 _color;
			
			half _UV_UpSpeed;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX(v.uv1, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv2, _MainTex);
				o.uv3 = TRANSFORM_TEX(v.uv3, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half alpha = tex2D(_MainTex, i.uv2).a ;
				//UV scroll
				i.uv1.x += (_Time * _UV1Speed);
				i.uv2.x += (_Time * _UV2Speed);
				i.uv3.x += (_Time * _UV3Speed);
				i.uv1.y += (_Time * _UV_UpSpeed);
				i.uv3.y += (_Time * _UV_UpSpeed);
				
				//Texture
				half4 col1 = tex2D(_MainTex, i.uv1).r;
				half4 col2 = tex2D(_MainTex, i.uv2).g;
				half4 col3 = tex2D(_MainTex, i.uv3).b;
				
				half4 col = lerp(col2, col1, col3) * _color;
				//col = lerp(col1, col2, col3) * _color;
				
				return (col * alpha)  * 2.0 ;
			}
			ENDCG
		}
	}
	
}
