Shader "GLU/ColorPulse" 
{
	Properties 
	{
		_Color1 ("Color 1", COLOR) = (0.0,1.0,0.0)
		_Color2 ("Color 2", COLOR) = (1.0,1.0,0.0)
		_PulseSpeed ("Pulse Speed", FLOAT) = 3.0
	}
	
	SubShader 
	{
		Tags { "Queue"="Geometry" }

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
		
			float4 _Color1;
			float4 _Color2;
			float _PulseSpeed;
		
			struct VertOut
			{
				float4 position : POSITION;
				float3 color : COLOR;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL )
			{
				VertOut OUT;
				
				float t = sin( _Time.y *_PulseSpeed ) * 0.5 + 0.5;
				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.color = lerp( _Color1, _Color2, t );
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				OUT.color = float4(input.color, 1.0);
				
				return OUT;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
