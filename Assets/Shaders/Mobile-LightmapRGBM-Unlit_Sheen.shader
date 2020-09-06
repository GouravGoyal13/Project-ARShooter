// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "GLU/Unlit-ScrollingSheen (RGBM Only Lightmap)"
{
	Properties
	{
		_MainTex	("Texture 1", 2D) = "white" {}
		
		_GlowTex("GlowMap1(R)", 2D) = "white" {}
		
		// sheen properties
		_SheenTex ("SheenScroll1 (R)", 2D) = "white"{}
		_SheenColor ("Sheen Color", Color) = (1, 0, 0, 1)

		_SheenDirectionU ("Sheen Direction U", Range(-1, 1)) = 1
		_SheenDirectionV ("Sheen Direction V", Range(-1, 1)) = 0		
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
				};
				
				float4 _MainTex_ST;
				
				v2f vert (appdata_full v)
				{
				    v2f o;
				    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				    
				    return o;
				}
				
				
				sampler2D _MainTex;
				
				// sheen properties
				sampler2D _GlowTex;
				sampler2D _SheenTex;
				fixed4 _SheenColor;
				float _SheenDirectionU;
				float _SheenDirectionV;
			
				half4 frag (v2f i) : COLOR
				{					
					half4 c = tex2D (_MainTex, i.uv);
					
					//R = Sheen Amount, G = Sheen Amount, B = Sheen Amount
					half4 glowTexProperties = tex2D (_GlowTex, i.uv);

					// scrolling sheen				
					half scrollingSheen = tex2D (_SheenTex, i.uv + _Time.y*float2(_SheenDirectionU, _SheenDirectionV)).r;
					half sheenIntensity = glowTexProperties.r*scrollingSheen;
					
					// Emission
					return c + _SheenColor * saturate(sheenIntensity);
				}
			ENDCG
		}
	
		// RGBM lightmapping (PC)
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
				};
				
				float4 _MainTex_ST;
				// uniform float4 unity_LightmapST;
								
				v2f vert (appdata_full v)
				{
				    v2f o;
				    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				    
				    return o;
				}
				
				
				sampler2D _MainTex;
				sampler2D _BlendTex1;
				sampler2D _BlendTex2;
				// sampler2D unity_Lightmap;
				
				// sheen properties
				sampler2D _GlowTex;
				sampler2D _SheenTex;
				fixed4 _SheenColor;
				float _SheenDirectionU;
				float _SheenDirectionV;
				
				half4 frag (v2f i) : COLOR
				{
					half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
					lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
					
					half4 c = tex2D (_MainTex, i.uv);
					
					//R = Sheen Amount, G = Sheen Amount, B = Sheen Amount
					half4 glowTexProperties = tex2D (_GlowTex, i.uv);

					// scrolling sheen				
					half scrollingSheen = tex2D (_SheenTex, i.uv + _Time.y*float2(_SheenDirectionU, _SheenDirectionV)).r;
					half sheenIntensity = glowTexProperties.r*scrollingSheen;
					
					// Emission
					return lightmapColor*(c + _SheenColor * saturate(sheenIntensity));
				}
			ENDCG
	
		}	//< Pass
		
		// Simple lightmaping iOS (encoded in 24-bit RGB)
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
				};
				
				float4 _MainTex_ST;
				// uniform float4 unity_LightmapST;
				v2f vert (appdata_full v)
				{
				    v2f o;
				    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				    
				    return o;
				}
				
				
				sampler2D _MainTex;
				sampler2D _BlendTex1;
				sampler2D _BlendTex2;
				// sampler2D unity_Lightmap;
				
				// sheen properties
				sampler2D _GlowTex;
				sampler2D _SheenTex;
				fixed4 _SheenColor;
				float _SheenDirectionU;
				float _SheenDirectionV;
				
				half4 frag (v2f i) : COLOR
				{					
					half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
					lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
					
					half4 c = tex2D (_MainTex, i.uv);
					
					//R = Sheen Amount, G = Sheen Amount, B = Sheen Amount
					half4 glowTexProperties = tex2D (_GlowTex, i.uv);

					// scrolling sheen				
					half scrollingSheen = tex2D (_SheenTex, i.uv + _Time.y*float2(_SheenDirectionU, _SheenDirectionV)).r;
					half sheenIntensity = glowTexProperties.r*scrollingSheen;
					
					// Emission
					return lightmapColor*(c + _SheenColor * saturate(sheenIntensity));
				}
			ENDCG
		}
	}
	
	Fallback "Mobile/Unlit (Supports Lightmap)"
}
