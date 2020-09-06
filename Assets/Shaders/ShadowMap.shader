Shader "GLU/Shadows/ShadowMap"
{
    Properties
    {

    }

    SubShader
    {
        Tags { "ShadowCaster"="True" }

        Pass
        {
       		Cull Back
       		
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
            
            float _ShadowCameraFarClipPlane;
            float4x4 _ShadowMatrix;
            float4x4 _ShadowViewMatrix;
       
            struct VertOut
            {
                float4 position : POSITION;
                float4 vsPosition : TEXCOORD0;
            };
           
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;

                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.vsPosition = mul( _ShadowMatrix, mul( _Object2World, position ) );
                
                return OUT;
            }
            
            struct PixelOut
            {
                float4 color : COLOR;
            };
           
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
               	
               	float depth = clamp( (input.vsPosition.z / input.vsPosition.w) * 0.5 + 0.5, 0.00, 1.0 );
               	
               	float3 color = float3( depth, depth, depth );
               	
                OUT.color = float4( color, 1.0 );
               
                return OUT;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
