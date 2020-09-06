// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "GLU/Unlit (Supports Lightmap)"  
{
    Properties
    {
        _MainTex    ("Texture 1", 2D) = "white" {}

		[MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
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
                #pragma multi_compile_fog
                
                #include "UnityCG.cginc"
				#include "Shadows.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
					float4 shadowCoord : TEXCOORD2;
                    float4  color : COLOR;
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    UNITY_TRANSFER_FOG(o,o.pos);

					o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                half4 frag (v2f i) : COLOR
                {                   
                    half4 albedo = tex2D(_MainTex, i.uv);
                    
					albedo.rgb = ApplyShadows( albedo.rgb, i.shadowCoord );

                    UNITY_APPLY_FOG(i.fogCoord, albedo.rgb);

                    return half4( albedo.rgb, 1);
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
				#include "Shadows.cginc"
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
					float4 shadowCoord : TEXCOORD3;
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
                    
                    UNITY_TRANSFER_FOG(o,o.pos);

					o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                    half3 c = lightmapRGB*albedo.rgb;
                    
					c = ApplyShadows( c, i.shadowCoord );

                    UNITY_APPLY_FOG(i.fogCoord, c.rgb);

                    return half4( c.rgb, 1);
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
                #include "Shadows.cginc"
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
					float4 shadowCoord : TEXCOORD3;
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
                    
                    UNITY_TRANSFER_FOG(o,o.pos);

					o.shadowCoord = CalculateShadowCoordinate( v.vertex );

                    o.color = v.color;
                    return o;
                }
                
                
                sampler2D _MainTex;
                sampler2D _BlendTex1;
                sampler2D _BlendTex2;
                // sampler2D unity_Lightmap;
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                                        
                    half3 c = albedo.rgb * lightmapRGB.rgb;

					c = ApplyShadows( c, i.shadowCoord );

                    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
                    
                    return half4( c.rgb, 1);
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
