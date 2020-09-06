// Simplified Multiply Particle shader. Differences from regular Multiply Particle one:
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask
// - no fog

Shader "GLU/Decal - ZWrite Off"
{
    Properties 
    {
        _MainTex ("Particle Texture", 2D) = "white" {}
    }

    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Cull Back
        Blend Zero SrcColor
        //ZTest LEqual
        ZWrite Off
        Lighting Off 
        Fog { Mode Off }
        
        // Offset the final depth of the geometry so that it is closer
        // to the camera so we have a better chance of not having any Z fighting.
        Offset 0,-10 

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p

			#include "UnityCG.cginc"

            sampler2D _MainTex;

            struct VertOut
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
				float4 color : COLOR;
            };

            VertOut v( float4 vertex : POSITION, float2 texcoord : TEXCOORD0, float4 color : COLOR )
            {
                VertOut OUT;

                OUT.vertex = mul( UNITY_MATRIX_MVP, vertex ); 
                OUT.texcoord = texcoord;

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

                OUT.color = float4( finalColor, 1.0 );

                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
