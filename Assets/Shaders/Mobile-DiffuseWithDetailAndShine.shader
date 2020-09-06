Shader "GLU/Diffuse With Detail And Shine" 
{
    Properties
    {
		[Toggle(NORMALMAP)] _NormalMap("Normal map enable", float) = 0
        _DiffuseTex ("Diffuse Texture (Alpha Controls Specular Intensity", 2D) = "white" {}
        _NormalTex ("Normal Map (Alpha Controls Specular Glossiness)", 2D) = "bump" {}

        _MinSpecularGlossiness ("Minimum Specular Glossiness", Float ) = 8.0
        _MaxSpecularGlossiness ("Maximum Specular Glossiness", Float ) = 58.0
        
        _MinDiffuseCoefficient ("Min Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0) ) = 0.3
        _MaxDiffuseCoefficient ("Max Diffuse Coefficient (0.00 to 1.0)", Range(0.0, 1.0) ) = 0.7
			
		_ShineColor("Shine Color", COLOR) = (1, 0, 0, 1)
		_ShinePower("Shine Power", Range(0.5, 8.0)) = 3.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase" "ShadowCaster"="True" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature NORMALMAP

            sampler2D _DiffuseTex;
#if NORMALMAP
            sampler2D _NormalTex;
#endif

            float3 _LightColor0; 
            float _MinSpecularGlossiness;
            float _MaxSpecularGlossiness;
            float _MinDiffuseCoefficient;
            float _MaxDiffuseCoefficient;
            
			float4 _ShineColor;
			float _ShinePower;

            #include "UnityCG.cginc"

            struct VertIn
            {
                float4 position             : POSITION;
                float4 normal               : NORMAL;
				float2 uv                   : TEXCOORD0;
#if NORMALMAP
                float4 tangent              : TANGENT;   
#endif
            };

            struct VertOut
            {
                float4 position             : POSITION;
                float2 uv                   : TEXCOORD0;
				float4 worldPosition        : TEXCOORD1;
                float3 normal               : TEXCOORD2;
#if NORMALMAP
                float3 tangent              : TEXCOORD3;
                float3 bitangent            : TEXCOORD4;
#endif                
            };

            VertOut vert(VertIn i)
            {
                VertOut o;
				
				o.worldPosition = mul(_Object2World, i.position);
                o.position = mul(UNITY_MATRIX_MVP, i.position);

                o.normal = normalize(mul(_Object2World, float4(i.normal.xyz, 0.00)));
#if NORMALMAP
                o.tangent = normalize(mul(_Object2World, float4(i.tangent.xyz, 0.00)));
                o.bitangent = normalize(cross(o.normal, o.tangent ) * i.tangent.w);
#endif
                o.uv = i.uv;

                return o;
            }                       

			float4 frag(VertOut i) : COLOR
            {         
#if NORMALMAP
				float4 normalTexture = tex2D(_NormalTex, i.uv);
                float3 normalInTangentSpace = UnpackNormal(normalTexture);                
                float3x3 tagentToWorldMatrix = float3x3(normalize(i.tangent), normalize(i.bitangent), normalize(i.normal));
                float3 normal = normalize(mul(normalInTangentSpace, tagentToWorldMatrix));
#else
				float3 normal = i.normal;
#endif

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 halfVec = normalize(lightDir + viewDir);
                float3 hDotv = clamp(dot(halfVec, normal), 0.0, 1.0);
				
				float4 diffuseTexture = tex2D(_DiffuseTex, i.uv);
                float diffuseCoefficient = clamp(dot(normal, lightDir), _MinDiffuseCoefficient, _MaxDiffuseCoefficient);
                float3 diffuseColor = (_LightColor0 * diffuseTexture) * diffuseCoefficient;
				
#if NORMALMAP
				float specularGlossiness = lerp(_MinSpecularGlossiness, _MaxSpecularGlossiness, normalTexture.a);
#else
				float specularGlossiness = _MaxSpecularGlossiness;
#endif
				float specularIntensity = diffuseTexture.a;				
                float specularCoefficient = pow(hDotv, specularGlossiness) * specularIntensity;
                float3 specularColor = _LightColor0 * specularCoefficient;

				float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;

				float rim = 1.0 - saturate(dot(normalize(viewDir), i.normal));
				float3 shineColor = _ShineColor.rgb * pow(rim, _ShinePower) * _ShineColor.a;

                float3 finalColor = ambientColor + diffuseColor + specularColor + shineColor;

				float4 o = float4(finalColor, 1.0);	

                return o;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
