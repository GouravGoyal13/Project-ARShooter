Shader "GLU/Transparent/Unlit (No Fog No Alpha Test Saturate)"
{
    Properties 
    {
        _MainTex ("Main Texture (RGB)", 2D) = "white" {}
        _Saturation ("Saturation", Float) = 1.0
        _Value ("Value", Float) = 1.0
    }

    SubShader 
    {
        Tags { "Queue"="Transparent" }

        AlphaTest Off
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		ZTest LEqual
		Lighting Off
		Cull Off
		Fog { Mode Off }

		CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		fixed _Saturation;
		fixed _Value;

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		struct appdata_t
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		v2f vert (appdata_t v)
		{
			v2f	o;

			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;

			return o;
		}
		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed4 d = dot(c, fixed4(0.3, 0.59, 0.11, 0.0));
				c.rgb = lerp(d, c, _Saturation) * _Value;
				return c;
			}

			ENDCG
        }
    }
}
