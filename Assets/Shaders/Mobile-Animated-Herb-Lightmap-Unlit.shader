Shader "GLU/Transparent/Unlit Animated Herb (Supports Lightmap)" 
{
    Properties
    { 
        [Toggle(LIGHTMAP)] _Lightmap("Lightmap enable", float) = 0		
        [Toggle(VERTEXCOLOR)] _VertexColor("Vertex color enable", float) = 0		
        [Enum(Off, 0, Front, 1, Back, 2)] _Cull("Cull", float) = 0
        [KeywordEnum(Off, R, A)] _MOTION_CHANNEL("Motion Channel", int) = 0

        _MainTex ("Main Texture (Vertex Color [Motion Channel] controls motion. The Object's Z vertex controls the randomness of the motion.)", 2D) = "white" {}
        _MaxSpeed ("Max Speed", Float) = 1.0
        _TextureWidthScalar ("Texture Width Scalar", Float ) = 30.0
        _TintColor("Color", Color) = (1, 1, 1, 1)
		_ExtendedParams("Extended Params (x - intensity of self-illumination, y - intensity of lightmap)", Vector) = (0, 1, 0, 0)
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300        
        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        ColorMask ARGB
        Lighting Off
		ZWrite Off
        Cull [_Cull]
        
        // Simple lightmaping iOS (encoded in 24-bit RGB)
        Pass 
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fog
                #pragma shader_feature LIGHTMAP
                #pragma shader_feature VERTEXCOLOR
                #pragma shader_feature _MOTION_CHANNEL_OFF _MOTION_CHANNEL_R _MOTION_CHANNEL_A
                
                #include "UnityCG.cginc"
                #include "Shadows.cginc"
                
                sampler2D _MainTex;
                float _MaxSpeed;
                float _TextureWidthScalar;
                float4 _TintColor;
				float4 _ExtendedParams;
                
                struct v2f 
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
#if LIGHTMAP
                    float2  uv1 : TEXCOORD1;
#endif 
					float4  color : COLOR;
                    UNITY_FOG_COORDS(2)                    
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

#if defined(_MOTION_CHANNEL_A)
                    float mc = v.color.a;
#elif defined(_MOTION_CHANNEL_R)
                    float mc = v.color.r;
#endif

#if defined(_MOTION_CHANNEL_R) || defined(_MOTION_CHANNEL_A)
                    float xOffset = (sin(v.vertex.z + (_Time.y * _MaxSpeed)) * mc) / widthScalar;
                    uv += float2(xOffset, 0.0);
#endif
                    o.uv = uv;
#if LIGHTMAP
                    o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif                    
                    UNITY_TRANSFER_FOG(o, o.pos);
					o.color = v.color;
                    
                    return o;
                }
                
                half4 frag (v2f i) : COLOR
                {
                    half4 albedo = tex2D(_MainTex, i.uv);
                    half3 c = albedo.rgb * _TintColor.rgb;
#if VERTEXCOLOR
                    c = c * i.color;
#endif

#if LIGHTMAP
					half4 lightmapColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1);
					half3 lightmapRGB = DecodeLightmap(lightmapColor);
					c = c * (_ExtendedParams.x + lightmapRGB.rgb * _ExtendedParams.y);
#endif
                    UNITY_APPLY_FOG(i.fogCoord, c);

                    return half4(c, albedo.a);
                }
            ENDCG
        }
    }
}