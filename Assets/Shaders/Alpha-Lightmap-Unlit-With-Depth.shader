Shader "GLU/Transparent/Unlit With Depth (Supports Lightmap)" 
{
    Properties
    {
        _MainTex    ("Main Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Lighting Off
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaTest Greater .01
		ColorMask RGB
		Lighting Off
		Cull Back
        
        // Took out the ZWrite false so that depth is taken into consideration.
        
        // Non-lightmapped
        Pass 
        {
            Tags { "LightMode" = "Vertex" }
            
            CGPROGRAM
                // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members channel)
                #pragma exclude_renderers  xbox360
                // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
                #pragma exclude_renderers xbox360
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fog
                
                #include "UnityCG.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    UNITY_TRANSFER_FOG(o,o.pos);
                    
                    return o;
                }
                
                
                sampler2D _MainTex;
                half4 frag (v2f i) : COLOR
                {                   
                    half4 albedo = tex2D(_MainTex, i.uv);
                                                                                    
                    UNITY_APPLY_FOG(i.fogCoord, albedo.rgb);

                    return half4( albedo );
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
                #pragma multi_compile_fog
                
                #include "UnityCG.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                };
                
                float4 _MainTex_ST;                
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    UNITY_TRANSFER_FOG(o,o.pos);
                    
                    return o;
                }
                
                
                sampler2D _MainTex;
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                    half3 c = lightmapRGB*albedo.rgb;
                    
                    UNITY_APPLY_FOG(i.fogCoord, c);
                    
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
                #pragma multi_compile_fog
                
                #include "UnityCG.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    UNITY_TRANSFER_FOG(o,o.pos);
                    
                    return o;
                }
                
                sampler2D _MainTex;
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                                        
                    half3 c = albedo.rgb * lightmapRGB.rgb;
                    
                    UNITY_APPLY_FOG(i.fogCoord, c);
                    
                    return half4( c.rgb, albedo.a );
//
//              FRAGMENT_SETUP(s)
//              UnityLight mainLight = MainLight (s.normalWorld);
//              half atten = SHADOW_ATTENUATION(i);
//              
//              half occlusion = Occlusion(i.tex.xy);
//              UnityGI gi = FragmentGI (
//                  s.posWorld, occlusion, i.ambientOrLightmapUV, atten, s.oneMinusRoughness, s.normalWorld, s.eyeVec, mainLight);
//
//              half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
//              c.rgb += UNITY_BRDF_GI (s.diffColor, s.specColor, s.oneMinusReflectivity, s.oneMinusRoughness, s.normalWorld, -s.eyeVec, occlusion, gi);
//              c.rgb += Emission(i.tex.xy);
//
//              UNITY_APPLY_FOG(i.fogCoord, c.rgb);
//              return OutputForward (c, s.alpha);
                
                                
                }


            ENDCG
        }
    }
    
    Fallback "Mobile/Unlit (Supports Lightmap)"
}
