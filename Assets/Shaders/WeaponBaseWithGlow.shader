Shader "GLU/Weapon/Weapon Base With Glow" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture (Alpha = Specular Intensity)", 2D) = "white" {}
        _EffectTex ("Effect Texture (R=Reflection, G=Specular Gloss)", 2D) = "black" {}
        _EnvironmentMap ("Environment Map", CUBE) = "black" {}
        
        _MinSpecularGlossiness ("Minimum Specular Glossiness", Float ) = 8.0
        _MaxSpecularGlossiness ("Maximum Specular Glossiness", Float ) = 1000.0
        
        _EmissiveColor1 ("Emissive Color 1 (Effect Texture B Channel", COLOR ) = (0,0,0,1)
        _EmissiveColor2 ("Emissive Color 2 (Effect Texture B Channel", COLOR ) = (0,0,0,1)

        _EmissiveColorPulseSpeed ("Emissive Color Pulse Speed", FLOAT) = 0.5
        _MetalAdditiveMetalColorTint ("Additive Metal Color Tint (Alpha Controls Intensity)", COLOR) = (0,0,0,0)
        _MetalMultiplicativeMetalColorTint ("Multiplicative Metal Color Tint (Alpha Controls Intensity)", COLOR) = (1,1,1,1)
        
        _EnvironmentMapScale ("Environment Map Scale", Float) = 1.0

        _Roughness ("Reflection Roughness (Requires Mip Maps on CubeMap)", RANGE( 0.00, 5.00) ) = 0.00
        
        
        _GlowTex ("Glow Texture", 2D) = "black" {}
        _SheenTex ("Sheen Texture", 2D) = "black" {}
        
        _GlowColor0 ("Glow Color 0 (Red Channel)", COLOR ) = (1,0,0,1)
        _GlowDirection0 ("Glow Direction 0", VECTOR) = (1,0,0,0)
        _GlowColor1 ("Glow Color 0 (Green Channel)", COLOR ) = (0,1,0,1)
        _GlowDirection1 ("Glow Direction 1", VECTOR) = (0,1,0,0)
        _GlowColor2 ("Glow Color 0 (Blue Channel)", COLOR ) = (0,0,1,1)
        _GlowDirection2 ("Glow Direction 2", VECTOR) = (0,1,0,0)
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
        
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _DiffuseTex;
            sampler2D _EffectTex;
            samplerCUBE _EnvironmentMap;
            
            float3 _LightColor0; 
            float _MinSpecularGlossiness;
            float _MaxSpecularGlossiness;
            half _LightMode;
            float _MinPlayerDiffuseCoefficient;
            float _MaxPlayerDiffuseCoefficient;
            float4 _PlayerAmbientLight;
            float4 _MetalAdditiveMetalColorTint;
            float4 _MetalMultiplicativeMetalColorTint;
            float _EnvironmentMapScale;
            float _Roughness;
            float4 _EmissiveColor1;
            float4 _EmissiveColor2;
            float _EmissiveColorPulseSpeed;
            
            
			sampler2D _GlowTex;
			sampler2D _SheenTex;
	        float4 _GlowColor0;
	        float4 _GlowDirection0;
	        float4 _GlowColor1;
	        float4 _GlowDirection1;
	        float4 _GlowColor2;
	        float4 _GlowDirection2;            
            
            #include "UnityCG.cginc" 
        
            struct VertOut
            {
                float4 position                 : POSITION;
                float2 uv                       : TEXCOORD0;
                float3 reflectionDir            : TEXCOORD1;
                float3 worldNormal              : TEXCOORD2;
                float3 worldPosition            : TEXCOORD3;
            };
            
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                float3 worldPos = mul( _Object2World, position ).xyz;
                float3 viewDir = (worldPos*_EnvironmentMapScale) - _WorldSpaceCameraPos.xyz;
                
                float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
                
                float3 reflection = normalize( reflect( viewDir, normalVec ) );
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv = uv;
                OUT.reflectionDir = reflection;
                OUT.worldNormal = mul( _Object2World, normalize( float4(norm, 0.00) ) ).xyz;
                OUT.worldPosition = mul( _Object2World, position ).xyz;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            float3 applyGlow( float3 inputColor, float2 uv )
            {
            	float3 glowTexture = 		tex2D( _GlowTex,   	uv );
            	
            	float3 sheenTexture = float3( 0,0,0 );
				sheenTexture.r = 	tex2D( _SheenTex,   uv + float2( _GlowDirection0.x * _Time.y, _GlowDirection0.y * _Time.y) ).r;
            	sheenTexture.g = 	tex2D( _SheenTex, 	uv + float2( _GlowDirection1.x * _Time.y, _GlowDirection1.y * _Time.y) ).g;
            	sheenTexture.b = 	tex2D( _SheenTex,  	uv + float2( _GlowDirection2.x * _Time.y, _GlowDirection2.y * _Time.y) ).b;
            
            	float3 finalGlowColorRed 	= _GlowColor0.rgb * sheenTexture.r * glowTexture.r * _GlowColor0.a;
            	float3 finalGlowColorGreen 	= _GlowColor1.rgb * sheenTexture.g * glowTexture.g * _GlowColor1.a;
            	float3 finalGlowColorBlue 	= _GlowColor2.rgb * sheenTexture.b * glowTexture.b * _GlowColor2.a;
            	
            	return inputColor + finalGlowColorRed + finalGlowColorGreen + finalGlowColorBlue;
            }
            
            float3 blinnphongLighting( VertOut input, float4 diffuseTexture, float4 environmentTexture, float4 effectTexture )
            {
                float specularIntensity = diffuseTexture.a;
                float specularGlossiness = lerp(  _MinSpecularGlossiness, _MaxSpecularGlossiness, effectTexture.g );
                float reflectivityAmount = effectTexture.r;
                
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                float3 worldNormal = normalize( input.worldNormal );
                float3 toCamera = normalize( _WorldSpaceCameraPos - input.worldPosition );
                float3 halfVec = normalize( lightDir + toCamera );
                float3 hDotv = clamp( dot( halfVec, worldNormal ), 0.00, 1.0 );
                
                //float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 ambientColor = _PlayerAmbientLight.rgb * 0.50;

                float3 reflectionColor = (environmentTexture.rgb + (_MetalAdditiveMetalColorTint.rgb * _MetalAdditiveMetalColorTint.a)) * (_MetalMultiplicativeMetalColorTint.rgb * _MetalMultiplicativeMetalColorTint.a);
                float diffuseCoefficient = clamp( dot( worldNormal, lightDir ), _MinPlayerDiffuseCoefficient, _MaxPlayerDiffuseCoefficient );
                float3 diffuseColor = (_LightColor0 * (diffuseTexture.rgb + (reflectionColor * reflectivityAmount))) * diffuseCoefficient;
                
                float specularCoefficient = pow( hDotv, specularGlossiness ) * specularIntensity;
                float3 specularColor = _LightColor0 * specularCoefficient;
                
                float emissiveFactor = sin( fmod(_Time.y * _EmissiveColorPulseSpeed, 6.28318) ) * 0.5 + 0.5;  // 6.28318 = 2*PI
                float3 emissiveColor = lerp( _EmissiveColor1, _EmissiveColor2,  emissiveFactor ) * effectTexture.b;

                float3 finalColor = ambientColor + diffuseColor + specularColor + emissiveColor;
                
                finalColor = applyGlow( finalColor, input.uv );
                
                return finalColor;
            }
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;

                float4 diffuseTexture = tex2D( _DiffuseTex, input.uv );
                float4 effectTexture = tex2D( _EffectTex, input.uv );
                float4 environmentTexture = texCUBElod( _EnvironmentMap, float4( normalize(input.reflectionDir.xyz), _Roughness ) );
                float3 finalColor = float3( 0.0, 0.0, 0.0 );

                finalColor = blinnphongLighting( input, diffuseTexture, environmentTexture, effectTexture );
                OUT.color = float4( finalColor, 1.0 );
                
                return OUT;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
