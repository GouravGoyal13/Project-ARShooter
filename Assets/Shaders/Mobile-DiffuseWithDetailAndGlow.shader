Shader "GLU/Diffuse With Detail And Glow" 
{
    Properties
    {
        _DiffuseTex ("Diffuse Texture (Alpha Controls Specular Intensity", 2D) = "white" {}
        _NormalTex ("Normal Map (Alpha Controls Specular Glossiness)", 2D) = "white" {}

        _MinSpecularGlossiness ("Minimum Specular Glossiness", Float ) = 8.0
        _MaxSpecularGlossiness ("Maximum Specular Glossiness", Float ) = 58.0
        
        _MinDiffuseCoefficient ("Min Diffuse Coefficient (0.00 to 1.0)", Range(0.00, 1.0) ) = 0.30
        _MaxDiffuseCoefficient ("Max Diffuse Coefficient (0.00 to 1.0)", Range(0.00, 1.0) ) = 0.70

        _EffectTex ("Effect Texture (Noise Cloud on Alpha Channel Uses Red Channel as a Mask)", 2D) = "black" {}
        _NoiseScalar ("Noise Scalar (Controls Shape on Noise)", Float) = 10.0
        _NoiseDirection ("Noise Scroll Direction (Scrolls Noise which is on Alpha Channel in Effect Texture)", VECTOR) = (0.00, 0.00, 0.00, 0.00)
        _GlowChannelSpeeds ("Glow Channel Speeds (Red, Green, Blue)", VECTOR) = (0,0,0,0)
        _GlowColor0 ("Glow Color 0 (Red Channel)", COLOR) = (0,0,0,1)
        _GlowColor0PulseMin ("Glow Color 0 Pulse Min Brightness", RANGE(0.00, 1.0)) = 0.00
        _GlowColor0PulseMax ("Glow Color 0 Pulse Max Brightness", RANGE(0.00, 1.0)) = 1.00
        _GlowColor1 ("Glow Color 1 (Green Channel)", COLOR) = (0,0,0,1)
        _GlowColor1PulseMin ("Glow Color 1 Pulse Min Brightness", RANGE(0.00, 1.0)) = 0.00
        _GlowColor1PulseMax ("Glow Color 1 Pulse Max Brightness", RANGE(0.00, 1.0)) = 1.00
        _GlowColor2 ("Glow Color 2 (Blue Channel)", COLOR) = (0,0,0,1)
        _GlowColor2PulseMin ("Glow Color 2 Pulse Min Brightness", RANGE(0.00, 1.0)) = 0.00
        _GlowColor2PulseMax ("Glow Color 2 Pulse Max Brightness", RANGE(0.00, 1.0)) = 1.00

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase" "ShadowCaster"="True" }

        Pass
        {

            CGPROGRAM
            #pragma vertex v
            #pragma fragment p

            sampler2D _DiffuseTex;
            sampler2D _NormalTex;

            float3 _LightColor0; 
            float _MinSpecularGlossiness;
            float _MaxSpecularGlossiness;
            float _MinDiffuseCoefficient;
            float _MaxDiffuseCoefficient;

            sampler2D _EffectTex;
            float _NoiseScalar;
            float4 _NoiseDirection;
            float4 _GlowChannelSpeeds;
            float4 _GlowColor0;
            float4 _GlowColor1;
            float4 _GlowColor2;
            float4 _GlowColor3;

            float _GlowColor0PulseMin;
            float _GlowColor0PulseMax;
            float _GlowColor1PulseMin;
            float _GlowColor1PulseMax;
            float _GlowColor2PulseMin;
            float _GlowColor2PulseMax;

            #include "UnityCG.cginc"

            struct VertIn
            {
                float4 position             : POSITION;
                float4 normal               : NORMAL;
                float4 tangent              : TANGENT;
                float2 uv                   : TEXCOORD0;
            };

            struct VertOut
            {
                float4 position             : POSITION;
                float2 uv                   : TEXCOORD0;
                float3 normal               : TEXCOORD1;
                float3 tangent              : TEXCOORD2;
                float3 bitangent            : TEXCOORD3;
                float4 worldPosition        : TEXCOORD4;
            };

            VertOut v( VertIn INPUT )
            {
                VertOut OUTPUT;

				OUTPUT.worldPosition = mul( _Object2World, INPUT.position );                
                OUTPUT.position = mul( UNITY_MATRIX_MVP, INPUT.position );

                OUTPUT.normal = normalize( mul( _Object2World, float4( INPUT.normal.xyz, 0.00 ) ) );
                OUTPUT.tangent = normalize( mul( _Object2World, float4( INPUT.tangent.xyz, 0.00 ) ) );
                OUTPUT.bitangent = normalize( cross( OUTPUT.normal, OUTPUT.tangent ) * INPUT.tangent.w );

                OUTPUT.uv = INPUT.uv;

                return OUTPUT;
            }

            struct PixelOut
            {
                float4 color : COLOR;
            };

            float3 addGlow( float3 inputColor, float2 inputUV )
            {
                
                float4 effectTexture = tex2D( _EffectTex, inputUV );

                float nx = fmod( _Time.y * _NoiseDirection.x, 1.0 );
                float ny = fmod( _Time.y * _NoiseDirection.y, 1.0 );
                float noise = tex2D( _EffectTex, inputUV + float2(nx, ny) ).a;

                float glowT0 = fmod( sin(_Time.y*_GlowChannelSpeeds.x + (noise*_NoiseScalar)), 1.0) * 0.5 + 0.5;
                float noiseT = lerp( _GlowColor0PulseMin, _GlowColor0PulseMax, glowT0);
                float3 noiseColor = ((noiseT * _GlowColor0.rgb) * _GlowColor0.a);
                noiseColor *= effectTexture.r;

                float glowT1 = sin(_Time.y * _GlowChannelSpeeds.y )*0.5+0.5;
                float3 glowColor1 = lerp( _GlowColor1PulseMin, _GlowColor1PulseMax, glowT1);
                float3 greenColor = glowColor1 * _GlowColor1.rgb * _GlowColor1.a;
                greenColor *= effectTexture.g;

                float glowT2 = sin(_Time.y * _GlowChannelSpeeds.z )*0.5+0.5;
                float3 glowColor2 = lerp( _GlowColor2PulseMin, _GlowColor2PulseMax, glowT2);
                float3 blueColor = glowColor2 * _GlowColor2.rgb * _GlowColor2.a;
                blueColor *= effectTexture.b;
                

                float3 finalColor = inputColor + noiseColor + greenColor + blueColor;

                return finalColor;
            }

            PixelOut p ( VertOut input )
            {
                PixelOut OUT;

                float4 diffuseTexture = tex2D( _DiffuseTex, input.uv );
                float4 normalTexture = tex2D( _NormalTex, input.uv );
                float3 normalInTangentSpace = UnpackNormal( normalTexture );
                
                float specularIntensity = diffuseTexture.a;
                float specularGlossiness = lerp(  _MinSpecularGlossiness, _MaxSpecularGlossiness, normalTexture.a);

                float3x3 tagentToWorldMatrix = float3x3(    normalize( input.tangent ),
                                                            normalize( input.bitangent ),
                                                            normalize( input.normal ) 
                                                        );

                float3 normal = normalize( mul( normalInTangentSpace, tagentToWorldMatrix ) );
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 toCamera = normalize( _WorldSpaceCameraPos - input.worldPosition );
                float3 halfVec = normalize( lightDir + toCamera );
                float3 hDotv = clamp( dot( halfVec, normal ), 0.00, 1.0 );


                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float diffuseCoefficient = clamp( dot( normal, lightDir ), _MinDiffuseCoefficient, _MaxDiffuseCoefficient );
                float3 diffuseColor = ((_LightColor0*diffuseTexture) * diffuseCoefficient);

                float specularCoefficient = pow( hDotv, specularGlossiness ) * specularIntensity;
                float specularColor = _LightColor0 * specularCoefficient;

                float3 finalColor = ambientColor + diffuseColor + specularColor;

                finalColor = addGlow( finalColor, input.uv );
                
                OUT.color = float4( finalColor, 1.0 );

                return OUT;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
