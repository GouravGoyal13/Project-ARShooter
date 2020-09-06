Shader "GLU/Weapon/Player Hands" 
{
    Properties 
    {
        _DiffuseTex ("Diffuse Texture", 2D) = "white" {}
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        LOD 300

        Pass
        {
        
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
        
            sampler2D _DiffuseTex;
            
            float3 _LightColor0; 
            half _LightMode;
            float _MinPlayerDiffuseCoefficient;
            float _MaxPlayerDiffuseCoefficient;
            float4 _PlayerAmbientLight;
            
            #include "UnityCG.cginc" 
        
            struct VertOut
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldPosition        : TEXCOORD3;
            };
            
            VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut OUT;
                
                float3 worldPos = mul( _Object2World, position ).xyz;
                float3 viewDir = worldPos - _WorldSpaceCameraPos.xyz;
                
                float3 normalVec = normalize( mul( (float3x3)(_Object2World), norm ) ); 
                
                float3 reflection = normalize( reflect( viewDir, normalVec ) );
                
                OUT.position = mul( UNITY_MATRIX_MVP, position );
                OUT.uv = uv;
                OUT.viewDir = reflection;
                OUT.worldNormal = mul( _Object2World, normalize( float4(norm, 0.00) ) ).xyz;
                OUT.worldPosition = mul( _Object2World, position ).xyz;
                
                return OUT;
            }
             
            struct PixelOut
            {
                float4 color : COLOR;
            };
            
            float3 blinnphongLighting( VertOut input, float4 diffuseTexture )
            {   
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldNormal = normalize( input.worldNormal );
                
                float3 ambientColor = _PlayerAmbientLight.rgb * 0.50;
                
                float diffuseCoefficient = clamp( dot( worldNormal, lightDir ), _MinPlayerDiffuseCoefficient, _MaxPlayerDiffuseCoefficient );
                float3 diffuseColor = _LightColor0 * (diffuseTexture.rgb * diffuseCoefficient);
                
                float3 finalColor = ambientColor + diffuseColor;
                return finalColor;
            }
            
            PixelOut p ( VertOut input )
            {
                PixelOut OUT;
                
                float4 diffuseTexture = tex2D( _DiffuseTex, input.uv );
                float3 finalColor = float3( 0.0, 0.0, 0.0 );

                finalColor = blinnphongLighting( input, diffuseTexture );
                OUT.color = float4( finalColor, 1.0 );
                
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
				return c;
			}
			ENDCG
		}
	}

    FallBack "Diffuse"
}
