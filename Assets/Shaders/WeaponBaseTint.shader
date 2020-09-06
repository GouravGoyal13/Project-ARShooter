Shader "GLU/Weapon/Weapon Base Tint" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture (Alpha = Specular Intensity)", 2D) = "white" {}
        _EffectTex ("Effect Texture (R=Reflection, G=Specular Gloss)", 2D) = "black" {}
        _EnvironmentMap ("Environment Map", CUBE) = "black" {}
		_Color("Color", Color) = (1, 1, 1, 1)
        
        _MinSpecularGlossiness ("Minimum Specular Glossiness", Float ) = 8.0
        _MaxSpecularGlossiness ("Maximum Specular Glossiness", Float ) = 1000.0
        
        _MetalAdditiveMetalColorTint ("Additive Metal Color Tint (Alpha Controls Intensity)", COLOR) = (0,0,0,0)
        _MetalMultiplicativeMetalColorTint ("Multiplicative Metal Color Tint (Alpha Controls Intensity)", COLOR) = (1,1,1,1)
        
        _EnvironmentMapScale ("Environment Map Scale", Float) = 1.0

        _Roughness ("Reflection Roughness (Requires Mip Maps on CubeMap)", RANGE( 0.00, 5.00) ) = 0.00
    }
    SubShader 
    {
    	LOD 300
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

			float4 _Color;
            
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
                
                //float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 ambientColor = _PlayerAmbientLight.rgb * 0.50;

                float3 reflectionColor = (environmentTexture.rgb + (_MetalAdditiveMetalColorTint.rgb * _MetalAdditiveMetalColorTint.a)) * (_MetalMultiplicativeMetalColorTint.rgb * _MetalMultiplicativeMetalColorTint.a);
                float diffuseCoefficient = clamp( dot( worldNormal, lightDir ), _MinPlayerDiffuseCoefficient, _MaxPlayerDiffuseCoefficient );
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
                float4 environmentTexture = texCUBElod( _EnvironmentMap, float4( normalize(input.reflectionDir.xyz), _Roughness ) );
                float3 finalColor = float3( 0.0, 0.0, 0.0 );

                finalColor = blinnphongLighting( input, diffuseTexture, environmentTexture, effectTexture );
                OUT.color = float4( finalColor, 1.0 ) * _Color;
                
                return OUT;
            }
            ENDCG
        }
    } 

    SubShader 
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" "ShadowCaster"="True" }
		LOD 200
		Cull Back
		Lighting Off

		Pass
		{		
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			float4 _Color;
		
			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			VertOut v( float4 position : POSITION, float2 uv : TEXCOORD0, fixed3 color : COLOR )
			{
				VertOut OUT;
				
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.uv = (uv * _DiffuseTex_ST.xy) + _DiffuseTex_ST.zw;
				
				return OUT;
			}	

			fixed4 p ( VertOut input ) : COLOR
			{
				fixed4 c = tex2D( _DiffuseTex, input.uv);
				c.a = 1;
				return c * _Color;
			}
			ENDCG
		}
	}

    FallBack "Diffuse"
}
