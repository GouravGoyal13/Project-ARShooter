Shader "GLU/UI/Chrome" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture (Alpha = Specular Intensity)", 2D) = "white" {}
        _EffectTex ("Effect Texture (R=Reflection, G=Specular Gloss)", 2D) = "black" {}
        _EnvironmentMap ("Environment Map", CUBE) = "black" {}
        
        _MinDiffuseCoefficient ("Min Diffuse Coefficient", RANGE(0.00, 1.0) ) = 0.0
        _MaxDiffuseCoefficient ("Max Diffuse Coefficient", RANGE(0.00, 1.0) ) = 1.0
        
        _MinSpecularGlossiness ("Minimum Specular Glossiness", Float ) = 8.0
        _MaxSpecularGlossiness ("Maximum Specular Glossiness", Float ) = 58.0
        
        _MetalAdditiveMetalColorTint ("Additive Metal Color Tint (Alpha Controls Intensity)", COLOR) = (0,0,0,1)
        _MetalMultiplicativeMetalColorTint ("Multiplicative Metal Color Tint (Alpha Controls Intensity)", COLOR) = (0,0,0,1)
        
        _EnvironmentMapScale ("Environment Map Scale", Float) = 1.0
        
        
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
            float _MinDiffuseCoefficient;
            float _MaxDiffuseCoefficient;
            float4 _MetalAdditiveMetalColorTint;
            float4 _MetalMultiplicativeMetalColorTint;
            float _EnvironmentMapScale;
            
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
                
                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 reflectionColor = (environmentTexture.rgb + (_MetalAdditiveMetalColorTint.rgb * _MetalAdditiveMetalColorTint.a)) * (_MetalMultiplicativeMetalColorTint.rgb * _MetalMultiplicativeMetalColorTint.a);
                float diffuseCoefficient = clamp( dot( worldNormal, lightDir ), _MinDiffuseCoefficient, _MaxDiffuseCoefficient );
                float3 diffuseColor = (_LightColor0 * (diffuseTexture.rgb + (reflectionColor * reflectivityAmount))) * diffuseCoefficient;
                
                float specularCoefficient = pow( hDotv, specularGlossiness ) * specularIntensity;
                float3 specularColor = _LightColor0 * specularCoefficient;
                
                float3 finalColor = ambientColor + diffuseColor + specularColor;
                return finalColor;
            }
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float4 diffuseTexture = tex2D( _DiffuseTex, input.uv );
                float4 effectTexture = tex2D( _EffectTex, input.uv );
                float4 environmentTexture = texCUBE( _EnvironmentMap, normalize(input.reflectionDir) );
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
