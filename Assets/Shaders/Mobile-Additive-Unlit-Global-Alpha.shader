Shader "GLU/Transparent/Additive/Unlit (Global Alpha and No Alpha Channel and No Fog)"
{
    Properties 
    {
        _MainTex ("Main Texture (RGB)", 2D) = "white" {}
        _GlobalAlpha ("Alpha", RANGE(0.00, 1.0)) = 1.0
    }
    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        
        ZTest Always Cull Off ZWrite Off
        Fog { Mode Off }    
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GlobalAlpha;
        
            struct VertOut
            {
                float4 position     : POSITION;
                float2 uv           : TEXCOORD0;
            };
            
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float4 textureColor = tex2D( _MainTex, input.uv );
                
                float3 finalColor = textureColor.rgb * _GlobalAlpha;
                
                OUT.color = float4( finalColor, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
