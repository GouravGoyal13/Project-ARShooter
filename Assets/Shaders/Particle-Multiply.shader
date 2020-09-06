// Simplified Multiply Particle shader. Differences from regular Multiply Particle one:
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "GLU/Particles/Multiply"
{
    Properties 
    {
        _MainTex ("Particle Texture", 2D) = "white" {}
    }

    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend Zero SrcColor
        Cull Off Lighting Off ZWrite Off Fog { Color (1,1,1,1) }

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

            sampler2D _MainTex;

            struct VertOut
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 color : COLOR;
            };

            VertOut v( float4 vertex : POSITION, float2 texcoord : TEXCOORD0, float4 color : COLOR )
            {
                VertOut OUT;

                OUT.vertex = mul( UNITY_MATRIX_MVP, vertex ); 
                OUT.texcoord = texcoord;

				UNITY_TRANSFER_FOG(OUT, OUT.vertex);

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

                float3 constantColor = float3( 1.0, 1.0, 1.0 );
                float4 textureColor = tex2D(_MainTex, input.texcoord);

                float3 finalColor = lerp( textureColor.rgb, constantColor * input.color.rgb, textureColor.a * input.color.a);

				UNITY_APPLY_FOG(input.fogCoord, finalColor.rgb);
                OUT.color = float4( finalColor, 1.0 );

                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
