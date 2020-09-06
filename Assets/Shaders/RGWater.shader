Shader "RG/Water"
{
    Properties
    {
        _WaterCubemap ("Water Cubemap (RGB)", CUBE) = "white" {}
        _FlowMap ("Flow Map (Controlled By Z)", 2D) = "white" {}
        _SpecMask ("Specular Mask (Red Specifies where Spec can be seen, Alpha Controls Water Transparency)", 2D) = "black" {}        
        _FlowDirection ("Flow Direction", VECTOR) = (0,0,0,0)        
        _SpecColor ("Specular Color (Alpha Controls Intensity)", COLOR) = (0,0,0,1)
        _SpecThreshold ("Specular Threshold (Between FlowMap Color and Wave Map Color", FLOAT) = 0.97
        _MinMaxSpec ("Min Max Specular", VECTOR) = ( 0.00, 1.0, 0.00, 0.00)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        
        Fog { Mode Off }

        Pass
        {
            CGPROGRAM
            #pragma vertex v
            #pragma fragment p
           
            #include "UnityCG.cginc"

            samplerCUBE _WaterCubemap;
            float4 _WaterCubemap_ST;
            sampler2D _FlowMap;
            sampler2D _WaveMap;
            sampler2D _SpecMask;
            float4 _SpecMask_ST;
            float4 _FlowDirection;            
            float4 _SpecColor;
            float _SpecThreshold;
            float4 _MinMaxSpec;

            struct VertOut
            {
                float4 position         : POSITION;
				float4 color			: COLOR;
                float3 worldPos         : TEXCOORD0;
                float3 worldNormal      : TEXCOORD1;
                float2 uv               : TEXCOORD3;
            };
           
            VertOut v( float4 position : POSITION, float4 color : COLOR, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
            {
                VertOut o;
               
                float3 worldPos = mul(_Object2World, position).xyz;
				float3 worldNormal = normalize(mul((float3x3)_Object2World, norm));
               
                o.position = mul( UNITY_MATRIX_MVP, position );
				o.color = color;
                o.worldPos = worldPos;
                o.worldNormal = worldNormal;
                o.uv = uv.xy;
               
                return o;
            }
           
            struct PixelOut
            {
                float4 color : COLOR;
            };
           
            PixelOut p ( VertOut i )
            {
                PixelOut o;
               
                // Due to gpu precision limitations, we need to
                // "reset" our time value before it gets too high and begins to cause
                // artifacts.  
				float time = _Time.y;// fmod(_Time.y, 180.0); // 180 = 3 minutes

				float2 fuv = i.uv + (float2(_FlowDirection.xy) * time);
               
                float4 diffuseColor = tex2D( _FlowMap, i.uv);
                float4 flowMapColor = tex2D( _FlowMap, fuv * _FlowDirection.z  );
               				
				float3 worldCamPos = _WorldSpaceCameraPos + flowMapColor.xyz;
               
                float3 worldNormal = normalize( i.worldNormal );                                                 
                float3 viewDir = normalize( i.worldPos - worldCamPos );
                float3 reflection = normalize( reflect( viewDir, worldNormal ) );
                
				float4 reflectionColor = texCUBE(_WaterCubemap, reflection);
               
                float4 globalSpecColor = tex2D( _SpecMask, i.uv * _SpecMask_ST.xy + _SpecMask_ST.zw );
               
                float finalAlpha = globalSpecColor.a;
                float4 specColor = float4( 0,0,0,0 );
               
               	float d = diffuseColor.x * flowMapColor.x;
                if( d > _SpecThreshold )
                {
                    //specColor = _SpecColor * globalSpecColor.x * clamp( dot( worldNormal, -viewDir), _MinMaxSpec.x, _MinMaxSpec.y ) ;
					specColor = _SpecColor * clamp(dot(worldNormal, -viewDir), _MinMaxSpec.x, _MinMaxSpec.y);
                    finalAlpha *= _SpecColor.a;
                }
               
				//finalAlpha *= i.color.a;

				//float4 finalColor = reflectionColor + specColor;
				float4 finalColor = specColor;
				//float4 finalColor = float4(0, 0, 0, 1);
				//finalColor.rgb = diffuseColor.rgb * flowMapColor.rgb;
                finalColor.a = finalAlpha;

				finalColor = reflectionColor;
               
                o.color = finalColor;               
               
                return o;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}