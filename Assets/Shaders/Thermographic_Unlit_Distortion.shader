Shader "Custom/Thermographic Unlit Distortion" {
Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}		
		_DistortionU ("Distortion U", 2D) = "white" {}
		_DistortionV ("Distortion V", 2D) = "white" {}
        _DistortionPower ("Distortion Power", Range(0,0.25)) = 1
        _HorizonPower ("Horizon Power", Range(0.001, 0.1)) = 5
        
     	_GradientTex ("Gradient (RGB)", 2D) = "white" {}
		_RangeMin ("RangeMin", Range(0.0, 1.0)) = 0.0
		_RangeMax ("RangeMax", Range(0.0, 1.0)) = 1.0

	}
	SubShader 
	{
		Tags { "RenderType" = "Opaque"}
		Fog { Mode Off }
		Lighting Off
		Blend One Zero
		
		Pass
	    {	
			CGPROGRAM
			#pragma vertex vertexMain
			#pragma fragment pixelMain
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DistortionU;
			float4 _DistortionU_ST;
			sampler2D _DistortionV;
			float4 _DistortionV_ST;
			
			float _HorizonPower;
			float _DistortionPower;
			
			// thermo vars
			sampler2D	_GradientTex;
			float		_RangeMin;
			float		_RangeMax;
			float 		_ThermographicBrightness; //< global variable used with all thermographic shaders
			
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
				float2 texcoord2 : TEXCOORD2;
				float4 color : COLOR0;
				float4 pos : TEXCOORD3;
			};
			
			Vertex vertexMain(Input input)
			{
				Vertex vertex;
				vertex.position = mul(UNITY_MATRIX_MVP, input.vertex);
				
				vertex.texcoord = input.texcoord *_MainTex_ST.xy +_MainTex_ST.zw;
				vertex.texcoord1 = input.texcoord *_DistortionU_ST.xy +_DistortionU_ST.zw *_Time.y; // Scrolling Texture
				vertex.texcoord2 = input.texcoord *_DistortionV_ST.xy +_DistortionV_ST.zw *_Time.y; // Scrolling Texture
				vertex.pos = vertex.position;
				
				vertex.color = input.color;
				return vertex;
			}
			
			struct Pixel
			{
				float4 color : COLOR;
			};
			
			Pixel pixelMain(Vertex vertex)
			{
				Pixel pixel;  
				
				float4 offsetU = tex2D(_DistortionU, vertex.texcoord1);
				float4 offsetV = tex2D(_DistortionV, vertex.texcoord2);
				float4 mainColor = tex2D(_MainTex, vertex.texcoord +float2((offsetU.a-0.5), (offsetV.a-0.5)) *_DistortionPower *(1-pow(vertex.texcoord.y, _HorizonPower))  ) *vertex.color;
				
				// now calc thermo color
				float rangeMinCompliment = 1.0 - _RangeMin;
			
				half luminance = Luminance(mainColor);
				half3 halfColor = tex2D (_GradientTex, float2(abs(luminance * rangeMinCompliment) + (_RangeMax - rangeMinCompliment), 0));
			
				pixel.color = fixed4( _ThermographicBrightness*(halfColor + halfColor), 1);
				
				return pixel;
			}
			ENDCG
		}
	}
}
