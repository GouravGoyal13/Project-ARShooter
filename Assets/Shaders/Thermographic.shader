Shader "Custom/Thermographic"
{

    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _GradientTex ("Gradient (RGB)", 2D) = "white" {}
        _RangeMin ("RangeMin", Range(0.0, 1.0)) = 0.0
        _RangeMax ("RangeMax", Range(0.0, 1.0)) = 1.0
        _GradientClamp ("GradientClamp", Range(0.0, 1.0)) = 1.0
        _Extrusion ("Extrusion", Range(0, 2)) = 0.0
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            #define GLOW_SPEED                      4.0
            #define GLOW_MIN                        6.5
            #define GLOW_MAX                        7.0

            uniform sampler2D   _MainTex;
            uniform sampler2D	_NormalTex;
            uniform sampler2D   _GradientTex;
            uniform float       _RangeMin;
            uniform float       _RangeMax;
            uniform float       _GradientClamp;
            uniform float       _Extrusion;
            float               _ThermographicBrightness; //< global variable used with all thermographic shaders
            struct vertInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent  : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct vertOutput 
            {
                float4 pos              : POSITION; 
                float2 mainTexCoord     : TEXCOORD0;
                float2 glow             : TEXCOORD1;
                float3 normal           : TEXCOORD2;
                float3 tangent          : TEXCOORD3;
                float3 bitangent        : TEXCOORD4;
                float4 worldPosition    : TEXCOORD5;
                
            };  
    
            vertOutput vert(vertInput i)
            {
                vertOutput o;
            
                float3 posWorld = mul(_Object2World, i.vertex).xyz;
                float3 viewVectorWorld = normalize(posWorld - _WorldSpaceCameraPos);

                float4 extrudedPos = i.vertex;
                extrudedPos.xyz = posWorld.xyz - (viewVectorWorld.xyz * _Extrusion);
                extrudedPos = mul(_World2Object, extrudedPos);
                
                o.pos = mul (UNITY_MATRIX_MVP, extrudedPos);
                o.mainTexCoord = i.texcoord;
                             
                // for normal map calcs
                o.normal = normalize( mul( _Object2World, float4( i.normal.xyz, 0.00 ) ) );
                o.tangent = normalize( mul( _Object2World, float4( i.tangent.xyz, 0.00 ) ) );
                o.bitangent = normalize( cross( o.normal, o.tangent ) * i.tangent.w );
                o.worldPosition = mul( _Object2World, i.vertex );

                return o;
            }
    
            half4 frag( vertOutput i ) : COLOR
            {
                float4 normalTexture = tex2D( _NormalTex, i.mainTexCoord );
                float3 normalInTangentSpace = UnpackNormal( normalTexture );
                float3x3 tagentToWorldMatrix = float3x3(normalize( i.tangent ),
                                                        normalize( i.bitangent ),
                                                        normalize( i.normal ));

                float3 normal = normalize( mul( normalInTangentSpace, tagentToWorldMatrix ) );
                float3 toCamera = normalize( _WorldSpaceCameraPos - i.worldPosition );
                float rangeMinCompliment = 1.0 - _RangeMin;
                float gu = abs(dot(normal, toCamera) * rangeMinCompliment) + (_RangeMax - rangeMinCompliment);
             
                return _ThermographicBrightness * tex2D (_GradientTex, float2(gu, 0));
			}
            
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
