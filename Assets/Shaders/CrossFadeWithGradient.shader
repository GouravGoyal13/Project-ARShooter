// Where the Gradient Texture is white, we will see the normal background texture.
// Where the Gradient Texture is transparent, we will see the gradient texture multiplied
// into the background texture.

Shader "GLU/Texture Effects/Cross Fade With Gradient"
{
	Properties 
	{
		_CurrentTexture ("Current Texture", 2D) = "white" {}
		_NextTexture ("Next Texture", 2D) = "white" {}
		_CurrentGradientTexture ("Current Gradient Texture", 2D) = "white" {}
		_NextGradientTexture ("Next Gradient Texture", 2D) = "white" {}
		
		_CurrentGradientColor ("Current Gradient Color", COLOR) = (1,1,1,1)
		_NextGradientColor ("Next Gradient Color", COLOR) = (1,1,1,1)

		_TransitionPercent ("Transition Percent (T Value)", RANGE(0.0,1.0)) = 0.0
	}
	SubShader 
	{
		Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque" }
		LOD 300

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p
			#pragma multi_compile _ _DesaturateCurrentRender
			#pragma multi_compile _ _DesaturateNextRender
		
			sampler2D _CurrentTexture;
			float4 _CurrentTexture_ST;
			
			sampler2D _NextTexture;
			float4 _NextTexture_ST;
			
			sampler2D _CurrentGradientTexture;
			float4 _CurrentGradientTexture_ST;

			sampler2D _NextGradientTexture;
			float4 _NextGradientTexture_ST;
						
			float4 _CurrentGradientColor;
			float4 _NextGradientColor;
						
			float _TransitionPercent;
		
			/*
			float2 RotateUV( float2 uv, float rotationInDegrees )
			{
				float theta = radians(rotationInDegrees);
				
				float c = cos( theta );
				float s = sin( theta );
				
				uv.x -= 0.5;
				uv.y -= 0.5;
				
				float x = (uv.x * c) - (uv.y * s);
				float y = (uv.x * s) + (uv.y * c);
				
				x += 0.5;
				y += 0.5;
				
				return float2(x, y);																			
			}
			*/
		
			struct VertOut
			{
				float4 position 					: POSITION;
				float2 currentTextureUV 			: TEXCOORD0;
				float2 nextTextureUV 				: TEXCOORD1;
				float2 currentGradientTextureUV 	: TEXCOORD2;
				float2 nextGradientTextureUV 		: TEXCOORD3;
			};
			
			VertOut v( float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0 )
			{
				VertOut OUT;

				OUT.position = mul( UNITY_MATRIX_MVP, position );
				OUT.currentTextureUV 			= 	uv * _CurrentTexture_ST.xy 			+ _CurrentTexture_ST.zw;
				OUT.nextTextureUV 				= 	uv * _NextTexture_ST.xy 			+ _NextTexture_ST.zw;
				OUT.currentGradientTextureUV 	= 	uv * _CurrentGradientTexture_ST.xy 	+ _CurrentGradientTexture_ST.zw;
				OUT.nextGradientTextureUV 		= 	uv * _NextGradientTexture_ST.xy 	+ _NextGradientTexture_ST.zw;
				
				return OUT;
			}
			 
			struct PixelOut
			{
				float4 color : COLOR;
			};
			
			float3 ApplyGradient( float3 currentPixelColor, sampler2D gradientTexture, float3 gradientColorWeight, float2 uv )
			{
				float4 gradientTextureColor = tex2D(gradientTexture, 	uv);
				float3 gradientColor = gradientTextureColor.rgb + (gradientColorWeight * (1.0-gradientTextureColor.a));
				
				float3 finalColor = currentPixelColor * gradientColor.rgb;
				
				return finalColor;
			}
			
			PixelOut p ( VertOut input )
			{
				PixelOut OUT;
				
				float3 currentTextureColor 			= tex2D(_CurrentTexture, 			input.currentTextureUV);
				float3 nextTextureColor 			= tex2D(_NextTexture, 				input.nextTextureUV);
				
				currentTextureColor = ApplyGradient( 	currentTextureColor, 
														_CurrentGradientTexture, 
														_CurrentGradientColor.rgb, 
														input.currentGradientTextureUV );
													
				nextTextureColor = ApplyGradient( 	nextTextureColor, 
													_NextGradientTexture, 
													_NextGradientColor.rgb, 
													input.nextTextureUV );
				
				// The weights in the grayScaleFilter come from the following
				// nVidia GPU article.
				// http://http.developer.nvidia.com/GPUGems/gpugems_ch22.html
				float grayScaleFilter = float3(0.222, 0.707, 0.071);
				
				#ifdef _DesaturateCurrentRender
				{
					float d = dot(currentTextureColor.rgb,  grayScaleFilter);
					currentTextureColor = float3( d, d, d );
				}
				#endif
				
				#ifdef _DesaturateNextRender
				{
					float d = dot(nextTextureColor.rgb,  grayScaleFilter);
					nextTextureColor = float3( d, d, d );
				}
				#endif
								
				float3 mainTextureColor = lerp( currentTextureColor, nextTextureColor, _TransitionPercent );
				
				float3 finalColor = mainTextureColor;
				OUT.color = float4( finalColor, 1.0 );
				
				return OUT;
			}
			ENDCG
		}
	} 


	SubShader
	{
		Tags{ "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex v
			#pragma fragment p

			sampler2D _CurrentTexture;
			float4 _CurrentTexture_ST;

			sampler2D _NextTexture;
			float4 _NextTexture_ST;			

			float _TransitionPercent;		

			struct VertOut
			{
				float4 position 					: POSITION;
				float2 currentTextureUV 			: TEXCOORD0;
				float2 nextTextureUV 				: TEXCOORD1;				
			};

			VertOut v(float4 position : POSITION, float3 norm : NORMAL, float2 uv : TEXCOORD0)
			{
				VertOut OUT;

				OUT.position = mul(UNITY_MATRIX_MVP, position);
				OUT.currentTextureUV = uv * _CurrentTexture_ST.xy + _CurrentTexture_ST.zw;
				OUT.nextTextureUV = uv * _NextTexture_ST.xy + _NextTexture_ST.zw;				

				return OUT;
			}

			struct PixelOut
			{
				float4 color : COLOR;
			};			

			PixelOut p(VertOut input)
			{
				PixelOut OUT;

				float3 currentTextureColor = tex2D(_CurrentTexture, input.currentTextureUV);
				float3 nextTextureColor = tex2D(_NextTexture, input.nextTextureUV);				
								
				float3 mainTextureColor = lerp(currentTextureColor, nextTextureColor, _TransitionPercent);

				float3 finalColor = mainTextureColor;
				OUT.color = float4(finalColor, 1);

				return OUT;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}

