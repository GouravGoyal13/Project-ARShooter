// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable

// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "GLU/Transparent/Unlit With Custom Fog (Supports Lightmap)" 
{
    Properties 
    {
        _MainTex    ("Texture 1", 2D) = "white" {}
        
        _MinFogFactor ("Min Fog Factor", Float) = 0.00
        _MaxFogFactor ("Max Fog Factor", Float) = 0.70
        
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 200
        
        Fog { Mode Off }
        
        AlphaTest Greater 0
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
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
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  camToVertLength : TEXCOORD2;
                    float4  color : COLOR;
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    o.camToVertLength.x = length( mul( UNITY_MATRIX_MV, v.vertex ).xyz );
                    
                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                
                half4 unity_FogStart;
                half4 unity_FogEnd;
                
                float _MinFogFactor;
                float _MaxFogFactor;
                
                half4 frag (v2f i) : COLOR
                {                   
                    half4 albedo = tex2D(_MainTex, i.uv);
                    
                    half3 c = albedo.rgb;
                    float t = i.camToVertLength.x / ( abs( unity_FogEnd.x - unity_FogStart.x ) );
                    t = clamp( t, _MinFogFactor, _MaxFogFactor );
                    
                    c = lerp( c, unity_FogColor.rgb, t);
                                                                                                                        
                    return half4( c.rgb, albedo.a);
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
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  camToVertLength : TEXCOORD2;
                    float4  color : COLOR;
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
                    
                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                
                half4 unity_FogStart;
                half4 unity_FogEnd;
                
                float _MinFogFactor;
                float _MaxFogFactor;
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    //lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
                    lightmapColor.rgb = DecodeLightmap(lightmapColor);

                    half4 albedo = tex2D(_MainTex, i.uv);
                                        
                    half3 c = lightmapColor.rgb*albedo.rgb;
                    
                    float t = i.camToVertLength.x / ( abs( unity_FogEnd.x - unity_FogStart.x ) );
                    t = clamp( t, _MinFogFactor, _MaxFogFactor );
                    
                    c = lerp( c, unity_FogColor.rgb, t );
                    
                    return half4( c.rgb, albedo.a);
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
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    float2  camToVertLength : TEXCOORD2;
                    float4  color : COLOR;
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
                    
                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                
                half4 unity_FogStart;
                half4 unity_FogEnd;
                
                float _MinFogFactor;
                float _MaxFogFactor;
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = 2.0 * UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                                        
                    half3 c = lightmapColor.rgb*albedo.rgb;
                    
                    float t = i.camToVertLength.x / ( abs( unity_FogEnd.x - unity_FogStart.x ) );
                    t = clamp( t, _MinFogFactor, _MaxFogFactor );
                    
                    c = lerp( c, unity_FogColor.rgb, t );
                    
                    return half4( c.rgb, albedo.a);
                }
            ENDCG
        }
    }
    
    Fallback "Mobile/Unlit (Supports Lightmap)"
}
