Shader "GLU/Reflection (With Spec Map)" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture", 2D) = "white" {}
        _EnvironmentMap ("Environment Map", CUBE) = "white" {}
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
        
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _DiffuseTex;
            samplerCUBE _EnvironmentMap; 
            float _RotationSpeed;
        
            struct VertOut
            {
                float4 position : POSITION;
                float3 viewDir : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };
            
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                float3 worldPos = mul( _Object2World, position ).xyz;
                float3 viewDir = worldPos - _WorldSpaceCameraPos.xyz;
                
                float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
                
                float3 reflection = reflect( viewDir, normalVec );
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.viewDir = reflection;
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
                
                float4 diffuseColor = tex2D( _DiffuseTex, input.uv );
                float4 environmentColor = texCUBE( _EnvironmentMap, input.viewDir );
                
                float3 finalColor = diffuseColor.rgb + (environmentColor.rgb * diffuseColor.a); 
                
                OUT.color = float4( finalColor, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
