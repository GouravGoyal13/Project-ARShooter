Shader "GLU/Transparent/Unlit Animated Grass (Supports Lightmap)" 
{
    Properties
    {
        _MainTex ("Main Texture (Vertex Color Red controls motion.  The Object's Z vertex controls the randomness of the motion.)", 2D) = "white" {}
        _MaxSpeed ("Max Speed", Float) = 1.0
        _TextureWidthScalar ("Texture Width Scalar", Float ) = 30.0

		[MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300
        Lighting Off
        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        ColorMask RGB
        Cull Off Lighting Off ZWrite Off
        Cull Back
        
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
				#include "Shadows.cginc"

                sampler2D _MainTex;
                float _MaxSpeed;
                float _TextureWidthScalar;
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                    ////float4 shadowCoord : TEXCOORD2;
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    float2 uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    // Make sure we can't divide by zero.
                    float widthScalar = max( _TextureWidthScalar, 0.001 );
                    // Add the object space vertex z into the mix to give some randomization.
                    float xOffset = (sin( v.vertex.z + (_Time.y * _MaxSpeed)) * v.color.r) / widthScalar;
                    uv += float2( xOffset, 0.0 );
                    o.uv = uv;
                    
                    UNITY_TRANSFER_FOG(o,o.pos);

                    ////o.shadowCoord = CalculateShadowCoordinate( v.vertex );
                    
                    return o;
                }
                
                half4 frag (v2f i) : COLOR
                {              
                    half4 albedo = tex2D(_MainTex, i.uv);

                    ////albedo.rgb = ApplyShadows( albedo.rgb, i.shadowCoord );
                                                                                    
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
				#include "Shadows.cginc"
                
                sampler2D _MainTex;
                float _MaxSpeed;
                float _TextureWidthScalar;
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                    ////float4 shadowCoord : TEXCOORD3;
                };
                
                float4 _MainTex_ST;                
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    float2 uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    // Make sure we can't divide by zero.
                    float widthScalar = max( _TextureWidthScalar, 0.001 );
                    // Add the object space vertex z into the mix to give some randomization.
                    float xOffset = (sin( v.vertex.z + (_Time.y * _MaxSpeed)) * v.color.r) / widthScalar;
                    uv += float2( xOffset, 0.0 );
                    o.uv = uv;
                    
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    UNITY_TRANSFER_FOG(o,o.pos);
                    
                    ////o.shadowCoord = CalculateShadowCoordinate( v.vertex );
                    
                    return o;
                }
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                    half3 c = lightmapRGB*albedo.rgb;
                    
                    ////c = ApplyShadows( c, i.shadowCoord );
                    
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
				#include "Shadows.cginc"
                
                sampler2D _MainTex;
                float _MaxSpeed;
                float _TextureWidthScalar;
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                    float2  uv1 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                    ////float4 shadowCoord : TEXCOORD3;
                };
                
                float4 _MainTex_ST;
                v2f vert (appdata_full v)
                {
                    v2f o;
                    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                    float2 uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                    
                    // Make sure we can't divide by zero.
                    float widthScalar = max( _TextureWidthScalar, 0.001 );
                    // Add the object space vertex z into the mix to give some randomization.
                    float xOffset = (sin( v.vertex.z + (_Time.y * _MaxSpeed)) * v.color.r) / widthScalar;
                    uv += float2( xOffset, 0.0 );
                    o.uv = uv;
                    
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                    
                    UNITY_TRANSFER_FOG(o,o.pos);
                    
                    ////o.shadowCoord = CalculateShadowCoordinate( v.vertex );
                    
                    return o;
                }
                
                half4 frag (v2f i) : COLOR
                {
                    half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
                    half3 lightmapRGB = DecodeLightmap(lightmapColor);
                    
                    half4 albedo = tex2D(_MainTex, i.uv);
                                        
                    half3 c = albedo.rgb * lightmapRGB.rgb;
                    
                    ////c = ApplyShadows( c, i.shadowCoord );
                    
                    UNITY_APPLY_FOG(i.fogCoord, c);
                    
                    return half4( c.rgb, albedo.a );
                }
            ENDCG
        }
    }
    
    //Fallback "Mobile/Unlit (Supports Lightmap)"
}
