Shader "GLU/Glow/Textured Pulsing Glow" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture", 2D) = "white" {}

		_GlowColor ("Glow Color", COLOR ) = (1,0,0,1)
        _GlowColorPulseSpeed ("Glow Color Pulse Speed", FLOAT) = 0.5

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
        
            sampler2D _DiffuseTex;
            float4 _GlowColor;
            float _GlowColorPulseSpeed;
			float _MinGlowIntensity;
			float _MaxGlowIntensity;
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

                float4 diffuseTexture = tex2D( _DiffuseTex, input.uv );

				float t = sin(_TimeUI * _GlowColorPulseSpeed) * 0.5 + 0.5;
				float glowT = lerp( _MinGlowIntensity, _MaxGlowIntensity, t);
				float3 glow = _GlowColor * glowT;

				float4 finalColor = float4( diffuseTexture.rgb + glow, 1.0 );

                OUT.color = finalColor;
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
