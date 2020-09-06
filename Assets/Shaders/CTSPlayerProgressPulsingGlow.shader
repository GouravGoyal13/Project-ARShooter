﻿Shader "GLU/Glow/CTS Player Progress Pulsing Glow" 
{
    Properties 
    {
		_BaseColor ("Base Color (RGB)", COLOR) = (0,0,0,1)
		_PlayerWinningGlow ("Player Winning Glow Color", COLOR ) = (0,1,0,1)
        _PlayerWinningGlowColorPulseSpeed ("Player Winning Glow Color Pulse Speed", FLOAT) = 5.0

		_PlayerLosingWinningGlow ("Player Losing Glow Color", COLOR ) = (1,0,0,1)
        _PlayerLosingGlowColorPulseSpeed ("Player Losing Glow Color Pulse Speed", FLOAT) = 10.0

		_MinGlowIntensity ("Min Glow Intensity", FLOAT) = 0.0
		_MaxGlowIntensity ("Max Glow Intensity", FLOAT) = 1.0
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
        
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
			float4 _BaseColor;
            float4 _PlayerWinningGlow;
            float _PlayerWinningGlowColorPulseSpeed;

			float4 _PlayerLosingWinningGlow;
            float _PlayerLosingGlowColorPulseSpeed;

			float _MinGlowIntensity;
			float _MaxGlowIntensity;

			float _CTSPlayerIsWinning;
			float _TimeUI;     
            
            #include "UnityCG.cginc" 
        
            struct VertOut
            {
                float4 position                 : POSITION;
                float2 uv                       : TEXCOORD0;
            };
            
            VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                float3 worldPos = mul( _Object2World, position ).xyz;
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv = uv;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;

				float4 glowColor = _PlayerWinningGlow;
				float glowColorPulseSpeed = _PlayerWinningGlowColorPulseSpeed;

				if(_CTSPlayerIsWinning <= 0.0)
				{
					glowColor = _PlayerLosingWinningGlow;
					glowColorPulseSpeed = _PlayerLosingGlowColorPulseSpeed;
				}

				float t = sin(_TimeUI * glowColorPulseSpeed) * 0.5 + 0.5;
				float glowT = lerp( _MinGlowIntensity, _MaxGlowIntensity, t);

				float4 finalColor = float4( lerp( _BaseColor.rgb, glowColor, glowT), 1.0 );

                OUT.color = finalColor;
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}