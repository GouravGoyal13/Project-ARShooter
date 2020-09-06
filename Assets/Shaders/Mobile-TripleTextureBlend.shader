Shader "GLU/Triple Texture Blend" 
{
    Properties
    {
        _MainTex    ("Texture 1", 2D) = "white" {}
        _BlendTex1  ("Texture 2", 2D) = "white" {}
        _BlendTex2  ("Texture 3", 2D) = "white" {}

		[MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 400
        Pass 
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
            #pragma exclude_renderers xbox360
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
			#include "Shadows.cginc"
            
            struct v2f 
            {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
                float4 shadowCoord : TEXCOORD1;
                #ifndef LIGHTMAP_OFF
                    float2  uv1 : TEXCOORD2;
                    UNITY_FOG_COORDS(3)
                #else
                    UNITY_FOG_COORDS(2)
                #endif
                float4  color : COLOR;
            };
            
            float4 _MainTex_ST;
            sampler2D _MainTex;
            sampler2D _BlendTex1;
            sampler2D _BlendTex2;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                
				o.shadowCoord = CalculateShadowCoordinate(v.vertex);

                UNITY_TRANSFER_FOG(o,o.pos);
                
                o.color = v.color;
                return o;
            }
            
            half4 frag (v2f i) : COLOR
            {
                half4 cout = (tex2D(_MainTex, i.uv) * i.color.r) + 
                             (tex2D(_BlendTex1, i.uv) * i.color.g) + 
                             (tex2D(_BlendTex2, i.uv) * i.color.b);
                                    
				#ifndef LIGHTMAP_OFF
	                half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
	                half3 lightmapRGB = DecodeLightmap(lightmapColor);
	                cout.rgb *= lightmapRGB.rgb;
                #endif
                
                cout.rgb = ApplyShadows( cout.rgb, i.shadowCoord );

                UNITY_APPLY_FOG(i.fogCoord, cout);

                cout.a = 1;

                return cout;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Pass 
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members tangent)
            #pragma exclude_renderers xbox360
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct v2f 
            {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
                #ifndef LIGHTMAP_OFF
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                #else
                    UNITY_FOG_COORDS(1)
                #endif
                float4  color : COLOR;
            };
            
            float4 _MainTex_ST;
            sampler2D _MainTex;
            sampler2D _BlendTex1;
            sampler2D _BlendTex2;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                #ifndef LIGHTMAP_OFF
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                
                UNITY_TRANSFER_FOG(o,o.pos);
                
                o.color = v.color;
                return o;
            }
            
            half4 frag (v2f i) : COLOR
            {
                half4 cout = (tex2D(_MainTex, i.uv) * i.color.r) + 
                             (tex2D(_BlendTex1, i.uv) * i.color.g) + 
                             (tex2D(_BlendTex2, i.uv) * i.color.b);
                                    
                #ifndef LIGHTMAP_OFF
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
	                half3 lightmapRGB = DecodeLightmap(lightmapColor);
	                cout.rgb *= lightmapRGB.rgb;
	            #endif

                UNITY_APPLY_FOG(i.fogCoord, cout);

                cout.a = 1;

                return cout;
            }
            ENDCG
        }
    }
    
    Fallback "Mobile/Unlit (Supports Lightmap)"
}
