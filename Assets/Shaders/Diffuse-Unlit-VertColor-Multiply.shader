Shader "GLU/Diffuse Unlit Vert Color Multiply" 
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
				float4 color: COLOR;
            };
            
            VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, float4 color : COLOR )
            {
                VertOut OUT;
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv = uv;
				OUT.color = color;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float3 finalColor = tex2D( _MainTex, input.uv ).rgb * input.color.rgb;
                OUT.color = float4( finalColor, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
