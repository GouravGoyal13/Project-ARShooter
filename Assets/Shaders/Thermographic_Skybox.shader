Shader "Custom/Thermographic Skybox"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "Queue"="Background" "RenderType"="Background" }
		
		Pass
		{
			Lighting Off
			Cull Off
			Fog { Mode Off }
					
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
						
			struct v2f 
			{
				float4  pos : SV_POSITION;
			};
			
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
			    v2f o;
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
			    return half4(0,0,0,1);
			}
			ENDCG

        } //< end pass
	} //< end subshader

}
