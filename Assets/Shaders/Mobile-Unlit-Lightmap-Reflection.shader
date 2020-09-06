Shader "GLU/Unlit (Supports Lightmap and Reflections)"  
{
    Properties
    {
        _MainTex    ("Texture 1", 2D) = "white" {}
		_EnvironmentMap("Environment Map", CUBE) = "black" {}
		[MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 0		
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        		
        Pass 
        {            
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

				#pragma shader_feature SELFILUM
                
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
					float4 shadowCoord : TEXCOORD3;
                    float4  color : COLOR;
					float3 reflection : TEXCOORD4;
                };
                
				sampler2D _MainTex;
                float4 _MainTex_ST;
				samplerCUBE _EnvironmentMap;

                // uniform float4 unity_LightmapST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    UNITY_TRANSFER_FOG(o,o.pos);

					o.shadowCoord = CalculateShadowCoordinate( v.vertex );

					float3 worldPos = mul(_Object2World, v.vertex).xyz;
					float3 viewDir = worldPos - _WorldSpaceCameraPos.xyz;
					float3 worldNormal = normalize(mul((float3x3)_Object2World, v.normal));
					float3 reflection = normalize(reflect(viewDir, worldNormal));
					o.reflection = reflection;

                    o.color = v.color;					
                    return o;
                }
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);					
					float4 reflectionColor = texCUBE(_EnvironmentMap, i.reflection);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);					
					half a = albedo.a;
					half3 c = reflectionColor * a + albedo.rgb * (1 - a);
					c = c * lightmapRGB.rgb;                   
					c = ApplyShadows( c, i.shadowCoord );

                    UNITY_APPLY_FOG(i.fogCoord, c.rgb);

                    return half4( c.rgb, 1);
                }
            ENDCG
    
        }
    }
    
    Fallback "Mobile/Unlit (Supports Lightmap)"
}
