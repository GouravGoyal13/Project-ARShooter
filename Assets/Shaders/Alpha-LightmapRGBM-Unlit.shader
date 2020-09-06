// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Unlit shader. Simplest possible textured shader.
// - SUPPORTS lightmap
// - no lighting
// - no per-material color

Shader "GLU/Transparent/Unlit (RGBM Only Lightmap)" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
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
				// sampler2D unity_Lightmap;
				half4 frag (v2f i) : COLOR
				{
					half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
					lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
					
					half4 albedo = tex2D(_MainTex, i.uv);
					    				
				    half3 c = lightmapColor.rgb*albedo.rgb;
				    
				    return half4( c.rgb, albedo.a);
				}
			ENDCG
	
		}	//< Pass
		
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
				// sampler2D unity_Lightmap;
				half4 frag (v2f i) : COLOR
				{
					half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
					lightmapColor.rgb = (8.0 * lightmapColor.a) * lightmapColor.rgb; // Lightmapped, encoded as RGBM
					
					half4 albedo = tex2D(_MainTex, i.uv);
					    				
				    half3 c = lightmapColor.rgb*albedo.rgb;
				    
				    return half4( c.rgb, albedo.a);
				}
			ENDCG
		}
	}	
}



