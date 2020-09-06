Shader "GLU/Texture/ADD/Unlit With Rotation And Translation"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
		_RotationSpeed ("Rotation Speed", Float) = 1.0
		_TranslationVector ("Translation Vector", VECTOR) = (0,0,0,1)
	}
	
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass
		{
			Blend SrcAlpha One
			ZWrite Off
			Lighting Off
			Cull Off
			Fog { Mode Off }
			
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			#define PI				3.14159265359
			#define PI_DIV_2		1.57079632679
		
			sampler2D _MainTex;
			float4 _Color;
			float _RotationSpeed;
			float4 _TranslationVector;
			float _TimeUI;

			float2 RotateUV( float2 uv, float rotationInDegrees )
			{
				float theta = radians(rotationInDegrees);
				
				float c = cos( theta );
				float s = sin( theta );
				
				uv.x -= 0.5;
				uv.y -= 0.5;
				
				float x = (uv.x * c) - (uv.y * s);
				float y = (uv.x * s) + (uv.y * c);
				
				x += 0.5;
				y += 0.5;
				
				return float2(x, y);																			
			}

			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0 )
			{
				VertOut OUT;

				float rotationTheta = fmod( _TimeUI * _RotationSpeed, 360.0);
				float2 translationOffset = fmod(_TimeUI * _TranslationVector, 1.0);

				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.uv = RotateUV( uv, rotationTheta ) + translationOffset;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float4 textureColor = tex2D( _MainTex, input.uv );
				float4 finalColor = textureColor * _Color;
				
				OUT.color = finalColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}

