Shader "Bumped Specular Triple Texture Blend" 
{
	Properties 
	{
		_BlendTex1 ("Texture 1 (RGB) Gloss (A)", 2D) = "white" {}
		_BlendTex2 ("Texture 2 (RGB) Gloss (A)", 2D) = "white" {}
		_BlendTex3 ("Texture 3 (RGB) Gloss (A)", 2D) = "white" {}
	
		_BumpMap1 ("Normalmap 1", 2D) = "bump" {}
		
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125	
	}

	SubShader 
	{ 
		Tags { "RenderType"="Opaque" }
		LOD 400
		
		CGPROGRAM
		#pragma surface surf BlinnPhong

		sampler2D _BlendTex1;
		sampler2D _BlendTex2;
		sampler2D _BlendTex3;
		
		sampler2D _BumpMap1;
		sampler2D _BumpMap2;
		sampler2D _BumpMap3;
		
		half _Shininess;

		struct Input 
		{
			float2 uv_BlendTex1;
			float4 color : COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 tex1 = tex2D(_BlendTex1, IN.uv_BlendTex1);
			fixed4 tex2 = tex2D(_BlendTex2, IN.uv_BlendTex1);
			fixed4 tex3 = tex2D(_BlendTex3, IN.uv_BlendTex1);
			
			fixed4 blendColor = (tex1*IN.color.r) + (tex2*IN.color.g) + (tex3*IN.color.b);
			
			o.Albedo = blendColor.rgb;
			o.Gloss = blendColor.a;
			
			o.Specular = _Shininess;
			
			// note: normal map blend... would a tangent color blend be an accurate normal blend?  not sure that's accurate, but it looks fine.
			fixed4 bump1 = tex2D(_BumpMap1, IN.uv_BlendTex1);			
			o.Normal = UnpackNormal(bump1);
		}
		ENDCG
	}
}
