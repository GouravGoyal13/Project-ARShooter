// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Custom/Thermographic Terrain No Normals"
{
    Properties
    {
        _MainTex    ("Texture 1", 2D) = "white" {}
        _BlendTex1  ("Texture 2", 2D) = "white" {}
        _BlendTex2  ("Texture 3", 2D) = "white" {}
        _GradientTex ("Gradient (RGB)", 2D) = "white" {}
        _RangeMin ("RangeMin", Range(0.0, 1.0)) = 0.0
        _RangeMax ("RangeMax", Range(0.0, 1.0)) = 1.0

        [MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        // Non-lightmapped
        Pass 
        {
            Tags { "LightMode" = "Vertex" }
            Lighting Off
            
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers  xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                #include "Shadows.cginc"
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv0 : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  uv2 : TEXCOORD2;
                    float4 shadowCoord : TEXCOORD3;
                    float4  color : COLOR;
                };
                
                float4 _MainTex_ST;
                float4 _BlendTex1_ST;
                float4 _BlendTex2_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv0 = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = TRANSFORM_TEX (v.texcoord, _BlendTex1);
                    o.uv2 = TRANSFORM_TEX (v.texcoord, _BlendTex2);
                    
                    o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                
                sampler2D   _GradientTex;
                float       _RangeMin;
                float       _RangeMax;
                float       _ThermographicBrightness; //< global variable used with all thermographic shaders


                half4 frag (v2f i) : COLOR
                {                   
                    half4 mainColor = (tex2D(_MainTex, i.uv0) * i.color.r) + 
                                    (tex2D(_BlendTex1, i.uv1) * i.color.g) + 
                                    (tex2D(_BlendTex2, i.uv2) * i.color.b);
                    
                    mainColor.rgb = ApplyShadows( mainColor.rgb, i.shadowCoord );

                    half luminance = lerp(_RangeMin, _RangeMax, Luminance(mainColor.rgb));

                    half3 thermoColor = _ThermographicBrightness*tex2D(_GradientTex, float2(luminance, 0)).rgb;
                    
                    return half4( thermoColor.rgb, 1 );
                }
            ENDCG
        }
    
        // RGBM lightmapping (PC)
        Pass 
        {
            Tags { "LightMode" = "VertexLMRGBM" }
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers  xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                #include "Shadows.cginc"

                sampler2D _NoiseTex0;
                half3 ApplyNoise( half3 inputColor, float2 uv )
                {
                    float noiseScale = 3.0;
                    float time = fmod( _Time.y, 1.0 );

                    float scrollOffset = time * 10.0;
                    float2 noiseUV = uv * noiseScale + float2( scrollOffset, scrollOffset  );

                    float noiseValue = tex2D( _NoiseTex0, noiseUV  ).r;
                    half3 finalColor = inputColor * clamp( noiseValue, 0.5, 1.0 ); 

                    float t = noiseValue;

                    finalColor *= lerp( 1.0, 2.0, t);

                    return finalColor;
                }
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv0 : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  uv2 : TEXCOORD2;
                    float2  uvLightmap : TEXCOORD3;
                    float4 shadowCoord : TEXCOORD4;
                    float4  color : COLOR;
                };
                
                float4 _MainTex_ST;
                float4 _BlendTex1_ST;
                float4 _BlendTex2_ST;
                // uniform float4 unity_LightmapST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv0 = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = TRANSFORM_TEX (v.texcoord, _BlendTex1);
                    o.uv2 = TRANSFORM_TEX (v.texcoord, _BlendTex2);
                    o.uvLightmap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                
                sampler2D   _GradientTex;
                float       _RangeMin;
                float       _RangeMax;
                float       _ThermographicBrightness; //< global variable used with all thermographic shaders

                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLightmap);
                    lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
                    
                    half4 mainColor = (tex2D(_MainTex, i.uv0) * i.color.r) + 
                                    (tex2D(_BlendTex1, i.uv1) * i.color.g) + 
                                    (tex2D(_BlendTex2, i.uv2) * i.color.b);
                    
                    mainColor.rgb = ApplyShadows( mainColor.rgb, i.shadowCoord );

                    half luminance = lerp(_RangeMin, _RangeMax, Luminance(lightmapColor.rgb*mainColor.rgb));

                    half3 thermoColor = _ThermographicBrightness*tex2D(_GradientTex, float2(luminance, 0)).rgb;

                    return half4( thermoColor.rgb, 1 );
                }
            ENDCG
    
        }   //< Pass
        
        // Simple lightmaping iOS (encoded in 24-bit RGB)
        Pass 
        {
            Tags { "LightMode" = "VertexLM" }
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers  xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                #include "Shadows.cginc"

                sampler2D _NoiseTex0;
                half3 ApplyNoise( half3 inputColor, float2 uv )
                {
                    float noiseScale = 3.0;
                    float time = fmod( _Time.y, 1.0 );

                    float scrollOffset = time * 10.0;
                    float2 noiseUV = uv * noiseScale + float2( scrollOffset, scrollOffset );

                    float noiseValue = tex2D( _NoiseTex0, noiseUV  ).r;
                    half3 finalColor = inputColor * clamp( noiseValue, 0.5, 1.0 ); 

                    float t = noiseValue;

                    finalColor *= lerp( 1.0, 2.0, t);

                    return finalColor;
                }
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv0 : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  uv2 : TEXCOORD2;
                    float2  uvLightmap : TEXCOORD3;
                    float4 shadowCoord : TEXCOORD4;
                    float4  color : COLOR;
                };
                
                float4 _MainTex_ST;
                float4 _BlendTex1_ST;
                float4 _BlendTex2_ST;
                // uniform float4 unity_LightmapST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv0 = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = TRANSFORM_TEX (v.texcoord, _BlendTex1);
                    o.uv2 = TRANSFORM_TEX (v.texcoord, _BlendTex2);
                      
                    o.uvLightmap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                
                sampler2D   _GradientTex;
                float       _RangeMin;
                float       _RangeMax;
                float       _ThermographicBrightness; //< global variable used with all thermographic shaders


                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = 2.0 * UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLightmap);
                    
                    half4 mainColor = (tex2D(_MainTex, i.uv0) * i.color.r) + 
                                    (tex2D(_BlendTex1, i.uv1) * i.color.g) + 
                                    (tex2D(_BlendTex2, i.uv2) * i.color.b);
                                                            
                    half luminance = lerp(_RangeMin, _RangeMax, Luminance(lightmapColor.rgb*mainColor.rgb));

                    half3 thermoColor = _ThermographicBrightness*tex2D(_GradientTex, float2(luminance, 0)).rgb;
                    
                    thermoColor.rgb = ApplyShadows( thermoColor.rgb, i.shadowCoord );

                    return half4( thermoColor.rgb, 1 );             
                }
            ENDCG
        }
    }   
}
