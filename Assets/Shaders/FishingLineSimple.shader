Shader "GLU/Weapon/Fishing Line (Simple)" 
{
    Properties 
    {
		[Toggle(UV_LIGHTING)] _UVLighting("UV lighting", float) = 0
        _DiffuseTex ("Diffuse Texture (Alpha = Specular Intensity)", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_Intensity("Intensity", float) = 1
        
    }
    SubShader 
    {    	
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		
        Pass
        {        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature UV_LIGHTING
        
            sampler2D _DiffuseTex;
			float4 _Color;
            float3 _LightColor0; 
            float _MinPlayerDiffuseCoefficient;
            float _MaxPlayerDiffuseCoefficient;
            float4 _PlayerAmbientLight;      
			float _Intensity;
            
            #include "UnityCG.cginc" 
        
            struct VertOut
            {
                float4 position                 : POSITION;
                float2 uv                       : TEXCOORD0;
				float3 worldNormal              : TEXCOORD1;
            };

			float3 lighting(VertOut input, float4 diffuseColor)
			{
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldNormal = normalize(input.worldNormal);

				float diffuseCoefficient = clamp(dot(worldNormal, lightDir), _MinPlayerDiffuseCoefficient, _MaxPlayerDiffuseCoefficient);
				float3 final = diffuseColor.rgb * diffuseCoefficient;

				return final;
			}

			float3 uv_lighting(VertOut input, float4 diffuseColor)
			{
				float amp = _MaxPlayerDiffuseCoefficient - _MinPlayerDiffuseCoefficient;
				//float3 final = diffuseColor.rgb * (_MinPlayerDiffuseCoefficient + amp * sin(3.14 * input.uv.y));
				float3 final = diffuseColor.rgb * (_MinPlayerDiffuseCoefficient + amp * (1 - abs(2 * input.uv.y - 1)));

				return final;
			}
            
            VertOut vert(appdata_full v)
            {
                VertOut OUT;
                
                OUT.position = mul( UNITY_MATRIX_MVP, v.vertex);
                OUT.uv = v.texcoord;
				OUT.worldNormal = mul(_Object2World, normalize(float4(v.normal, 0.00))).xyz;
                
                return OUT;
            }
            
			float4 frag( VertOut input ) : COLOR
            {                
                float4 diffuseColor = tex2D( _DiffuseTex, input.uv );								
#if UV_LIGHTING
				float3 finalColor = uv_lighting(input, diffuseColor);
#else
				float3 finalColor = lighting(input, diffuseColor);
#endif                
				float3 lightColor = clamp(_LightColor0, 0, 1);
				float3 ambientColor = _PlayerAmbientLight.rgb * 0.50;

				finalColor = (finalColor * lightColor * _Color) * _Intensity + ambientColor;							
								               
                return float4(finalColor, 1);
            }			
            ENDCG
        }
    }     

    FallBack "Diffuse"
}
