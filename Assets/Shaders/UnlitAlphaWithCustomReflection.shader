Shader "GLU/Unlit Alpha With Custom Reflection" 
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _CubeMap ("Cube Map", CUBE ) = "white" {}
        _CubeMapMask ("Cube Map Mask", 2D ) = "white" {}
        _Normal ("Normal", VECTOR ) = (0.0, 0.0, 1.0, 0.0 )
        _CameraPosition ("Camera Position", VECTOR ) = (0.0, 0.0, 0.0, 0.0 )
        _Amount ("Amount", Float) = 1.0
        _CubeMapIntensity ("Cubemap Intensity", Float) = 1.0
    }
    SubShader 
    {
        Tags { "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater .01
        ColorMask RGB
        Cull Off Lighting Off ZWrite Off
        Fog { Mode Off }

        Pass
        {
        
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _MainTex;
            samplerCUBE _CubeMap;
            sampler2D _CubeMapMask;
            
            float4 _Normal;
            float4 _CameraPosition;
            float _Amount;
            float _CubeMapIntensity;
            float _TimeUI;
        
            struct VertOut
            {
                float4 position : POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                float3 worldPos = mul( _Object2World, position ).xyz;
                float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.worldPos = worldPos + (normalVec * _Amount);
                OUT.worldNormal = normalVec;
                OUT.uv = uv;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float3 cameraPosVec = _CameraPosition.xyz;
                
                float3 viewDir = normalize( input.worldPos - cameraPosVec );
                float3 reflection = normalize( reflect( viewDir, _Normal.xyz ) );
                
                float4 diffuseColor = tex2D( _MainTex, input.uv );
                float4 cubeMapMask = tex2D( _CubeMapMask, input.uv );
                float4 cubeColor = texCUBE( _CubeMap, reflection );
                
                float finalAlpha = diffuseColor.a;
                float4 finalColor = diffuseColor + (cubeColor * cubeMapMask.r)*_CubeMapIntensity;
                finalColor.a = finalAlpha;
                
                OUT.color = finalColor;
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}

