Shader "GLU/Diffuse - Unlit" 
{
    Properties 
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _MainTex;
        
            struct VertOut
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
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
                
                float3 diffuseTexture = tex2D( _MainTex, input.uv ).rgb;
                OUT.color = float4( diffuseTexture, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
