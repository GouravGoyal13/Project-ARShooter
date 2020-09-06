// Simplified Multiply Particle shader. Differences from regular Multiply Particle one:
// - no Smooth particle support
// - no AlphaTest
// - no ColorMask

Shader "GLU/Particles/Additive, No Fog"
{
    Properties 
    {
        _MainTex ("Particle Texture", 2D) = "white" {}
    }

    SubShader 
    {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog {Mode Off}

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p

			#include "UnityCG.cginc"

            sampler2D _MainTex;
			float4 _MainTex_ST;

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
                OUT.texcoord = texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
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

				float3 finalColor = textureColor.rgb * input.color;

                OUT.color = float4( finalColor, textureColor.a );

                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
