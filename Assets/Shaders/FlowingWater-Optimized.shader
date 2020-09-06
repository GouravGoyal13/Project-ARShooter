Shader "GLU/Flowing Water (Optimized)"
{
    Properties
    {
        _WaterCubemap ("Water Cubemap (RGB)", CUBE) = "white" {}
        _FlowMap ("Flow Map (Controlled By Z)", 2D) = "white" {}
        _SpecMask ("Specular Mask (Red Specifies where Spec can be seen, Alpha Controls Water Transparency)", 2D) = "black" {}
        _ColorTint ("Color Tint (Alpha Controls Tint Intensity)", 2D) = "white" {}
        _FlowDirection ("Flow Direction", VECTOR) = (0,0,0,0)
        _ColorTintFlowDirection  ("Color Tint Flow Direction", VECTOR) = (0,0,0,0)
        _SpecColor ("Specular Color (Alpha Controls Intensity)", COLOR) = (0,0,0,1)
        _SpecIntensity ("Specular Threshold (Between FlowMap Color and Wave Map Color", FLOAT) = 0.97
        _MinMaxSpec ("Min Max Specular", VECTOR) = ( 0.00, 1.0, 0.00, 0.00)
    }
    SubShader
    {
        Tags { "Queue"="Geometry" }
        
        Fog { Mode Off }

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
           
            #include "UnityCG.cginc"

            samplerCUBE _WaterCubemap;
            float4 _WaterCubemap_ST;
            sampler2D _FlowMap;
            sampler2D _WaveMap;
            sampler2D _SpecMask;
            float4 _SpecMask_ST;
            sampler2D _ColorTint;
            float4x4 _RotMatrix;
            float4 _FlowDirection;
            float4 _ColorTintFlowDirection;
            float4 _SpecColor;
            float _SpecIntensity;
            float4 _MinMaxSpec;

            struct VertOut
            {
                float4 position         : POSITION;
                float3 worldPos         : TEXCOORD0;
                float3 worldNormal      : TEXCOORD1;
                float2 uv               : TEXCOORD3;
                float4 pos              : TEXCOORD4;
            };
           
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
               
                float4x4 mat = mul( _RotMatrix, _Object2World );
               
                float3 worldPos = mul( mat, position ).xyz;
                float3 worldNormal = normalize( mul( (float3x3)(mat), norm ) );
               
                OUT.position = mul( UNITY_MATRIX_MVP, position );
               
                OUT.worldPos = worldPos;
                OUT.worldNormal = worldNormal;
                OUT.uv = uv.xy;
                OUT.pos = OUT.position;
               
                return OUT;
            }
           
            struct PixelOut
            {
                float4 color : COLOR;
            };
           
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
               
                float2 fuv = input.uv + (float2(_FlowDirection.xy) * _Time.y);
                float2 cfuv = input.uv + (float2(_ColorTintFlowDirection.xy) * _Time.y);
               
                float4 diffuseColor = tex2D( _FlowMap, input.uv );
                float4 flowMapColor = tex2D( _FlowMap, fuv * _FlowDirection.z  );
               
                float3 originalWorldCamPos = mul( _RotMatrix, float4( _WorldSpaceCameraPos, 1.0) ).xyz;
                float3 worldCamPos = originalWorldCamPos + flowMapColor.xyz;
               
                float3 worldNormal = normalize( input.worldNormal );                                                 
                float3 viewDir = normalize( input.worldPos - worldCamPos );
                float3 reflection = normalize( reflect( viewDir, worldNormal ) );
                                                                               
                float4 colorMaskSample = tex2D( _ColorTint, cfuv );
               
                float4 originalReflectionColor = texCUBE( _WaterCubemap, reflection );
                float4 reflectionColor = originalReflectionColor + float4((colorMaskSample.rgb * colorMaskSample.a), 1.00);
               
                float4 globalSpecColor = tex2D( _SpecMask, input.uv * _SpecMask_ST.xy + _SpecMask_ST.zw );
               
                float4 finalColor = reflectionColor;
               
                OUT.color = finalColor;
               
                return OUT;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}