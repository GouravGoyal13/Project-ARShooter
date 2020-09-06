Shader "GLU/Fishing Drops"
{	
	Properties
	{			
		_NormalTex("Normal map", 2D) = "bump" {}
		_DiffuseTex("Diffuse map", 2D) = "white" {}
		_Distortion("Distortion", Range(-1, 1)) = 0.1		
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 400

		// Grab the screen behind the object into _BackgroundTexture
		GrabPass
		{
			"_BackgroundTexture"
		}

		Pass
		{
			CGPROGRAM			
			#pragma exclude_renderers xbox360
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct v2f
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
				float4	grabPos : TEXCOORD1;		
				float4	color : COLOR;
			};

			sampler2D _NormalTex;
			float4 _NormalTex_ST;
			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;			
			sampler2D _BackgroundTexture;
			float _Distortion;			
					
			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _NormalTex);
				o.color = v.color;

				o.grabPos = ComputeGrabScreenPos(o.pos);				

				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				float4 diffuseTexture = tex2D(_DiffuseTex, i.uv);
				float4 normalTexture = tex2D(_NormalTex, i.uv);
				fixed3 normal = UnpackNormal(normalTexture);
				
				i.grabPos.xy += normal * _Distortion;
				float4 refraction = tex2Dproj(_BackgroundTexture, i.grabPos);				
				
				float4 c = float4(refraction.rgb, diffuseTexture.a * i.color.a);				

				return c;
			}
			ENDCG
		}
	}		
}