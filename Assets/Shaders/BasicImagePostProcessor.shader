Shader "GLU/Texture Effects/Basic Image Post Processor"
{
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MaterialToggle] _DesaturateCurrentRender("Desaturate Current Render", Float) = 0.0

    }
    SubShader 
    {
        Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _MainTex;
            float4 _MainTex_ST;
                        
            float _DesaturateCurrentRender;
        
            struct VertOut
            {
                float4 position                     : POSITION;
                float2 uv                           : TEXCOORD0;
            };
            
            VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;

                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv  =   uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float3 mainTextureColor             = tex2D(_MainTex, input.uv);
                
                float3 finalColor = mainTextureColor;
                
                // The weights in the grayScaleFilter come from the following
                // nVidia GPU article.
                // http://http.developer.nvidia.com/GPUGems/gpugems_ch22.html
                float grayScaleFilter = float3(0.222, 0.707, 0.071);
                if( _DesaturateCurrentRender > 0.0 )
                {
                    float d = dot(mainTextureColor.rgb,  grayScaleFilter);
                    finalColor = float3( d, d, d );
                }

                OUT.color = float4( finalColor, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}

