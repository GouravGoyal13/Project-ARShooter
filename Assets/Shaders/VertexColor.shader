//=v1.0.1=
Shader "RG/VertexColor" 
{
	Properties { }	
	
	SubShader 
	{
		Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass 
		{
			CGPROGRAM
				#include "UnityCG.cginc"
				#pragma vertex vs300
				#pragma fragment fs300
			
				struct v2f300
				{
					float4 pos : POSITION;					
					float4 color : COLOR;														
				};
			
				v2f300 vs300(appdata_full i)
				{
					v2f300 o;										
					o.pos = mul(UNITY_MATRIX_MVP, i.vertex);					
					o.color = i.color;					
					return o;
				}
				float4 fs300(v2f300 i) : COLOR
				{					
					return i.color;
				}
			ENDCG
		}
	}	
}
