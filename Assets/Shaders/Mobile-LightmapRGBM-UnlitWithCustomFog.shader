// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Unlit shader. Simplest possible textured shader.
// - SUPPORTS RGBM lightmap
// - no lighting
// - no per-material color

Shader "GLU/Unlit With Custom Fog (RGBM Only Lightmap)" 
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        //_Lightmap ("Lightmap (RGBM)", 2D) = "white" {}
        
        _MinFogFactor ("Min Fog Factor", Float) = 0.00
        _MaxFogFactor ("Max Fog Factor", Float) = 0.70
    }

    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        
        Fog { Mode Off }
        
        Pass 
        {
            Tags { "LightMode" = "VertexLMRGBM" }
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers d3d11 xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  camToVertLength : TEXCOORD2;
                };
                
                float4 _MainTex_ST;
                // uniform float4 unity_LightmapST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);                    
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    o.camToVertLength.x = length( mul( UNITY_MATRIX_MV, v.vertex ).xyz );
                    
                    return o;
                }
                
                
                sampler2D _MainTex;
                // uniform sampler2D unity_Lightmap;
                
                uniform half4 unity_FogStart;
                uniform half4 unity_FogEnd;
                
                float _MinFogFactor;
                float _MaxFogFactor;
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
                    
                    half4 texColor = tex2D (_MainTex, i.uv);                    
                    half3 c = lightmapColor.rgb*texColor.rgb;
                    
                    float t = i.camToVertLength.x / ( abs( unity_FogEnd.x - unity_FogStart.x ) );
                    t = clamp( t, _MinFogFactor, _MaxFogFactor );
                    
                    c = lerp( c, unity_FogColor.rgb, t);
                    
                    return half4( c.rgb, 1);
                }
            ENDCG
        }   //< Pass
        
        
        Pass 
        {
            Tags { "LightMode" = "VertexLM" }
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers d3d11 xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  camToVertLength : TEXCOORD2;
                };
                
                float4 _MainTex_ST;
                // uniform float4 unity_LightmapST;
                
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);                    
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    o.camToVertLength.x = length( mul( UNITY_MATRIX_MV, v.vertex ).xyz );
                    
                    return o;
                }
                
                
                sampler2D _MainTex;
                // uniform sampler2D unity_Lightmap;
                
                half4 unity_FogStart;
                half4 unity_FogEnd;
                
                float _MinFogFactor;
                float _MaxFogFactor;
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
                    
                    half4 texColor = tex2D (_MainTex, i.uv);                    
                    half3 c = lightmapColor.rgb*texColor.rgb;
                    
                    float t = i.camToVertLength.x / ( abs( unity_FogEnd.x - unity_FogStart.x ) );
                    t = clamp( t, _MinFogFactor, _MaxFogFactor );
                    
                    c = lerp( c, unity_FogColor.rgb, t);
                    
                    return half4( c.rgb, 1);
                }
            ENDCG
        }   //< Pass
    }
}



