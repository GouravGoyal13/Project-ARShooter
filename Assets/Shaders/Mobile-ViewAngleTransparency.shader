Shader "GLU/View Angle Transparency" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_AngleThresholdInDegress ("Max Angle Threshold In Degrees", Float) = 45.0
	}
	
	SubShader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }  
		LOD 200

		Pass
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode Off }
			
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			#define PI 3.14159
			#define PI_DIV_2 PI / 2.0
		
			sampler2D _MainTex;
			float _AngleThresholdInDegress;
		
			struct VertOut
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float2 alpha : TEXCOORD1;
				float4 vertColor : TEXCOORD2;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0, float4 vertColor : COLOR  )
			{
				VertOut OUT;
				
				float alpha = 1.0f;
				float4 fromCamToVert = mul( UNITY_MATRIX_MV, float4(0,0,0,1));
				
				fromCamToVert.w = 0.00f;
				fromCamToVert = normalize( fromCamToVert );
				
				alpha = dot( fromCamToVert, float4( 0.0f, 0.0f, -1.0f, 0.0f ) );
				alpha = clamp( alpha, 0.00, 1.0 );

				float thresholdInRadians = (_AngleThresholdInDegress * PI / 180.0);
				alpha = 1.0 - ((1.0-alpha) * ( PI / thresholdInRadians )); 
				alpha = clamp( alpha, 0.00, 1.0 );
				
				OUT.position = mul( UNITY_MATRIX_MVP, position ); 
				OUT.uv = uv;
				OUT.alpha = float2( alpha, alpha );
				OUT.vertColor = vertColor;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float4 finalColor = tex2D( _MainTex, input.uv );
				finalColor.rgb *= input.vertColor.xyz;
				finalColor.a = clamp( input.alpha.x * finalColor.a, 0.00, 1.0 );
				
				OUT.color = finalColor;
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}

