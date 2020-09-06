Shader "GLU/Multi Layer Animated Skybox (Verion 2)" 
{
    Properties 
    {
        _TextureLayer0 ("Texture Layer 0 (Uses UV Channel 1)", 2D) = "white" {}
        _TextureLayer1 ("Texture Layer 1 (Uses UV Channel 1)", 2D) = "black" {}
        _TextureLayer2 ("Texture Layer 2 (Uses UV Channel 2)", 2D) = "black" {}

        _LayerMovement ("Layer Movement Direction And Speed (Layer1 = xy, Layer 2 = zw) (Uses UV Channel 2)", VECTOR) = (0,0,0,0)
    }

    SubShader 
    {
        Tags { "Queue"="Background" "RenderType"="Background" }  

        Pass
        {
            Cull Off 
            ZWrite Off
            Lighting Off
            Fog { Mode Off }

            CGPROGRAM
            #pragma vertex v
            #pragma fragment p

            sampler2D _TextureLayer0;

            sampler2D _TextureLayer1;
            float4 _TextureLayer1_ST;

            sampler2D _TextureLayer2;
            float4 _TextureLayer2_ST;
            
            float4 _LayerMovement;

            struct VertOut
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float4 layer0And1UVs : TEXCOORD1;
                float4 color : COLOR;
            };

            VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, float2 uv2 : TEXCOORD1, float4 color : COLOR  )
            {
                VertOut OUT;

                OUT.position = mul( UNITY_MATRIX_MVP, position ); 

                float2 uvLayer1 = (uv.xy * _TextureLayer1_ST.xy + _TextureLayer1_ST.zw) + ( _Time.y * _LayerMovement.xy );
                float2 uvLayer2 = (uv2.xy * _TextureLayer2_ST.xy + _TextureLayer2_ST.zw) + ( _Time.y * _LayerMovement.zw );

                OUT.uv = uv;
                OUT.layer0And1UVs = float4( uvLayer1.x, uvLayer1.y, uvLayer2.x, uvLayer2.y );
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

                float3 finalColor = (tex2D(_TextureLayer0, input.uv)    * input.color.r) + 
                (tex2D(_TextureLayer1, input.layer0And1UVs.xy)          * input.color.g) + 
                (tex2D(_TextureLayer2, input.layer0And1UVs.zw)          * input.color.b);

                OUT.color = float4( finalColor, 1.0 );

                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
