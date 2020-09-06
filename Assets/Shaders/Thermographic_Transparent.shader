Shader "Custom/Thermographic Transparent"
{
	Properties
	{
		_MainTex	("Texture 1", 2D) = "white" {}
		_GradientTex ("Gradient (RGB)", 2D) = "white" {}
		_RangeMin ("RangeMin", Range(0.0, 1.0)) = 0.0
		_RangeMax ("RangeMax", Range(0.0, 1.0)) = 1.0
	}
	
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

		CGPROGRAM
			
		#pragma surface surf Lambert alpha:fade
		
		sampler2D	_MainTex;
		sampler2D	_GradientTex;
		float		_RangeMin;
		float		_RangeMax;
		float 		_ThermographicBrightness; //< global variable used with all thermographic shaders
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
		    float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			half4 mainColor = tex2D (_MainTex,	IN.uv_MainTex); 
			float rangeMinCompliment = 1.0 - _RangeMin;
			half3 halfColor = dot(mainColor.rgb, mainColor.rgb) * tex2D (_GradientTex, float2(abs(dot(IN.worldNormal, IN.viewDir) * rangeMinCompliment) + (_RangeMax - rangeMinCompliment), 0));
			
			o.Albedo = _ThermographicBrightness*halfColor;
			o.Alpha = mainColor.a;
		}
				
		ENDCG
	}
	
	FallBack "Diffuse"
}
