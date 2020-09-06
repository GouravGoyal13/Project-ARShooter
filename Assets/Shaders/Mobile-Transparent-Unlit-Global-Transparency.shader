Shader "GLU/Transparent/Unlit (Global Transparency With Alpha Channel and No Fog)"
{
    Properties 
    {
        _MainTex ("Main Texture (RGBA)", 2D) = "white" {}
        _GlobalAlpha ("Transparency", RANGE(0.00, 1.0)) = 1.0
    }
    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        
        AlphaTest Greater .01
        ColorMask RGB
        Cull Back Lighting Off ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

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
                float4 position         : POSITION;
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
                
                float3 finalColor = textureColor.rgb;
                float finalAlpha = _GlobalAlpha * textureColor.a;
                
                OUT.color = float4( finalColor, finalAlpha );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
