Shader "Custom/Thermographic Transparent No Normals"
{
    Properties
    {
        _MainTex    ("Texture 1", 2D) = "white" {}
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
    
        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
        
            sampler2D   _MainTex;
            float4      _MainTex_ST; //< Unity will auto-fill this with the texture's offset and scale.  Syntax <TextureName>_ST
            sampler2D   _GradientTex;
            float       _RangeMin;
            float       _RangeMax;
            float       _ThermographicBrightness; //< global variable used with all thermographic shaders
            
            sampler2D _NoiseTex0;
            half3 ApplyNoise( half3 inputColor, float2 uv )
            {
                float noiseScale = 1.0;
                float time = fmod( _Time.y, 1.0 );

                float scrollOffset = time * 10.0;
                float2 noiseUV = uv * noiseScale + float2( scrollOffset, scrollOffset );
                half3 finalColor = inputColor * clamp( tex2D( _NoiseTex0, noiseUV  ).r, 0.5, 1.0 );

                return finalColor;
            }

            struct appdata 
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
            };

            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
                o.uv_MainTex = TRANSFORM_TEX (v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR 
            {
                half4 mainColor = tex2D(_MainTex, i.uv_MainTex);

                float rangeMinCompliment = 1.0 - _RangeMin;
            
                half luminance = Luminance(mainColor);
                half3 halfColor = dot(mainColor, mainColor) * tex2D (_GradientTex, float2(abs(luminance * rangeMinCompliment) + (_RangeMax - rangeMinCompliment), 0));

                fixed4 color = fixed4( _ThermographicBrightness*(halfColor + halfColor), 1);
                color.a = mainColor.a;
                
                return color;       
            }

            ENDCG
        }
    }
}
